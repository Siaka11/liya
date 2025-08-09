/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

// Initialize Firebase Admin
initializeApp();

const db = getFirestore();
const messaging = getMessaging();

/**
 * Mettre à jour le token FCM d'un utilisateur
 */
exports.updateFCMToken = onRequest(function(req, res) {
  const phone = req.body.phone;
  const fcmToken = req.body.fcm_token;

  if (!phone || !fcmToken) {
    return res.status(400).json({
      success: false,
      error: "phone et fcm_token sont requis",
    });
  }

  // Normaliser le numéro de téléphone pour Firestore
  const normalizedPhone = phone.startsWith("+225") ? phone : `+225${phone}`;

  // Mettre à jour le token dans Firestore
  db.collection("users").doc(normalizedPhone).update({
    fcm_token: fcmToken,
    fcm_token_updated_at: new Date(),
  })
      .then(function() {
        console.log(`✅ Token FCM mis à jour pour ${normalizedPhone}`);
        res.json({
          success: true,
          message: "Token FCM mis à jour avec succès",
        });
      })
      .catch(function(error) {
        console.error(`❌ Erreur mise à jour token FCM pour ${normalizedPhone}:`, error);

        // Si l'utilisateur n'existe pas, essayer de le créer
        if (error.code === "not-found") {
          db.collection("users").doc(normalizedPhone).set({
            fcm_token: fcmToken,
            fcm_token_updated_at: new Date(),
            created_at: new Date(),
          })
              .then(function() {
                console.log(`✅ Utilisateur créé avec token FCM pour ${normalizedPhone}`);
                res.json({
                  success: true,
                  message: "Utilisateur créé avec token FCM",
                });
              })
              .catch(function(createError) {
                console.error(`❌ Erreur création utilisateur pour ${normalizedPhone}:`, createError);
                res.status(500).json({
                  success: false,
                  error: "Erreur lors de la création de l'utilisateur",
                });
              });
        } else {
          res.status(500).json({
            success: false,
            error: "Erreur lors de la mise à jour du token FCM",
          });
        }
      });
});

/**
 * Envoyer une notification à un utilisateur spécifique
 */
exports.sendNotification = onRequest(function(req, res) {
  const phone = req.body.phone;
  const title = req.body.title;
  const body = req.body.body;
  const data = req.body.data;

  if (!phone || !title || !body) {
    return res.status(400).json({
      success: false,
      error: "phone, title et body sont requis",
    });
  }

  // Normaliser le numéro de téléphone pour Firestore
  const normalizedPhone = phone.startsWith("+225") ? phone : `+225${phone}`;

  // Récupérer le token FCM de l'utilisateur
  db.collection("users").doc(normalizedPhone).get()
      .then(function(userDoc) {
        if (!userDoc.exists) {
          return res.status(404).json({
            success: false,
            error: "Utilisateur non trouvé",
          });
        }

        const userData = userDoc.data();

        // Gérer les deux formats possibles : fcm_token (string) ou fcm_tokens (array)
        let fcmToken = null;
        if (userData.fcm_token) {
          fcmToken = userData.fcm_token;
        } else if (userData.fcm_tokens && userData.fcm_tokens.length > 0) {
          fcmToken = userData.fcm_tokens[0]; // Prendre le premier token
        }

        if (!fcmToken) {
          return res.status(400).json({
            success: false,
            error: "Token FCM non trouvé pour cet utilisateur",
          });
        }

        // Préparer le message
        const message = {
          token: fcmToken,
          notification: {
            title: title,
            body: body,
          },
          data: data || {},
          android: {
            priority: "high",
            notification: {
              channel_id: "default",
              priority: "high",
              default_sound: true,
              default_vibrate_timings: true,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        };

        // Envoyer la notification
        return messaging.send(message);
      })
      .then(function(response) {
        // Sauvegarder l'historique de notification
        return db.collection("notifications").add({
          recipient_phone: normalizedPhone,
          title: title,
          body: body,
          data: data || {},
          sent_at: new Date(),
          success: true,
          message_id: response,
        });
      })
      .then(function() {
        res.json({
          success: true,
          message: "Notification envoyée avec succès",
        });
      })
      .catch(function(error) {
        console.error("Erreur envoi notification:", error);

        // Sauvegarder l'erreur
        db.collection("notifications").add({
          recipient_phone: normalizedPhone,
          title: title || "",
          body: body || "",
          data: data || {},
          sent_at: new Date(),
          success: false,
          error: error.message,
        });

        res.status(500).json({
          success: false,
          error: "Erreur lors de l'envoi de la notification",
        });
      });
});

/**
 * Envoyer une notification à tous les utilisateurs d'un rôle spécifique
 */
exports.sendNotificationToRole = onRequest(function(req, res) {
  const role = req.body.role;
  const title = req.body.title;
  const body = req.body.body;
  const data = req.body.data;

  if (!role || !title || !body) {
    return res.status(400).json({
      success: false,
      error: "role, title et body sont requis",
    });
  }

  // Récupérer tous les utilisateurs avec ce rôle
  db.collection("users")
      .where("role", "==", role)
      .get()
      .then(function(usersSnapshot) {
        if (usersSnapshot.empty) {
          return res.status(404).json({
            success: false,
            error: `Aucun utilisateur trouvé avec le rôle: ${role}`,
          });
        }

        const tokens = [];
        const users = [];

        usersSnapshot.forEach(function(doc) {
          const userData = doc.data();
          // Gérer les deux formats possibles : fcm_token (string) ou fcm_tokens (array)
          let fcmToken = null;
          if (userData.fcm_token) {
            fcmToken = userData.fcm_token;
          } else if (userData.fcm_tokens && userData.fcm_tokens.length > 0) {
            fcmToken = userData.fcm_tokens[0]; // Prendre le premier token
          }

          if (fcmToken) {
            tokens.push(fcmToken);
            users.push({
              phone: doc.id,
              name: userData.name || "Utilisateur",
            });
          }
        });

        if (tokens.length === 0) {
          return res.status(400).json({
            success: false,
            error: "Aucun token FCM trouvé pour ce rôle",
          });
        }

        // Envoyer les notifications une par une au lieu d'utiliser sendMulticast
        const promises = tokens.map(function(token, index) {
          const message = {
            token: token,
            notification: {
              title: title,
              body: body,
            },
            data: data || {},
            android: {
              priority: "high",
              notification: {
                channel_id: "default",
                priority: "high",
                default_sound: true,
                default_vibrate_timings: true,
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: "default",
                  badge: 1,
                },
              },
            },
          };

          return messaging.send(message)
              .then(function(response) {
                return {
                  success: true,
                  messageId: response,
                  user: users[index],
                };
              })
              .catch(function(error) {
                console.error(`Erreur envoi notification à ${users[index].phone}:`, error);
                return {
                  success: false,
                  error: error.message,
                  user: users[index],
                };
              });
        });

        return Promise.all(promises);
      })
      .then(function(results) {
        const successCount = results.filter(function(r) {
          return r.success;
        }).length;
        const failureCount = results.length - successCount;

        res.json({
          success: true,
          message: `Notification envoyée à ${successCount}/${results.length} utilisateurs`,
          success_count: successCount,
          failure_count: failureCount,
          results: results,
        });
      })
      .catch(function(error) {
        console.error("Erreur envoi notification par rôle:", error);
        res.status(500).json({
          success: false,
          error: "Erreur lors de l'envoi de la notification",
        });
      });
});

/**
 * Fonction de test pour vérifier que les Functions fonctionnent
 */
exports.testFunction = onRequest(function(req, res) {
  res.json({
    success: true,
    message: "Firebase Functions fonctionnent correctement !",
    timestamp: new Date().toISOString(),
  });
});

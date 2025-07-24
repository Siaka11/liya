const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialiser Firebase Admin
admin.initializeApp();

const db = admin.firestore();

// Fonction pour envoyer une notification FCM
async function sendNotification(token, title, body, data = {}) {
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: data,
      token: token,
    };

    const response = await admin.messaging().send(message);
    console.log('Notification envoyée avec succès:', response);
    return response;
  } catch (error) {
    console.error('Erreur envoi notification:', error);
    throw error;
  }
}

// Fonction pour récupérer le token FCM d'un utilisateur
async function getUserFcmToken(userId) {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data().fcm_token) {
      return userDoc.data().fcm_token;
    }
    return null;
  } catch (error) {
    console.error('Erreur récupération token FCM:', error);
    return null;
  }
}

// 1. Notification quand une commande est assignée à un livreur
exports.notifyOrderAssigned = functions.firestore
  .document('delivery_orders/{orderId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    
    // Vérifier si le statut a changé vers "assigned"
    if (newData.status === 'assigned' && previousData.status !== 'assigned') {
      try {
        // Notification au client
        const clientToken = await getUserFcmToken(newData.clientId);
        if (clientToken) {
          await sendNotification(
            clientToken,
            'Commande assignée !',
            `Votre commande #${newData.id} a été assignée à un livreur.`,
            {
              type: 'order_assigned',
              orderId: newData.id,
              deliveryUserId: newData.deliveryUserId,
            }
          );
        }

        // Notification au livreur
        const deliveryUserToken = await getUserFcmToken(newData.deliveryUserId);
        if (deliveryUserToken) {
          await sendNotification(
            deliveryUserToken,
            'Nouvelle livraison !',
            `Vous avez une nouvelle livraison #${newData.id} à effectuer.`,
            {
              type: 'new_delivery',
              orderId: newData.id,
              clientId: newData.clientId,
            }
          );
        }

        console.log('Notifications envoyées pour la commande assignée:', newData.id);
      } catch (error) {
        console.error('Erreur notifications commande assignée:', error);
      }
    }
  });

// 2. Notification quand une livraison commence
exports.notifyDeliveryStarted = functions.firestore
  .document('delivery_orders/{orderId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    
    // Vérifier si le statut a changé vers "en_route"
    if (newData.status === 'en_route' && previousData.status !== 'en_route') {
      try {
        // Notification au client
        const clientToken = await getUserFcmToken(newData.clientId);
        if (clientToken) {
          await sendNotification(
            clientToken,
            'Livraison en cours !',
            `Votre commande #${newData.id} est en route vers vous.`,
            {
              type: 'delivery_started',
              orderId: newData.id,
              deliveryUserId: newData.deliveryUserId,
            }
          );
        }

        console.log('Notification envoyée pour livraison en cours:', newData.id);
      } catch (error) {
        console.error('Erreur notification livraison en cours:', error);
      }
    }
  });

// 3. Notification quand une livraison est terminée
exports.notifyDeliveryCompleted = functions.firestore
  .document('delivery_orders/{orderId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    
    // Vérifier si le statut a changé vers "completed"
    if (newData.status === 'completed' && previousData.status !== 'completed') {
      try {
        // Notification au client
        const clientToken = await getUserFcmToken(newData.clientId);
        if (clientToken) {
          await sendNotification(
            clientToken,
            'Livraison terminée !',
            `Votre commande #${newData.id} a été livrée avec succès.`,
            {
              type: 'delivery_completed',
              orderId: newData.id,
              deliveryUserId: newData.deliveryUserId,
            }
          );
        }

        // Notification au livreur
        const deliveryUserToken = await getUserFcmToken(newData.deliveryUserId);
        if (deliveryUserToken) {
          await sendNotification(
            deliveryUserToken,
            'Livraison terminée !',
            `Vous avez terminé la livraison #${newData.id} avec succès.`,
            {
              type: 'delivery_completed',
              orderId: newData.id,
              clientId: newData.clientId,
            }
          );
        }

        console.log('Notifications envoyées pour livraison terminée:', newData.id);
      } catch (error) {
        console.error('Erreur notifications livraison terminée:', error);
      }
    }
  });

// 4. Notification pour les nouvelles commandes restaurant
exports.notifyNewRestaurantOrder = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const orderData = snap.data();
    
    try {
      // Notification à tous les livreurs disponibles
      const deliveryUsersSnapshot = await db
        .collection('users')
        .where('user_type', '==', 'delivery')
        .where('notification_enabled', '==', true)
        .get();

      const notifications = deliveryUsersSnapshot.docs.map(async (doc) => {
        const userData = doc.data();
        if (userData.fcm_token) {
          return sendNotification(
            userData.fcm_token,
            'Nouvelle commande restaurant !',
            `Une nouvelle commande #${orderData.id} est disponible.`,
            {
              type: 'new_restaurant_order',
              orderId: orderData.id,
              restaurantId: orderData.restaurantId,
            }
          );
        }
      });

      await Promise.all(notifications);
      console.log('Notifications envoyées pour nouvelle commande restaurant:', orderData.id);
    } catch (error) {
      console.error('Erreur notifications nouvelle commande restaurant:', error);
    }
  });

// 5. Notification pour les nouveaux colis
exports.notifyNewParcel = functions.firestore
  .document('parcels/{parcelId}')
  .onCreate(async (snap, context) => {
    const parcelData = snap.data();
    
    try {
      // Notification à tous les livreurs disponibles
      const deliveryUsersSnapshot = await db
        .collection('users')
        .where('user_type', '==', 'delivery')
        .where('notification_enabled', '==', true)
        .get();

      const notifications = deliveryUsersSnapshot.docs.map(async (doc) => {
        const userData = doc.data();
        if (userData.fcm_token) {
          return sendNotification(
            userData.fcm_token,
            'Nouveau colis à livrer !',
            `Un nouveau colis #${parcelData.id} est disponible.`,
            {
              type: 'new_parcel',
              parcelId: parcelData.id,
              pickupAddress: parcelData.pickupAddress,
              deliveryAddress: parcelData.deliveryAddress,
            }
          );
        }
      });

      await Promise.all(notifications);
      console.log('Notifications envoyées pour nouveau colis:', parcelData.id);
    } catch (error) {
      console.error('Erreur notifications nouveau colis:', error);
    }
  });

// 6. Fonction pour envoyer une notification personnalisée (pour les tests)
exports.sendCustomNotification = functions.https.onCall(async (data, context) => {
  // Vérifier l'authentification
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }

  const { userId, title, body, data: notificationData } = data;

  try {
    const token = await getUserFcmToken(userId);
    if (token) {
      await sendNotification(token, title, body, notificationData);
      return { success: true, message: 'Notification envoyée' };
    } else {
      throw new functions.https.HttpsError('not-found', 'Token FCM non trouvé');
    }
  } catch (error) {
    console.error('Erreur envoi notification personnalisée:', error);
    throw new functions.https.HttpsError('internal', 'Erreur envoi notification');
  }
});

// 7. Fonction pour nettoyer les tokens FCM invalides
exports.cleanupInvalidTokens = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  try {
    const usersSnapshot = await db.collection('users').get();
    const cleanupPromises = [];

    usersSnapshot.docs.forEach(async (doc) => {
      const userData = doc.data();
      if (userData.fcm_token) {
        // Vérifier si le token est toujours valide
        try {
          await admin.messaging().send({
            token: userData.fcm_token,
            data: { test: 'true' }
          });
        } catch (error) {
          // Token invalide, le supprimer
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            cleanupPromises.push(
              doc.ref.update({
                fcm_token: admin.firestore.FieldValue.delete()
              })
            );
          }
        }
      }
    });

    await Promise.all(cleanupPromises);
    console.log('Nettoyage des tokens FCM terminé');
  } catch (error) {
    console.error('Erreur nettoyage tokens FCM:', error);
  }
}); 
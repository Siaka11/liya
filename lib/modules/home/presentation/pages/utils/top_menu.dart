

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/singletons.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../routes/app_router.gr.dart';
import '../../../../auth/auth_provider.dart';
import '../../../application/home_provider.dart';

void showTopMenu(BuildContext context, WidgetRef ref) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton de fermeture
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Options "Profil" et "Déconnexion" alignées horizontalement
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Option "Profil"
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(); // Ferme le menu
                              //singleton<AppRouter>().push(const ProfileRoute());
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Profil',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 1,
                            height: 30,
                            child: Container(color: Colors.grey[500])),
                        // Option "Déconnexion"
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(); // Ferme le menu
                              ref.read(authProvider.notifier).logout();
                              ref.read(homeProvider.notifier).logout();
                              ref.invalidate(homeProvider);
                              singleton<AppRouter>().replace(const AuthRoute());
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Déconnexion',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1), // Commence hors de l'écran (en haut)
          end: const Offset(0, 0), // Arrive à sa position finale
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}
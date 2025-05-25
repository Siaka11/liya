import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/components/custom_button.dart';
import 'package:liya/core/ui/components/custom_field.dart';
import 'package:liya/modules/auth/info_user_provider.dart';
import '../../core/loading_provider.dart';
import '../../core/ui/theme/theme.dart';

@RoutePage()
class InfoUserPage extends ConsumerStatefulWidget {
  const InfoUserPage({super.key});

  @override
  ConsumerState<InfoUserPage> createState() => _InfoUserPageState();
}

class _InfoUserPageState extends ConsumerState<InfoUserPage> {
  late final TextEditingController nameController;
  late final TextEditingController lastNameController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(infoUserProvider);
    nameController = TextEditingController(text: state.name);
    lastNameController = TextEditingController(text: state.lastName);

    nameController.addListener(() {
      ref.read(infoUserProvider.notifier).updateName(nameController.text.trim());
    });
    lastNameController.addListener(() {
      ref.read(infoUserProvider.notifier).updateLastName(lastNameController.text.trim());
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final infoUserState = ref.watch(infoUserProvider);
    final infoUserNotifier = ref.read(infoUserProvider.notifier);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: UIColors.defaultColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      height: 180,
                      width: 180,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Veuillez saisir vos informations",
                  style: TextStyle(
                    fontSize: 16,
                    color: UIColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  placeholder: "Nom",
                  fontSize: 16,
                  decoration: InputDecoration(
                    errorText: infoUserState.hasError && infoUserState.name.isEmpty
                        ? 'Veuillez entrer votre nom'
                        : null,
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomField(
                  controller: lastNameController,
                  keyboardType: TextInputType.text,
                  placeholder: "Prénom",
                  fontSize: 16,
                  decoration: InputDecoration(
                    errorText: infoUserState.hasError && infoUserState.lastName.isEmpty
                        ? 'Veuillez entrer votre prénom'
                        : null,
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: UIColors.black),
                    ),
                  ),
                ),
              ),
              if (infoUserState.hasError && infoUserState.errorText.isNotEmpty) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    infoUserState.errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomButton(
                      text: "Soumettre",
                      borderRadius: 50,
                      onPressedButton: isLoading ? null : () => infoUserNotifier.submit(context),
                      bgColor: UIColors.white,
                      fontSize: 18,
                      paddingVertical: 16,
                      width: 120,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

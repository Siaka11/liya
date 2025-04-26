

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/auth/otp_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:liya/core/ui/components/custom_button.dart';

@RoutePage()
class OtpPage extends ConsumerWidget{
  final String verificationId;

  const OtpPage(this.verificationId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpState = ref.watch(otpProvider(verificationId));
    final otpNotifier = ref.read(otpProvider(verificationId).notifier);
    // TODO: implement build
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: UIColors.defaultColor,
        ),
        child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:  const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                  ),
                  ]
                ),
                ),
                const SizedBox(height: 10),
                const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Veuillez saisir le code envoyé",
                          style: TextStyle(
                            fontSize: 16,
                            color: UIColors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Nous vous avons envoyé un code de confirmation à votre numéro de téléphone",
                          style: TextStyle(
                            fontSize: 12,
                            color: UIColors.black,
                          ),
                        ),
                      ],
                    ),

                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Pinput(
                        length: 6,
                        autofocus: true,
                        controller: otpNotifier.pinController,
                        onCompleted: (pin) {
                          print("Pin is $pin");
                          otpNotifier.verifyOTP(context);
                        },
                        defaultPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: UIColors.black,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: UIColors.defaultColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: UIColors.black,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: UIColors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        errorPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  ]
                ),
                const SizedBox(height: 10),
                if(otpState.hasError && otpState.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      otpState.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                //add a button to resend the code
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 120,
                      height: 30,
                      child: CustomButton(
                        text: 'Renvoie SMS',
                        onPressedButton: () {  },
                        bgColor: UIColors.orange,
                        fontSize: 10,
                        paddingVertical: 8,
                        borderRaduis: 16,

                      ),
                      /*child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: UIColors.mainColor),
                          ),
                        ),
                        onPressed: () {
                          // add code to resend the code
                        },
                        child: const Text("Renvoyer SMS",
                        style: TextStyle(
                          fontSize: 10,
                          color: UIColors.orange,
                        ),
                        ),
                      ),*/
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
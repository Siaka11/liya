

import 'package:flutter/material.dart';


// colors scheme
class UIColors {
  // static colors
  static const Color primary = Color(0xFF009D4F);
  static const Color primaryDark = Color(0xFF052555);
  static const Color primaryLight = Color(0xFFd9e8ff);
  static const Color secondary = Color(0xFFe20912);
  static const Color accent = Color(0xFFff8400);
  static const Color danger = Color(0xFFe20912);
  static const Color positive = Color(0xFF5FB82C);
  static const Color info = Color(0xFF2ba2e6);
  static const Color warning = Color(0xFFFFC600);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFF2F2F2);
  static const Color lightGrey = Color.fromARGB(255, 174, 173, 173);
  static const Color darkGrey = Color(0xFF787878);
  static const Color none = Colors.transparent;
  static const Color black = Colors.black;
  static const Color borderColor = Colors.black12;
  static const Color defaultColor = Color(0xFFF2F2F4);

  static const Color buttonBG= Color(0xFFedfaf4);
  static const Color buttonBGRed= Color(0xFFfaeded);
  static const Color buttonText= Color(0xFF056b3d);
  static const Color buttonTextRed= Color(0xFFbf082f);
  static const Color lightgreen= Color(0xFF54A92C);


  static const mainColor = Color(0xFFFF9A35);
  static const darker = Color(0xFF3E4249);
  static const cardColor = Colors.white;
  static const appBgColor = Color(0xFFF2F2F4);
  static const appBarColor = Color(0xFFF7F7F7);
  static const bottomBarColor = Colors.white;
  static const inActiveColor = Colors.grey;
  static const shadowColor = Colors.black87;
  static const textBoxColor = Colors.white70;
  static const textColor = Color(0xFF333333);
  static const glassTextColor = Colors.white;
  static const labelColor = Color(0xFF8A8989);
  static const glassLabelColor = Colors.white;
  static const actionColor = Color(0xFFe54140);

  static const Color titleTextColor = Color(0xff1d2635);
  static const Color subTitleTextColor = Color(0xff797878);

  static const Color skyBlue = Color(0xff2890c8);
  static const Color lightBlue = Color(0xff5c3dff);

  static const Color orange = Color(0xffF77030);
  static const Color red = Color(0xffF72804);

  static const Color lightGrey2 = Color(0xffF6F7FA);

  static const Color iconColor = Color(0xffa8a09b);
  static const Color yellowColor = Color(0xfffbba01);

  static const Color lightBlack = Color(0xff5F5F60);

  // light
  static const Color background = Color(0XFFFFFFFF);
  static Color card = Colors.white;
  static Color shadow = Colors.grey;
  // dark
  static const Color backgroundDark = Color(0xFF424242);
  static Color cardDark = const Color(0xFF212121);
  static Color shadowDark = Colors.grey;
  //icon
  static  Color indigoColor = const Color(0xFF3F51B5);
  static  Color greenColor = const Color(0xFF388E3C);
  static  Color orangeColor = const Color(0xfff57c00);
  static  Color darkgreenColor = const Color(0xff5b5b5b);

}

// gradients scheme

class UIGradients {
  // gradients colors
  static const LinearGradient primary = LinearGradient(
    colors: [
      UIColors.accent,
      UIColors.primary,
    ],
    begin: FractionalOffset.centerLeft,
    end: FractionalOffset.centerRight,
  );

  static const LinearGradient secondary = LinearGradient(
    colors: [
      UIColors.darkGrey,
      UIColors.grey,
    ],
    begin: FractionalOffset.centerLeft,
    end: FractionalOffset.centerRight,
  );

  static const LinearGradient positive = LinearGradient(
    colors: [
      UIColors.positive,
      Color.fromARGB(255, 49, 118, 9),
    ],
    begin: FractionalOffset.centerLeft,
    end: FractionalOffset.centerRight,
  );

  static const LinearGradient info = LinearGradient(
    colors: [
      UIColors.info,
      Color.fromARGB(255, 9, 58, 118),
    ],
    begin: FractionalOffset.centerLeft,
    end: FractionalOffset.centerRight,
  );
}

// forms
class UIForms {
  // textfield label

  static Widget textFieldLabel({String name = "Placeholder"}) {
    return Text(
      name,
      style: const TextStyle(
        color: UIColors.primary,
        fontSize: 12,
      ),
    );
  }

  // button style
  static ButtonStyle button({
    Color color = UIColors.white,
    Color background = UIColors.primary,
    Size minimumSize = const Size(50, 40),
    double borderRadius = 50,
  }) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      side: const BorderSide(
        style: BorderStyle.none,
      ),
      /* foregroundColor: color,
      backgroundColor: background,*/
      shadowColor: Colors.transparent,
      minimumSize: minimumSize,
    );
  }

  // textfield style
  static InputDecoration textField({
    Icon? icon,
    Color color = UIColors.primaryLight,
    Color textColor = UIColors.primary,
    String? labelText,
    String? hintText,
    double fontSize = 14,
    dynamic suffixIcon,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(15),
  }) {
    return InputDecoration(
      prefixIcon: icon,
      prefixIconColor: textColor,
      prefixIconConstraints: BoxConstraints.tight(const Size(30, 15)),
      suffixIcon: suffixIcon,
      suffixIconColor: textColor,
      suffixIconConstraints: const BoxConstraints.tightFor(),
      contentPadding: contentPadding,
      isDense: true,
      hoverColor: UIColors.white,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: color,
      filled: true,
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(
        color: textColor,
        fontSize: fontSize,
        decoration: TextDecoration.none,
      ),
      labelStyle: TextStyle(
        color: textColor,
        fontSize: fontSize,
        decoration: TextDecoration.none,
      ),
      errorStyle: const TextStyle(
        color: UIColors.danger,
        fontSize: 12,
        decoration: TextDecoration.none,
      ),
      errorMaxLines: 1,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: UIColors.primary,
          width: 1,
        ),
      ),
    );
  }

  // textfield miltilines style
  static InputDecoration textFieldMultiline({
    Color color = UIColors.primaryLight,
    Color textColor = UIColors.primary,
    bool bordered = false,
    String? labelText,
    String? hintText,
    double fontSize = 14,
    BoxConstraints constraints = const BoxConstraints.expand(),
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(0),
  }) {
    return InputDecoration(
      // prefixIconConstraints: BoxConstraints.tight(Size(30, 15)),
      constraints: constraints,
      contentPadding: contentPadding,
      // isDense: true,
      hoverColor: UIColors.white,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: color,
      filled: true,
      labelText: labelText,
      hintText: hintText,
      alignLabelWithHint: true,
      hintMaxLines: 5,
      hintStyle: TextStyle(
        color: textColor,
        fontSize: fontSize,
        decoration: TextDecoration.none,
      ),
      labelStyle: TextStyle(
        color: textColor,
        fontSize: fontSize,
        decoration: TextDecoration.none,
      ),
      errorStyle: TextStyle(
        color: UIColors.danger,
        fontSize: fontSize,
        decoration: TextDecoration.none,
      ),
      helperStyle: TextStyle(
        color: UIColors.primary,
        fontSize: fontSize,
        decoration: TextDecoration.none,
      ),
      errorMaxLines: 1,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: bordered == true ? UIColors.primary : UIColors.none,
          width: 1,
        ),
      ),
    );
  }

  // dropdown textfield style
  static InputDecoration textFieldDropdown({
    Color color = UIColors.primaryLight,
    String? labelText,
    Color textColor = UIColors.primary,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(10),
  }) {
    return InputDecoration(
      contentPadding: contentPadding,
      isDense: true,
      hoverColor: UIColors.white,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: color,
      filled: true,
      labelText: labelText,
      hintText: labelText,
      hintStyle: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(
        color: UIColors.danger,
        fontSize: 14,
      ),
      errorMaxLines: 1,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: UIColors.primary,
          width: 2,
        ),
      ),
    );
  }
}

// utilities
class UIUtils {
  static BoxShadow boxShadow = const BoxShadow(
    color: Color.fromARGB(19, 0, 0, 0),
    offset: Offset(0, 1),
    blurRadius: 50,
    spreadRadius: 5,
  );
  static double defaultPadding = 10;
  static double doublePadding = defaultPadding * 2;
  static double spacer = 15;

  static SizedBox wSpacer = SizedBox(
    width: spacer,
  );

  static SizedBox hSpacer = SizedBox(
    height: spacer,
  );
}

// utilities
class UIText {
  static TextStyle header(
      double fontSize,
      Color color,
      FontWeight weight,
      ) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
    );
  }

  // Material default
  // caption
  static TextStyle caption(Color color) {
    return TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.normal);
  }

  // body1
  static TextStyle body1(Color color) {
    return TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.normal);
  }

  // body2
  static TextStyle body2(Color color) {
    return TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.normal);
  }

  // subtitle1
  static TextStyle subtitle1(Color color) {
    return TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.normal);
  }

  // subtitle2
  static TextStyle subtitle2(Color color) {
    return TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600);
  }

  // h6
  static TextStyle h6(Color color) {
    return TextStyle(
      fontSize: 20,
      color: color,
      fontWeight: FontWeight.w600,
      height: 1,
    );
  }

  static TextStyle h4(Color color) {
    return TextStyle(
      fontSize: 22,
      color: color,
      fontWeight: FontWeight.w600,
      height: 1,
    );
  }

  static TextStyle h2(Color color) {
    return TextStyle(
      fontSize: 36,
      color: color,
      fontWeight: FontWeight.w600,
      height: 1,
    );
  }
}


MaterialColor LiyaColor = MaterialColor(const Color.fromRGBO(0, 46, 79, 1).value, const <int, Color>{
  50: Color.fromRGBO(0, 157, 79, 0.1),
  100: Color.fromRGBO(0, 157, 79, 0.2),
  200: Color.fromRGBO(0, 157, 79, 0.3),
  300: Color.fromRGBO(0, 157, 79, 0.4),
  400: Color.fromRGBO(0, 157, 79, 0.5),
  500: Color.fromRGBO(0, 157, 79, 0.6),
  600: Color.fromRGBO(0, 157, 79, 0.7),
  700: Color.fromRGBO(0, 157, 79, 0.8),
  800: Color.fromRGBO(0, 157, 79, 0.9),
  900: Color.fromRGBO(0, 157, 79, 1),
},
);

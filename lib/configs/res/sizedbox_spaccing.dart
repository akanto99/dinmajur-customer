import 'package:flutter/material.dart';

class SizedboxSpaccing {
  /// Width-based SizedBox getters
  static SizedBox width01(BuildContext context) =>
      SizedBox(width: MediaQuery.of(context).size.width * 0.01);

  static SizedBox width02(BuildContext context) =>
      SizedBox(width: MediaQuery.of(context).size.width * 0.02);

  static SizedBox width03(BuildContext context) =>
      SizedBox(width: MediaQuery.of(context).size.width * 0.03);




  /// Height-based SizedBox getters
  static SizedBox height005(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.005);

  static SizedBox height01(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.01);
  static SizedBox height012(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.012);


  static SizedBox height015(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.015);
  static SizedBox height017(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.017);

  static SizedBox height02(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.02);
  static SizedBox height025(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.025);

  static SizedBox height03(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.03);
  static SizedBox height035(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.035);

  static SizedBox height04(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.04);
  static SizedBox height042(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.042);
  static SizedBox height045(BuildContext context) =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.045);


///358 px means in MediaQuery MediaQuery.of(context).size.width * 0.9547
///figma designer created design height as 1061px but shuold be standared 844px

}
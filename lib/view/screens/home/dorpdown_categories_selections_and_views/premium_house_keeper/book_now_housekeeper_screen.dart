import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
class BookNowHousekeeperScreen extends StatefulWidget {
  const BookNowHousekeeperScreen({super.key});

  @override
  State<BookNowHousekeeperScreen> createState() => _BookNowHousekeeperScreenState();
}

class _BookNowHousekeeperScreenState extends State<BookNowHousekeeperScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
        children: []);
  }
}
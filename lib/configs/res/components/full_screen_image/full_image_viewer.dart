import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(
          child: ResPonsiveUi(
            mobile: body(),
            desktop: body(),
            tablet: body(),
          ),
        ));
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
        height: screenHeight,
        // color: Colors.white,
        child: Column(
          children: [
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
              ),
              child: Center(
                child: Container(
                  height: 60,
                  width: screenWidth * 0.9,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back_ios_new,color: AppColors.textPrimary(context),size: 22,)
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, RoutesName.navigationBar);
                          },
                          child: Icon(Icons.home,color: AppColors.textPrimary(context),size: 28)
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  height: screenHeight * 0.81,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Hero(
                        tag: 'imageHero',
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:flutter/material.dart';


class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  late TextEditingController supportTextController = TextEditingController();

  @override
  void dispose() {
    supportTextController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 60,
            color: AppColors.containerBackground(context),
            child: Center(child: AppBarHeader("Support")),
          ),
        ),
        SizedboxSpaccing.height025(context),
        Container(
          width: screenWidth*0.9,
          padding: EdgeInsets.all( screenHeight * 0.02,),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              width: 1,
              color: AppColors.border(context),
            ),
          ),

          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Please leave us a message and we will get back to you shortly', style: AppTextStyles.textSize18(context,weight: FontWeight.w500)),
              SizedboxSpaccing.height02(context),
              Container(
                decoration: BoxDecoration(
                  // color: AppColors.textFieldFill(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        width: 1,
                        color: AppColors.border(context)
                    )
                ),
                child: TextFormField(
                  controller: supportTextController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  style:  AppTextStyles.textSize16(context, weight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText:"Input Text Here",
                    hintStyle:  AppTextStyles.textSize16(context,color: AppColors.form_hover(context), weight: FontWeight.w400),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                ),
              ),
              SizedboxSpaccing.height02(context),
              GestureDetector(
                onTap: (){
                  if(supportTextController.text.isEmpty && supportTextController.text==null){
                    Utils.flushBarErrorMessage(
                        "Please drop your message", context);
                  }else{

                  }
                },
                child: Container(
                  width: screenWidth*0.425,
                  height: 50,
                  // width: screenWidth*0.65,
                  decoration: BoxDecoration(
                      color:Color(0xff00424D),
                      // borderRadius: BorderRadius.circular(16)
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Center(child:  Text("Send",style: AppTextStyles.textSize16(context,color: AppColors.whiteColor,weight: FontWeight.w600,),),)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

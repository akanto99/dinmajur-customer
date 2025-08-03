import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {

  final String title ;
  final bool loading ;
  final VoidCallback onPress ;
  final IconData? iconData;
  const RoundButton({Key? key ,
    required this.title,
    this.loading = false ,
    required this.onPress ,
    this.iconData,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return GestureDetector(
      onTap: onPress,
      child: Container(
        // height: screenHeight*0.055,
        height: 50,
        // width: screenWidth*0.65,
        decoration: BoxDecoration(
            color:Color(0xff00424D),
            // borderRadius: BorderRadius.circular(16)
            borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
            child:loading ?Text('Waiting...',style: AppTextStyles.poppins16(context,color: AppColors.whiteColor,weight: FontWeight.w600,),)
                :
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.arrow_forward_ios_rounded,size:16,color:Colors.transparent,),
                Text(title,style: AppTextStyles.poppins16(context,color: AppColors.whiteColor,weight: FontWeight.w600,),),
                if (iconData != null) ...[
                  Icon(iconData, color: Colors.white, size: 16,),
                ],

              ],
            )),
      ),
    );
  }
}



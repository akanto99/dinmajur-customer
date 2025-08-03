import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class DynamicProfileHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;
  final String? profileImage;
  final String? coverImage;

  const DynamicProfileHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onImageTap,
    this.onCameraTap,
    this.profileImage,
    this.coverImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return   Stack(
      children: [
        Container(
          height: 186,
          // color: Colors.red,
          alignment: Alignment.topCenter,
          child: Container(
              height: 132,
              width: screenWidth,
          decoration: BoxDecoration(
              color: AppColors.border(context),
              border: Border.all(
                  width: 1,
                  color: AppColors.border(context)
              ),
              image: DecorationImage(image: NetworkImage(coverImage!),fit: BoxFit.cover)
          ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: screenWidth*0.05,
          child: Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: onImageTap,
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textFieldFill(context),
                          border: Border.all(
                              width: 2,
                              color: AppColors.border(context)
                          )
                      ),

                      child: Center(
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textFieldFill(context),
                              border: Border.all(
                                  width: 1,
                                  color: AppColors.button(context)
                              ),
                            image: DecorationImage(image: NetworkImage(profileImage!),fit: BoxFit.cover)
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 0,
                    child:  GestureDetector(
                      onTap: onCameraTap,
                      child: Container(
                        height: 19,
                        width: 19,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            color: AppColors.border(context)
                        ),
                        child: Icon(Icons.camera_alt,size: 10,),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(''),
                  Text(title,
                    style: AppTextStyles.poppins18(context, weight: FontWeight.w600,)
                  ),

                  Text(subtitle, style:AppTextStyles.poppins14(context,weight: FontWeight.w400)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
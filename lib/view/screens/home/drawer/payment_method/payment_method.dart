import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/validations/authentication_validation/authentication_validation.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view_model/homeview_model/drawer_view_model/payment_method_view_model/account_update_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/drawer_view_model/payment_method_view_model/get_bkash_nagad_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/drawer_view_model/payment_method_view_model/payment_method_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:provider/provider.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  TextEditingController _bikashController = TextEditingController();
  TextEditingController _nogodController = TextEditingController();

  // Add loading states
  bool _isBkashLoading = false;
  bool _isNagadLoading = false;

  // Add edit states
  bool _isBkashEditing = false;
  bool _isNagadEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// FETCH GET ALL PAYMENT DATA
      Provider.of<GetBkashNagadViewModel>(context, listen: false).fetchBkashDataGetApi();
      Provider.of<GetBkashNagadViewModel>(context, listen: false).fetchNagadDataGetApi();
    });
  }

  @override
  void dispose() {
    _bikashController.dispose();
    _nogodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
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
            child: Center(child: AppBarHeader("Payment Method")),
          ),
        ),
        // Center(child: SizedboxSpaccing.height025(context)),
        Expanded(child: SingleChildScrollView(child: addPaymentAccountsWidget())),
      ],
    );
  }

  Widget addPaymentAccountsWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      color: AppColors.containerBackground(context),
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Banking',
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
          ),

          SizedBox(height: screenHeight * 0.015),

          // BKASH SECTION
          Consumer<GetBkashNagadViewModel>(
            builder: (context, value, _) {
              switch (value.bkashData.status) {
                case Status.LOADING:
                  return _IsLoadingCard(
                    context,
                    svgImg: "assets/images/home/drawer/bkash.svg",
                    title: 'Bkash Account',
                    description: 'Your registered Bkash account',
                    button: Color(0xffDB2777),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  );
                case Status.ERROR:
                  return Container(
                    height: 245,
                    color: AppColors.appBackground(context),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          value.fetchBkashDataGetApi();
                        },
                        child: Icon(Icons.restart_alt_outlined, size: 30),
                      ),
                    ),
                  );
                case Status.COMPLETED:
                // Check if Bkash data exists and has accounts
                  if (value.bkashAccountData?.data != null && value.bkashAccountData!.data!.isNotEmpty) {
                    // Show existing Bkash account details or edit form
                    if (_isBkashEditing) {
                      // Show edit form
                      return Consumer<PatchAccountUpdateViewModel>(
                        builder: (context, patchAccountUpdateViewModel, child) {
                          return _buildIsUpdatingMethodCard(
                            context,
                            svgImg: "assets/images/home/drawer/bkash.svg",
                            title: 'Bkash Account',
                            description: 'Update your Bkash mobile number',
                            inputLabel: 'Bkash Number',
                            buttonText: 'Update Bkash Account',
                            controller: _bikashController,
                            button: Color(0xffDB2777),
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isLoading: _isBkashLoading,
                            isEditing: true,
                            onUpdatePressed: () async {
                              // Validate phone number first
                              String? validationError = AuthenticationValidation.validateBangladeshiPhone(_bikashController.text);
                              if (validationError != null) {
                                Utils.flushBarErrorMessage(validationError, context);
                                return;
                              }

                              // Get the actual Bkash account ID
                              String id = value.bkashAccountData!.data!.first.id!;

                              Map<String, dynamic> data = {
                                "accountNumber": _bikashController.text.trim(),
                                "provider":"bkash"
                              };

                              setState(() {
                                _isBkashLoading = true;
                              });

                              try {
                                await patchAccountUpdateViewModel.accountUpdatePatchApi(context, id, data);

                                // On success, refresh data and reset edit state
                                setState(() {
                                  _isBkashEditing = false;
                                  _isBkashLoading = false;
                                });

                                // Refresh the Bkash data
                                Provider.of<GetBkashNagadViewModel>(context, listen: false).fetchBkashDataGetApi();
                              } catch (e) {
                                setState(() {
                                  _isBkashLoading = false;
                                });
                                Utils.flushBarErrorMessage("Failed to update Bkash account. Please try again.", context);
                              }
                            },

                            onCancelEdit: () {
                              setState(() {
                                _isBkashEditing = false;
                                _bikashController.clear();
                              });
                            },
                          );
                        },
                      );
                    } else {
                      // Show existing account details
                      return _ViewPaymentDetails(
                        context,
                        svgImg: "assets/images/home/drawer/bkash.svg",
                        title: 'Bkash Account',
                        description: 'Your registered Bkash account',
                        accountNumber: value.bkashAccountData!.data!.first.accountNumber ?? '',
                        button: Color(0xffDB2777),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onEditPressed: () {
                          setState(() {
                            _isBkashEditing = true;
                            _bikashController.text = value.bkashAccountData!.data!.first.accountNumber ?? '';
                          });
                        },
                        onDeletePressed: () {
                          setState(() {
                            _isBkashEditing = true;
                            _bikashController.text = value.bkashAccountData!.data!.first.accountNumber ?? '';
                          });
                        },
                      );
                    }
                  } else {
                    // Show add Bkash form
                    return Consumer<PostPaymentMethodViewModel>(
                      builder: (context, paymentmethodModel, child) {
                        return _buildMobileBankingCard(
                          context,
                          svgImg: "assets/images/home/drawer/bkash.svg",
                          title: 'Add your Bkash Account',
                          description: 'Add your Bkash mobile number to receive payments',
                          inputLabel: 'Bkash Number',
                          buttonText: 'Add Bkash Account',
                          controller: _bikashController,
                          button: Color(0xffDB2777),
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLoading: _isBkashLoading,
                          isEditing: false,
                          onAddPressed: () async {
                            await _addPaymentMethod(
                              'bkash',
                              _bikashController,
                                  () {
                                setState(() {
                                  _isBkashLoading = !_isBkashLoading;
                                });
                              },
                              paymentmethodModel,
                              value,
                            );
                          },
                          onCancelEdit: () {},
                        );
                      },
                    );
                  }
                default:
                  return SizedBox.shrink();
              }
            },
          ),

          SizedboxSpaccing.height015(context),

          // NAGAD SECTION
          Consumer<GetBkashNagadViewModel>(
            builder: (context, value, _) {
              switch (value.nagadData.status) {
                case Status.LOADING:
                  return _IsLoadingCard(
                    context,
                    svgImg: "assets/images/home/drawer/nagad.svg",
                    title: 'Nagad Account',
                    description: 'Your registered Nagad account',
                    button: Color(0xffEA1D25),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  );
                case Status.ERROR:
                  return Container();
                case Status.COMPLETED:
                // Check if Nagad data exists and has accounts
                  if (value.nagadAccountData?.data != null && value.nagadAccountData!.data!.isNotEmpty) {
                    // Show existing Nagad account details or edit form
                    if (_isNagadEditing) {
                      // Show edit form
                      return Consumer<PatchAccountUpdateViewModel>(
                        builder: (context, patchAccountUpdateViewModel, child) {
                          return _buildIsUpdatingMethodCard(
                            context,
                            svgImg: "assets/images/home/drawer/nagad.svg",
                            title: 'Nagad Account',
                            description: 'Update your Nagad mobile number',
                            inputLabel: 'Nagad Number',
                            buttonText: 'Update Nagad Account',
                            controller: _nogodController,
                            button: Color(0xffEA1D25),
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            isLoading: _isNagadLoading,
                            isEditing: true,
                            onUpdatePressed: () async {
                              // Validate phone number first
                              String? validationError = AuthenticationValidation.validateBangladeshiPhone(_nogodController.text);
                              if (validationError != null) {
                                Utils.flushBarErrorMessage(validationError, context);
                                return;
                              }

                              // Get the actual Nagad account ID
                              String id = value.nagadAccountData!.data!.first.id!;

                              Map<String, dynamic> data = {
                                "accountNumber": _nogodController.text.trim(),
                                "provider":"nagad"
                              };

                              setState(() {
                                _isNagadLoading = true;
                              });

                              try {
                                await patchAccountUpdateViewModel.accountUpdatePatchApi(context, id, data);

                                // On success, refresh data and reset edit state
                                setState(() {
                                  _isNagadEditing = false;
                                  _isNagadLoading = false;
                                });

                                // Refresh the Nagad data
                                Provider.of<GetBkashNagadViewModel>(context, listen: false).fetchNagadDataGetApi();
                              } catch (e) {
                                setState(() {
                                  _isNagadLoading = false;
                                });
                                Utils.flushBarErrorMessage("Failed to update Nagad account. Please try again.", context);
                              }
                            },

                            onCancelEdit: () {
                              setState(() {
                                _isNagadEditing = false;
                                _nogodController.clear();
                              });
                            },
                          );
                        },
                      );
                    } else {
                      // Show existing account details
                      return _ViewPaymentDetails(
                        context,
                        svgImg: "assets/images/home/drawer/nagad.svg",
                        title: 'Nagad Account',
                        description: 'Your registered Nagad account',
                        accountNumber: value.nagadAccountData!.data!.first.accountNumber ?? '',
                        button: Color(0xffEA1D25),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onEditPressed: () {
                          setState(() {
                            _isNagadEditing = true;
                            _nogodController.text = value.nagadAccountData!.data!.first.accountNumber ?? '';
                          });
                        },
                        onDeletePressed: () {
                          setState(() {
                            _isNagadEditing = true;
                            _nogodController.text = value.nagadAccountData!.data!.first.accountNumber ?? '';
                          });
                        },
                      );
                    }
                  } else {
                    // Show add Nagad form
                    return Consumer<PostPaymentMethodViewModel>(
                      builder: (context, paymentmethodModel, child) {
                        return _buildMobileBankingCard(
                          context,
                          svgImg: "assets/images/home/drawer/nagad.svg",
                          title: 'Add your Nagad Account',
                          description: 'Add your Nagad mobile number to receive payments',
                          inputLabel: 'Nagad Number',
                          buttonText: 'Add Nagad Account',
                          controller: _nogodController,
                          button: Color(0xffEA1D25),
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLoading: _isNagadLoading,
                          isEditing: false,
                          onAddPressed: () async {
                            await _addPaymentMethod(
                              'nagad',
                              _nogodController,
                                  () {
                                setState(() {
                                  _isNagadLoading = !_isNagadLoading;
                                });
                              },
                              paymentmethodModel,
                              value,
                            );
                          },
                          onCancelEdit: () {},
                        );
                      },
                    );
                  }
                default:
                  return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper method to add payment method
  Future<void> _addPaymentMethod(
      String provider,
      TextEditingController controller,
      VoidCallback toggleLoading,
      PostPaymentMethodViewModel paymentmethodModel,
      GetBkashNagadViewModel getBkashNagadViewModel,
      ) async {
    // Validate phone number
    String? validationError = AuthenticationValidation.validateBangladeshiPhone(controller.text);

    if (validationError != null) {
      Utils.flushBarErrorMessage(validationError, context);
      return;
    }

    // Set loading state
    toggleLoading();

    try {
      Map<String, dynamic> fields = {"type": "WALLET", "provider": provider, "accountNumber": controller.text};

      await paymentmethodModel.PayementMetheodPostApi(context, fields);

      // Clear the text field and refresh data
      controller.clear();

      // Refresh the appropriate data
      if (provider == 'bkash') {
        getBkashNagadViewModel.fetchBkashDataGetApi();
      } else {
        getBkashNagadViewModel.fetchNagadDataGetApi();
      }

      // Reset loading state on success
      toggleLoading();
    } catch (e) {
      // Handle API error
      toggleLoading();
      Utils.flushBarErrorMessage("Failed to add $provider account. Please try again.", context);
    }
  }

  Widget _buildMobileBankingCard(
      BuildContext context, {
        required String svgImg,
        required String title,
        required String description,
        required String inputLabel,
        required String buttonText,
        required Color button,
        required double screenWidth,
        required double screenHeight,
        required VoidCallback onAddPressed,
        required TextEditingController controller,
        required bool isLoading,
        required bool isEditing,
        required VoidCallback onCancelEdit,
      }) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      color: button,
                      child: SvgPicture.asset(svgImg, color: AppColors.whiteColor),
                    ),
                    SizedboxSpaccing.width03(context),
                    Text(title, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                  ],
                ),
                // Show cancel button only when editing
                if (isEditing)
                  GestureDetector(
                    onTap: onCancelEdit,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text('Cancel', style: AppTextStyles.textSize12(context, weight: FontWeight.w500)),
                    ),
                  ),
              ],
            ),
          ),

          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Column(
              children: [
                Text(description, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                SizedboxSpaccing.height01(context),
                Container(
                  width: screenWidth * 0.8,
                  child: Text(inputLabel, style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                ),
                SizedboxSpaccing.height012(context),
                Container(
                  // width: screenWidth * 0.75,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                  ),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "01XXXXXXXXX",
                      hintStyle: AppTextStyles.textSize16(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),

                SizedboxSpaccing.height015(context),
                GestureDetector(
                  onTap: isLoading ? null : onAddPressed,
                  child: Container(
                    height: 50,
                    // width: screenWidth * 0.75,
                    decoration: BoxDecoration(color: isLoading ? button.withOpacity(0.2) : button, borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: isLoading
                          ? Text(
                        "Waiting",
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                      )
                          : Text(
                        buttonText,
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ViewPaymentDetails(
      BuildContext context, {
        required String svgImg,
        required String title,
        required String description,
        required String accountNumber,
        required Color button,
        required double screenWidth,
        required double screenHeight,
        required VoidCallback onEditPressed,
        required VoidCallback onDeletePressed,
      }) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  color: button,
                  child: SvgPicture.asset(svgImg, color: AppColors.whiteColor),
                ),
                SizedboxSpaccing.width03(context),
                Text(title, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Column(
              children: [
                Text("This number will be used to receive payments.", style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                SizedboxSpaccing.height02(context),

                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                  decoration: BoxDecoration(color: button, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 32),
                            SizedboxSpaccing.width03(context),
                            Text(
                              accountNumber,
                              style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.whiteColor),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onDeletePressed,
                          child: Container(
                            width: 75,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                "Change",
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIsUpdatingMethodCard(
      BuildContext context, {
        required String svgImg,
        required String title,
        required String description,
        required String inputLabel,
        required String buttonText,
        required Color button,
        required double screenWidth,
        required double screenHeight,
        required VoidCallback onUpdatePressed,
        required TextEditingController controller,
        required bool isLoading,
        required bool isEditing,
        required VoidCallback onCancelEdit,
      }) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      color: button,
                      child: SvgPicture.asset(svgImg, color: AppColors.whiteColor),
                    ),
                    SizedboxSpaccing.width03(context),
                    Text(title, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                  ],
                ),

                GestureDetector(
                  onTap: onCancelEdit,
                  child: Container(width: 24, height: 24, child: Icon(Icons.cancel_rounded, color: AppColors.button(context))),
                ),
              ],
            ),
          ),
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Column(
              children: [
                Text(description, style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                SizedboxSpaccing.height02(context),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                  decoration: BoxDecoration(color: button, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 32),
                              SizedboxSpaccing.width03(context),
                              // Wrap TextFormField container with Expanded
                              Expanded(
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.textFieldFill(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(width: 1, color: AppColors.border(context)),
                                  ),
                                  child: TextFormField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      hintText: "01XXXXXXXXX",
                                      hintStyle: AppTextStyles.textSize16(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                                      border: OutlineInputBorder(borderSide: BorderSide.none),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: isLoading ? null : onUpdatePressed,
                          child: Container(
                            width: 75,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                "Update",
                                style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _IsLoadingCard(
      BuildContext context, {
        required String svgImg,
        required String title,
        required String description,
        required Color button,
        required double screenWidth,
        required double screenHeight,
      }) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  color: button,
                  child: SvgPicture.asset(svgImg, color: AppColors.whiteColor),
                ),
                SizedboxSpaccing.width03(context),
                Text(title, style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Column(
              children: [
                Text("This number will be used to receive payments.", style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                SizedboxSpaccing.height02(context),

                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015),
                  decoration: BoxDecoration(color: button, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 45)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

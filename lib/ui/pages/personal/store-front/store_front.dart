import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/customer_profile.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/auth_provider.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/upi_payment_provider.dart';
import 'package:flutter_bzaru/model/upi_payment_model.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/chats/c_chat_screen.dart';
import 'package:flutter_bzaru/ui/pages/personal/proceed-bnb/proceed_bnb.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/product_search_delegate.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/widgets/store_category_listings.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/widgets/store_timings.dart';
import 'package:flutter_bzaru/ui/widgets/cart_icon.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_icon.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:provider/provider.dart';
import 'package:upi_pay/upi_pay.dart';

class StoreFrontPage extends StatefulWidget {
  const StoreFrontPage({Key key, @required this.profileModel})
      : super(key: key);

  final ProfileModel profileModel;

  @override
  _StoreFrontPageState createState() => _StoreFrontPageState();
}

class _StoreFrontPageState extends State<StoreFrontPage> {
  bool lastStatus = true;
  ScrollController _scrollController;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  bool isLanguageEng = true;
  String langCode;
  String _upiAddrError;
  final scaffold = GlobalKey<ScaffoldState>();

  List<ApplicationMeta> _apps;
  TextEditingController _amountController = TextEditingController();

  final _upiAddressController = TextEditingController();

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onTap(ApplicationMeta app) async {
    // final err = _validateUpiAddress(_upiAddressController.text);
    // if (err != null) {
    //   setState(() {
    //     _upiAddrError = err;
    //   });
    //   return;
    // }
    // setState(() {
    //   _upiAddrError = null;
    // });
    // final _amountController = TextEditingController(text: "0");
    //
    // final transactionRef = Random.secure().nextInt(1 << 32).toString();
    // print("Starting transaction with id $transactionRef");
    //
    // final a = await UpiPay.initiateTransaction(
    //   amount: _amountController.text,
    //   app: app.upiApplication,
    //   receiverName: 'Himanshu',
    //   receiverUpiAddress: _upiAddressController.text,
    //   transactionRef: transactionRef,
    //   transactionNote: 'UPI Payment',
    //   // merchantCode: '7372',
    // );
    //
    // print(a);
  }

  // String _validateUpiAddress(String value) {
  //   if (value.isEmpty) {
  //     return 'UPI VPA is required.';
  //   }
  //   if (value.split('@').length != 2) {
  //     return 'Invalid UPI VPA';
  //   }
  //   return null;
  // }

  @override
  void initState() {
    _isLoading.value = true;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    getLocale();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lang = await SharedPrefrenceHelper().getLanguageCode();
      isLanguageEng = lang == "hi" ? false : true;
      getStoreTimings();
      getChatWithStore();
      getAllMerhcantProducts();

      setState(() async {
        _apps = await UpiPay.getInstalledUpiApplications(
            statusType: UpiApplicationDiscoveryAppStatusType.all);
      });
    });
    super.initState();

    _amountController.text = "0";

    // we have used sample UPI address (will be used to receive amount)
    _upiAddressController.text = '8505957287@ybl';
  }

  void getLocale() async {
    langCode = await SharedPrefrenceHelper().getLanguageCode();
    print(langCode);
    if (langCode == null) {
      return;
    }
  }

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (240 - kToolbarHeight);
  }

  Future<void> getAllMerhcantProducts() async {
    final state = Provider.of<CStoreState>(context, listen: false);
    await state.getSubCategories(widget.profileModel);
    await state.getMerchantProductList(widget.profileModel.id);
    _isLoading.value = false;
  }

  Future<void> getStoreTimings() async {
    Provider.of<CStoreState>(context, listen: false)
        .getStoreTimings(widget.profileModel.id);
  }

  Future<void> getChatWithStore() async {
    Provider.of<CStoreState>(context, listen: false)
        .getChatWithStore(widget.profileModel.id);
  }

  Widget _buildCoverImage() {
    final locale = AppLocalizations.of(context);
    return Stack(
      children: [
        customNetworkImage(
          widget.profileModel.coverImage,
          height: 250,
          fit: BoxFit.cover,
          width: double.infinity,
          defaultHolder: Container(),
        ),
        Align(
          alignment: Alignment.center,
          child: customNetworkImage(
            widget.profileModel.avatar,
            fit: BoxFit.cover,
            height: 100,
            width: 100,
          ),
        ),
        Consumer<CStoreState>(
          builder: (context, state, child) => Positioned(
            bottom: 5.0,
            left: 20.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                showSearch(
                    context: context,
                    delegate: ProductSearchDelegate(
                      searchField: isLanguageEng
                          ? "${locale.getTranslatedValue(KeyConstants.searchIn)} ${widget.profileModel.name}"
                          : "${widget.profileModel.name} ${locale.getTranslatedValue(KeyConstants.searchIn)}",
                      listOfProducts: state.listOfProducts,
                    ));
              },
              child: FittedBox(
                child: Container(
                  height: 50,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 23,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 5.0),
                      Flexible(
                        child: BText(
                          isLanguageEng
                              ? "${locale.getTranslatedValue(KeyConstants.searchIn)} ${widget.profileModel.name}"
                              : "${widget.profileModel.name} ${locale.getTranslatedValue(KeyConstants.searchIn)}",
                          variant: TypographyVariant.h2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffF3F5F3),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            height: kToolbarHeight,
            color: widget.profileModel.coverImage != null
                ? Colors.black38
                : Colors.transparent,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      key: scaffold,
      bottomNavigationBar: ProceedBNB(),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              elevation: 0.0,
              automaticallyImplyLeading: false,
              title: BText(
                widget.profileModel.name?.capitalize(),
                variant: TypographyVariant.title,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              centerTitle: true,
              pinned: true,
              stretch: true,
              flexibleSpace: isShrink ? Container() : _buildCoverImage(),
              expandedHeight: 250,
              actions: [
                CartIcon().pH(5),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 60),
                child: ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) => isLoading
                      ? OverlayLoading(
                          showLoader: _isLoading,
                          bgScreenColor: Colors.white,
                          loadingMessage: locale.getTranslatedValue(
                              KeyConstants.lookingIntoStore),
                        )
                      : Consumer<CStoreState>(
                          builder: (context, state, child) {
                            return state.displayProductList != null &&
                                    state.displayProductList.isNotEmpty
                                ? Column(
                                    children: [
                                      SizedBox(height: 20),
                                      _buildStoreDetails(),
                                      SizedBox(height: 20),
                                      ...state.categories.map(
                                        (CategoryModel categoryModel) {
                                          final listOfProducts =
                                              state.divideCategoricalList(
                                                  categoryModel.category);
                                          if (listOfProducts != null &&
                                              listOfProducts.isNotEmpty) {
                                            return StoreCategoryListings(
                                              categoryModel: categoryModel,
                                              listOfProducts: listOfProducts,
                                              langCode: langCode,
                                            );
                                          } else {
                                            return SizedBox();
                                          }
                                        },
                                      ).toList()
                                    ],
                                  )
                                : Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    child: Center(
                                      child: BText(
                                        "${locale.getTranslatedValue(KeyConstants.noItemsFound)} :(",
                                        variant: TypographyVariant.titleSmall,
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                ),
              ).pH(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreDetails() {
    final storeProfile = widget.profileModel;
    final myProfile = Provider.of<ProfileState>(context, listen: false).customerProfileModel;

    //final upiPayment =

    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider<ProfileState>(create: (_) => ),
    //     ChangeNotifierProvider<UpiPaymentProvider>(create: (context) => Provider<UpiPaymentProvider>()),
    //   ],
    //   child:
      return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              BText(
                storeProfile.name?.capitalize(),
                variant: TypographyVariant.h1,
              ),
              SizedBox(height: 5),
              BText(
                storeProfile.description?.capitalize(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                variant: TypographyVariant.h3,
              ),
              SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.location_pin,
                      size: 20, color: KColors.customerPrimaryColor),
                  Expanded(
                    child: BText(
                     storeProfile.address1==null?"NA": "${storeProfile.address1}, ${storeProfile.address2}, ${storeProfile.city}, ${storeProfile.state} ${storeProfile.pinCode}",
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      variant: TypographyVariant.h3,
                    ),
                  ),
                ],
              ),
              if (_upiAddrError != null)
                Container(
                  margin: EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    _upiAddrError,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              //
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(context: scaffold.currentContext,
                    //isScrollControlled: true,
                    builder: (context){

                    return Wrap(
                      children: [
                        Container(
                            color: Colors.transparent,
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
                            // ),
                            padding: EdgeInsets.only(top: 36,bottom: 18),
                            child: Column(
                              children: [
                                GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: _apps.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: 2,
                                        crossAxisCount: 3),
                                    itemBuilder: (context, index){
                                      return GestureDetector(
                                          onTap: (){
                                            if(_apps.length!=0){
                                              UpiPaymentProvider upiPayment = UpiPaymentProvider();
                                              upiPayment.paymentDetails = UpiPaymentModel(
                                                app: _apps[index].upiApplication,
                                                amount: 10,
                                                receiverName: "Himanshu",
                                                receiverUpiAddress: '8505957287@ybl',
                                                transactionRef: Random.secure().nextInt(1 << 32).toString(),
                                              );
                                              upiPayment.makePayment();
                                            }else{
                                              print("No UPI gateway found");
                                            }
                                          },
                                          child:  SizedBox(height: 60,
                                            width: 60,
                                            child: Column(
                                              children: [
                                                _apps[index].iconImage(42),

                                                //Icon(Icons.add),
                                                Text(_apps[index].upiApplication.appName),
                                              ],
                                            ),
                                          )
                                      );
                                    }),
                                Padding(padding: EdgeInsets.only(left: 12,right: 12, top: 8),
                                  child: MaterialButton(onPressed: () {  },
                                    child: Text("Cancel"),
                                    color:  Colors.white70,
                                    minWidth: double.infinity,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    );
                  },
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(8))
                    ),
                    elevation: 72,
                  );


                },
                child: Container(
                  child: Row(children: [Icon(Icons.money), Text('UPI Pay')]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BIcon(
                    iconData: Icons.phone,
                    color: KColors.customerPrimaryColor,
                    alignment: Alignment.topCenter,
                    onTap: () async {
                      await Provider.of<CStoreState>(context, listen: false)
                          .launchCaller(storeProfile.contactPrimary);
                    },
                  ),
                  SizedBox(width: 10),
                  Consumer<CStoreState>(
                    builder: (context, state, child) => BIcon(
                      iconData: Icons.chat,
                      alignment: Alignment.topCenter,
                      color: KColors.customerPrimaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          CChatScreen.getRoute(
                              null,
                              state.lastChatMessage?.receiverId != null
                                  ? state.lastChatMessage.receiverId
                                  : ChatMessage(
                                senderId: myProfile.id,
                                receiverId: storeProfile.id,
                                receiverImage: storeProfile.avatar,
                                receiverName: storeProfile.name,
                                senderName: myProfile.name,
                              )
    ),
                        ); //Passing null Chat Message Model
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              StoreTimings()
            ],
          ),
        ),
      ],
    ).pH(10);
  }
}


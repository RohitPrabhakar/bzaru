import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/auth_provider.dart';
import 'package:flutter_bzaru/providers/business/product_provider.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/size_drop_down.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/sub_categories_drop.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/painting/basic_types.dart' as basic;
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  static CupertinoPageRoute getRoute() {
    return CupertinoPageRoute(
      builder: (_) => AddProductScreen(),
    );
  }

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  ///with [Add Icon] & [pickedImage] is the image coming fromthe `list` [productImages]
  ///`Function` that allows to `pick` a `image`
  ///and show it in `box`. [isAddImage] is a [boolean] which drives the `Container`

  ValueNotifier<bool> inStock = ValueNotifier<bool>(true);
  ValueNotifier<bool> isAdding = ValueNotifier<bool>(false);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  String langCode;
  int maxProductsImages;
  List<File> productImages = [];
  ProductSize productSize;
  String size;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  TextEditingController _descriptionController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;
  TextEditingController _mrpController;
  TextEditingController _priceController;
  TextEditingController _productnameController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CategoryModel _selectedCategory = CategoryModel();
  TextEditingController _synonymController;

  @override
  void didChangeDependencies() {
    getProductImageLength();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _productnameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _synonymController.dispose();
    _mrpController.dispose();
    _connectivitySubscription.cancel();
    inStock.dispose();
  }

  @override
  void initState() {
    _productnameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _synonymController = TextEditingController();
    _mrpController = TextEditingController();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    super.initState();
  }

  void getProductImageLength() {
    final profile = Provider.of<ProfileState>(context).merchantProfileModel;
    maxProductsImages = profile.maxProductImages ?? 4;
  }

  Future<String> getLocale() async {
    final response = await SharedPrefrenceHelper().getLanguageCode();
    return Future.value(response);
  }

  ///`Pick Image` from `Gallery`
  Future<void> pickFromGallery(int index) async {
    final picker = ImagePicker();
    final image = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setSelectedImage(image, index);
  }

  void setSelectedImage(PickedFile image, int index) {
    setState(() {
      _image = File(image.path);
      if (productImages.isEmpty) {
        productImages.add(_image);
      } else {
        final model = index < productImages.length
            ? productImages.elementAt(index)
            : null;
        if (model != null) {
          productImages[index] = _image;
        } else {
          productImages.add(_image);
        }
      }
    });
  }

  ///`ADDING PRODUCTS`
  Future<void> addProduct() async {
    final locale = AppLocalizations.of(context);
    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      if (Utility.connectionCode == 0) {
        Utility.displaySnackbar(
          context,
          key: _scaffoldKey,
          msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
        );
      }
    }
    _formKey.currentState.save();
    bool isValidated = _formKey.currentState.validate();

    final merchantId = await SharedPrefrenceHelper().getAccessToken();

    if (isValidated) {
      if (_selectedCategory.category == "select a category" ||
          _selectedCategory.category.isEmpty) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
              locale.getTranslatedValue(KeyConstants.pleaseSelectCategory)),
        ));
        return;
      }
      final state = Provider.of<ProductProvider>(context, listen: false);
      final profile = Provider.of<ProfileState>(context, listen: false)
          .merchantProfileModel;

      isAdding.value = true;
      isLoading.value = true;
      ProductModel productModel = ProductModel(
        title: _productnameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text),
        productSize: productSize,
        size: size,
        merchantId: merchantId,
        mainCategory: profile.categoryOfBusiness,
        subCategory: _selectedCategory.category,
        inStock: inStock.value,
        productSnyonmys: List.from(state.synonymsList),
        mrp: double.tryParse(_mrpController.text),
      );

      /// `upload Product Image to firebase storage`
      if (productImages != null && productImages.isNotEmpty) {
        List<String> tempImages = [];

        for (File image in productImages) {
          String imageUrl;
          print("IMAGE");
          imageUrl = await state.uploadProductImage(image);
          tempImages.add(imageUrl);
        }
        productModel.imageUrl = tempImages;
      }

      await state.addNewProduct(productModel);
      await Provider.of<AuthState>(context, listen: false)
          .addCollectionListener();

      Provider.of<ProductProvider>(context, listen: false).clearSearchedList();
      await state.getMerchantProductList();
      Navigator.of(context).pop();

      isLoading.value = false;
      isAdding.value = false;
    }
  }

  ///`Method` that lets the user to `upload` image
  ///from the `Gallery`.
  Widget _buildUploadImage() {
    if (productImages.isEmpty) {
      return _imageBox(true, null, 0);
    } else {
      return Container(
        height: 100,
        child: ListView.builder(
          itemCount: productImages.isEmpty
              ? 1
              : productImages.length >= maxProductsImages
                  ? maxProductsImages
                  : productImages.length + 1,
          scrollDirection: basic.Axis.horizontal,
          itemBuilder: (context, index) {
            if (productImages.length >= maxProductsImages) {
              return _imageBox(false, productImages[index], index);
            } else {
              if (index == productImages.length) {
                return _imageBox(true, null, index);
              } else {
                return _imageBox(false, productImages[index], index);
              }
            }
          },
        ),
      );
    }
  }

  Widget _imageBox(bool isAddImage, File pickedImage, int index) {
    return Container(
      height: 100,
      width: 100,
      margin: EdgeInsets.fromLTRB(
          0, 0, index == productImages.length ? 0 : 10.0, 0),
      decoration: BoxDecoration(
        border: Border.all(color: KColors.businessPrimaryColor),
        color: Colors.white,
      ),
      child: isAddImage
          ? Icon(
              Icons.add,
              size: 60,
              color: KColors.businessPrimaryColor,
            )
          : Image.file(
              pickedImage,
              fit: BoxFit.cover,
            ),
    ).ripple(() async {
      await pickFromGallery(index);
    });
  }

  ///Building `Custom Text Field` for `Price` & `Quantity`
  Widget _buildCustomTextField(
    String label,
    TextEditingController controller,
    String hintText,
    TextInputAction textInputAction,
    TextInputType textInputType,
  ) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        BText(
          label ?? "",
          style: KStyles.labelTextStyle,
          variant: TypographyVariant.h1,
        ),
        SizedBox(height: 10),
        Container(
          height: 70,
          // width: 140,
          child: TextFormField(
            autocorrect: false,
            keyboardType: textInputType,
            controller: controller ?? TextEditingController(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: KStyles.hintTextStyle,
              helperText: "",
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: KColors.businessPrimaryColor,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: KColors.businessPrimaryColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.5,
                  color: KColors.businessPrimaryColor,
                ),
              ),
            ),
            style: KStyles.fieldTextStyle,
            textInputAction: textInputAction ?? TextInputAction.next,
            validator: (String value) {
              if (value.isEmpty) {
                return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
              }
              if (RegExp(r'^(?!0*\.0+$)\d*(?:\.\d+)?$').hasMatch(value)) {
                return null;
              } else {
                return locale
                    .getTranslatedValue(KeyConstants.enterAValidAmount);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategory(String lang) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          locale.getTranslatedValue(KeyConstants.category),
          style: KStyles.labelTextStyle,
          variant: TypographyVariant.h1,
        ),
        SizedBox(height: 10),
        SubCategoryDropDown(
          onSelectedCategory: (value) => _selectedCategory = value,
          langCode: lang,
        ),
      ],
    );
  }

  Widget _buildSize() {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          locale.getTranslatedValue(KeyConstants.size),
          style: KStyles.labelTextStyle,
          variant: TypographyVariant.h1,
        ),
        SizedBox(height: 10),
        SizeDropDown(
          scaffoldKey: _scaffoldKey,
          productSize: (value) {
            productSize = value;
          },
          size: (value) {
            if (value.isNotEmpty) size = value;
          },
        ),
      ],
    );
  }

  Widget _buildInStockRow() {
    final locale = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          locale.getTranslatedValue(KeyConstants.inStock),
          style: KStyles.h2.copyWith(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        ValueListenableBuilder(
          valueListenable: inStock,
          builder: (context, value, _) => Switch(
            value: value,
            activeColor: KColors.businessPrimaryColor,
            onChanged: (val) {
              inStock.value = val;
            },
          ),
        ),
      ],
    );
  }

  void clearTextField() {
    print("CLEAR");
    _synonymController.clear();
  }

  Widget _buildSynonyms() {
    final locale = AppLocalizations.of(context);

    return Consumer<ProductProvider>(
      builder: (context, state, child) => Column(
        children: [
          Container(
            child: state.synonymsList != null && state.synonymsList.isNotEmpty
                ? GridView(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3.0,
                      crossAxisSpacing: 10,
                    ),
                    children: state.synonymsList
                        .map((text) => Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: BText(
                                      text,
                                      variant: TypographyVariant.h3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        state.removeWordFromSynonymList(text);
                                      },
                                      child: Icon(Icons.clear),
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  )
                : SizedBox(),
          ),
          SizedBox(height: 10),
          child,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BText(
            locale.getTranslatedValue(KeyConstants.productSynonym),
            style: KStyles.labelTextStyle,
            variant: TypographyVariant.h1,
          ),
          SizedBox(height: 10),
          Container(
            height: 70,
            // width: 140,
            child: TextField(
              autocorrect: false,
              keyboardType: TextInputType.name,
              controller: _synonymController,
              decoration: InputDecoration(
                helperText: "",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: KColors.businessPrimaryColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: KColors.businessPrimaryColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: KColors.businessPrimaryColor,
                  ),
                ),
              ),
              style: KStyles.fieldTextStyle,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                print(value);
                if (_synonymController.text.length > 2 &&
                    value.characters.last == ",") {
                  final state =
                      Provider.of<ProductProvider>(context, listen: false);
                  state.addWordToSynonymList(
                    _synonymController.text
                        .toLowerCase()
                        .replaceAll(",", "")
                        .trim(),
                  );

                  clearTextField();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        final state = Provider.of<ProductProvider>(context, listen: false);
        state.clearSynonymsList();
        Navigator.of(context).pop();
        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: KColors.bgColor,
        appBar: BAppBar(
          title: locale.getTranslatedValue(KeyConstants.addProduct),
          onPressed: () {
            final state = Provider.of<ProductProvider>(context, listen: false);
            state.clearSynonymsList();
            Navigator.of(context).pop();
          },
        ),
        body: FutureBuilder(
          future: getLocale(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          _buildUploadImage(),
                          SizedBox(height: 40),
                          _buildInStockRow(),
                          BTextField(
                            choice: Labels.text,
                            controller: _productnameController,
                            label: locale
                                .getTranslatedValue(KeyConstants.productName),
                          ),
                          SizedBox(height: 5.0),
                          _buildCategory(snapshot.data),
                          SizedBox(height: 20.0),
                          BTextField(
                            choice: Labels.text,
                            controller: _descriptionController,
                            label: locale
                                .getTranslatedValue(KeyConstants.description),
                            maxLines: 3,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          SizedBox(height: 5.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildSize()),
                              SizedBox(width: 25),
                              Expanded(
                                child: _buildCustomTextField(
                                  locale.getTranslatedValue(KeyConstants.price),
                                  _priceController,
                                  "₹ 0.00",
                                  TextInputAction.next,
                                  TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          _buildCustomTextField(
                            locale.getTranslatedValue(KeyConstants.mrpText),
                            _mrpController,
                            "₹ 0.00",
                            TextInputAction.next,
                            TextInputType.number,
                          ),
                          SizedBox(height: 20),
                          _buildSynonyms(),
                          SizedBox(height: 40),
                          BFlatButton(
                            text: locale
                                .getTranslatedValue(KeyConstants.addProduct),
                            isWraped: true,
                            isBold: true,
                            color: KColors.businessPrimaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            onPressed: addProduct,
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ).pH(20),
                  ),
                  ValueListenableBuilder(
                    valueListenable: isAdding,
                    builder: (context, value, child) => OverlayLoading(
                      showLoader: isLoading,
                      // bgScreenColor: Colors.white,
                      loadingMessage: value
                          ? "${locale.getTranslatedValue(KeyConstants.addingProduct)}..."
                          : "",
                    ),
                  )
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/basic_types.dart' as basic;
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/providers/business/product_provider.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/size_drop_down.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/sub_categories_drop.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key key, @required this.productModel})
      : super(key: key);

  final ProductModel productModel;

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  ///with [Add Icon] & [pickedImage] is the image coming fromthe `list` [productImages]
  ///`Function` that allows to `pick` a `image`
  ///and show it in `box`. [isAddImage] is a [boolean] which drives the `Container`

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isSave = ValueNotifier<bool>(true);
  ValueNotifier<bool> isSetting = ValueNotifier<bool>(true);
  ValueNotifier<bool> inStock;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  CategoryModel _selectedCategory = CategoryModel();

  List<File> productImages = [];

  TextEditingController _descriptionController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;
  TextEditingController _priceController;
  TextEditingController _productnameController;
  TextEditingController _synonymController;
  TextEditingController _mrpController;
  ProductSize productSize;
  String size;
  int maxProductsImages;
  bool didChangedDepRan = true;

  @override
  void dispose() {
    super.dispose();
    _productnameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _connectivitySubscription.cancel();
    _synonymController.dispose();
    isSetting.dispose();
    isSave.dispose();
    isLoading.dispose();
    inStock.dispose();
    _mrpController.dispose();
  }

  @override
  void initState() {
    super.initState();
    initalize();
  }

  void initalize() {
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    _productnameController =
        TextEditingController(text: widget.productModel.title);
    _descriptionController =
        TextEditingController(text: widget.productModel.description);
    size = widget.productModel.size;
    productSize = widget.productModel.productSize;
    _priceController =
        TextEditingController(text: widget.productModel.price.toString());
    _selectedCategory = _selectedCategory;
    inStock = ValueNotifier<bool>(widget.productModel.inStock ?? true);
    _synonymController = TextEditingController();
    _mrpController = TextEditingController(
        text: widget.productModel.mrp != null
            ? widget.productModel.mrp.toString()
            : "0.0");

    final prodImageFromDB = widget.productModel.imageUrl != null
        ? widget.productModel.imageUrl
        : []; //!PASSING EMPTY LIST
    prodImageFromDB.forEach((element) {
      items.add(element);
    });
    if (productImages.isNotEmpty) {
      productImages.forEach((element) {
        items.add(element);
      });
    }
  }

  @override
  void didChangeDependencies() {
    getProductImageLength();
    super.didChangeDependencies();
  }

  void getProductImageLength() {
    if (didChangedDepRan) {
      final profile = Provider.of<ProfileState>(context).merchantProfileModel;
      maxProductsImages = profile.maxProductImages ?? 4;
      Provider.of<ProductProvider>(context)
          .setSynonymList(widget.productModel.productSnyonmys);
      didChangedDepRan = false;
      isSetting.value = false;
    }
  }

  Future<String> getLocale() async {
    final response = await SharedPrefrenceHelper().getLanguageCode();
    return Future.value(response);
  }

  ///`Pick Image` from `Gallery`
  Future<void> pickFromGallery(int index) async {
    print("FR INDEX $index");
    print("ITEMS IMAGE LEN ${items.length}");

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
      if (items.isEmpty) {
        items.add(_image);
      } else {
        final model = index < items.length ? items.elementAt(index) : null;
        if (model != null) {
          print("MODEL NOT NULL");
          items.removeAt(index);
          if (items != null && items.isNotEmpty) {
            items.insert(index, _image);
          } else {
            items.add(_image);
          }
        } else {
          print("MODEL NULL");
          items.add(_image);
        }
      }
    });
  }

  Future<void> updateProduct() async {
    final locale = AppLocalizations.of(context);

    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      _formKey.currentState.save();
      isSave.value = true;

      final merchantId = await SharedPrefrenceHelper().getAccessToken();
      bool isValidated = _formKey.currentState.validate();

      if (isValidated) {
        final state = Provider.of<ProductProvider>(context, listen: false);
        isLoading.value = true;

        ProductModel productModel = ProductModel(
          title: _productnameController.text,
          description: _descriptionController.text,
          price: double.tryParse(_priceController.text),
          productSize: productSize,
          size: size,
          merchantId: merchantId,
          id: widget.productModel.id,
          isDeleted: false,
          subCategory: _selectedCategory.category,
          inStock: inStock.value,
          productSnyonmys: state.synonymsList,
          mrp: double.tryParse(_mrpController.text),
        );

        /// `upload Product Image to firebase storage`
        if (items != null && items.isNotEmpty) {
          print("ITEMS NOT NULL>>>");
          print(items);
          List<String> tempImages = [];

          items.forEach((element) {
            print(element.runtimeType);
            if (element.runtimeType == String) {
              print("hey");
              tempImages.add(element);
            }
          });

          for (var image in items) {
            if (image.runtimeType != String) {
              String imageUrl;
              print("IMAGE");
              imageUrl = await state.uploadProductImage(image);
              tempImages.add(imageUrl);
            }
          }
          print("LEN: ${tempImages.length}");
          productModel.imageUrl = List.from(tempImages);
        } else {
          print("Here");
          if (widget.productModel.imageUrl != null &&
              widget.productModel.imageUrl.isNotEmpty) {
            productModel.imageUrl = List.from(widget.productModel.imageUrl);
          }
        }

        await state.updateProduct(productModel);
        await state.getMerchantProductList();
        Provider.of<ProductProvider>(context, listen: false)
            .clearSearchedList();
        Navigator.pop(context);
        state.clearSynonymsList();
        isLoading.value = false;
      }
    }
  }

  ///`DELETING PRODCUT`
  Future<void> deleteProduct() async {
    final locale = AppLocalizations.of(context);
    if (Utility.connectionCode == 0) {
      Navigator.of(context).pop();
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      isSave.value = false;

      final merchantId = await SharedPrefrenceHelper().getAccessToken();
      final state = Provider.of<ProductProvider>(context, listen: false);
      Navigator.of(context).pop();

      isLoading.value = true;

      ProductModel productModel = ProductModel(
        title: _productnameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text),
        productSize: productSize,
        size: size,
        merchantId: merchantId,
        id: widget.productModel.id,
        isDeleted: true,
      );

      Provider.of<ProductProvider>(context, listen: false).clearSearchedList();
      await state.deleteMerchantProduct(productModel);
      await state.getMerchantProductList();
      Navigator.pop(context);
      state.clearSynonymsList();
      isLoading.value = false;
    }
  }

  List<dynamic> items = [];

  ///`Method` that lets the user to `upload` image
  ///from the `Gallery`.
  Widget _buildUploadImage() {
    // if (prodImageFromDB.isEmpty && productImages.isEmpty) {
    //   return _imageBox(true, null, null, 0);
    // } else {
    //   if (prodImageFromDB.isNotEmpty) {
    //     //THERE ARE IMAGES IN DB
    //     int index = 0;
    //     prodImageFromDB.forEach((element) {
    //       items.add(_imageBox(false, null, element, index));
    //     });
    //     if (productImages.isNotEmpty) {
    //       productImages.forEach((element) {
    //         items.add(_imageBox(false, element, null, index));
    //       });
    //     }

    //     return Container(
    //       height: 100,
    //       child: ListView.builder(
    //         itemCount: prodImageFromDB.length >= maxProductsImages
    //             ? maxProductsImages
    //             : prodImageFromDB.length + 1,
    //         scrollDirection: basic.Axis.horizontal,
    //         itemBuilder: (context, index) {
    //           if (prodImageFromDB.length >= maxProductsImages) {
    //             return _imageBox(false, null, prodImageFromDB[index], index);
    //           } else {
    //             if (index == prodImageFromDB.length) {
    //               return _imageBox(true, null, null, index);
    //             } else {
    //               return _imageBox(false, null, prodImageFromDB[index], index);
    //             }
    //           }
    //         },
    //       ),
    //     );
    //   } else {
    //FROM FILES
    return Container(
      height: 100,
      child: ListView.builder(
        itemCount: items.isEmpty
            ? 1
            : items.length >= maxProductsImages
                ? maxProductsImages
                : items.length + 1,
        scrollDirection: basic.Axis.horizontal,
        itemBuilder: (context, index) {
          if (items.length >= maxProductsImages) {
            if (items[index].runtimeType == String)
              return _imageBox(false, null, items[index], index);
            else
              return _imageBox(false, items[index], null, index);
          } else {
            if (index == items.length) {
              return _imageBox(true, null, null, index);
            } else {
              if (items[index].runtimeType == String)
                return _imageBox(false, null, items[index], index);
              else
                return _imageBox(false, items[index], null, index);
            }
          }
        },
      ),
    );
    // }
  }

  Widget _imageBox(
      bool isAddImage, File pickedImage, String prodImageUrl, int index) {
    print("INDX FROM IMAGE BOX $index");
    return pickedImage != null
        ? Container(
            height: 100,
            width: 100,
            margin: EdgeInsets.symmetric(horizontal: 10.0),
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
          })
        : Container(
            height: 100,
            width: 100,
            margin: EdgeInsets.symmetric(horizontal: 10.0),
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
                : customNetworkImage(
                    prodImageUrl,
                    placeholder: BPlaceHolder(),
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
              }),
        ),
      ],
    );
  }

  Widget _buildCategory(String langCode) {
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
          preDefinedCategory: widget.productModel.subCategory,
          langCode: langCode,
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
          predefinedSize: size,
          predefinedProductSize: productSize,
        ),
      ],
    );
  }

  void showDeleteDailog() {
    final locale = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: BText(
          locale.getTranslatedValue(KeyConstants.areYouSureDelete),
          variant: TypographyVariant.h2,
        ),
        actions: [
          Row(
            children: [
              BFlatButton(
                text: locale.getTranslatedValue(KeyConstants.delete),
                onPressed: deleteProduct,
                isWraped: true,
                color: KColors.redColor,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
              ),
              SizedBox(width: 20),
              BFlatButton(
                text: locale.getTranslatedValue(KeyConstants.cancel),
                onPressed: () => Navigator.of(context).pop(),
                isWraped: true,
                color: KColors.businessPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        final state = Provider.of<ProductProvider>(context, listen: false);
        state.clearSynonymsList();
        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: KColors.bgColor,
        appBar: BAppBar(
          title: locale.getTranslatedValue(KeyConstants.editProduct),
          onPressed: () {
            Navigator.of(context).pop();
            final state = Provider.of<ProductProvider>(context, listen: false);
            state.clearSynonymsList();
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
                                  flex: 1,
                                  child: _buildCustomTextField(
                                    locale
                                        .getTranslatedValue(KeyConstants.price),
                                    _priceController,
                                    "₹ 0.00",
                                    TextInputAction.done,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BFlatButton(
                                  text: locale
                                      .getTranslatedValue(KeyConstants.delete),
                                  isWraped: true,
                                  isBold: true,
                                  color: KColors.redColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 35.0,
                                    vertical: 10.0,
                                  ),
                                  onPressed: () {
                                    showDeleteDailog();
                                  },
                                ),
                                BFlatButton(
                                    text: locale
                                        .getTranslatedValue(KeyConstants.save),
                                    isWraped: true,
                                    isBold: true,
                                    color: KColors.businessPrimaryColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 40.0,
                                      vertical: 10.0,
                                    ),
                                    onPressed: updateProduct),
                              ],
                            ),
                            SizedBox(height: 40),
                          ],
                        ),
                      ).pH(20),
                    ),
                    ValueListenableBuilder(
                      valueListenable: isSetting,
                      builder: (context, isSettingFirst, child) =>
                          ValueListenableBuilder(
                        valueListenable: isSave,
                        builder: (context, save, _) {
                          return OverlayLoading(
                            showLoader: isLoading,
                            loadingMessage: isSettingFirst
                                ? "${locale.getTranslatedValue(KeyConstants.loadingProducts)}..."
                                : save
                                    ? "${locale.getTranslatedValue(KeyConstants.savingProduct)}..."
                                    : "${locale.getTranslatedValue(KeyConstants.deletingProduct)}...",
                          );
                        },
                      ),
                    )
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
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
                                        print("TEXT: $text");
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
}

import 'dart:io';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../services/http_services.dart';
import '../../../models/product.dart';

class DashBoardProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addProductFormKey = GlobalKey<FormState>();

  //?text editing controllers in dashBoard screen
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescCtrl = TextEditingController();
  TextEditingController productQntCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productOffPriceCtrl = TextEditingController();

  //? dropdown value
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Brand? selectedBrand;
  VariantType? selectedVariantType;
  List<String> selectedVariants = [];

  Product? productForUpdate;
  File? selectedMainImage,
      selectedSecondImage,
      selectedThirdImage,
      selectedFourthImage,
      selectedFifthImage;
  XFile? mainImgXFile,
      secondImgXFile,
      thirdImgXFile,
      fourthImgXFile,
      fifthImgXFile;

  List<SubCategory> subCategoriesByCategory = [];
  List<Brand> brandsBySubCategory = [];
  List<String> variantsByVariantType = [];

  DashBoardProvider(this._dataProvider);

  addProduct() async {
    try {
      // Validate form
      if (addProductFormKey.currentState?.validate() != true) {
        SnackBarHelper.showErrorSnackBar(
            'Please fill out all required fields.');
        return;
      }

      // Ensure an image is selected
      if (mainImgXFile == null) {
        SnackBarHelper.showErrorSnackBar('Please choose an image!');
        return; // Stop the function execution
      }

      // Create form data map
      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text,
        'description': productDescCtrl.text,
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'proBrandId': selectedBrand?.sId ?? '',
        'price': productPriceCtrl.text,
        'offerPrice': productOffPriceCtrl.text.isEmpty
            ? productPriceCtrl.text
            : productOffPriceCtrl.text,
        'quantity': productQntCtrl.text,
        'proVariantTypeId': selectedVariantType?.sId ?? '',
        'proVariantId': selectedVariants,
      };

      // Check for missing required fields
      final missingFields = formDataMap.entries
          .where((entry) =>
              entry.value == null ||
              (entry.value is String && entry.value.isEmpty))
          .map((entry) => entry.key)
          .toList();

      if (missingFields.isNotEmpty) {
        SnackBarHelper.showErrorSnackBar(
            'Missing required fields: ${missingFields.join(', ')}');
        return;
      }

      // Create form data with images
      final FormData form = await createFormDataForMultipleImage(
        imgXFiles: [
          {'image1': mainImgXFile},
          {'image2': secondImgXFile},
          {'image3': thirdImgXFile},
          {'image4': fourthImgXFile},
          {'image5': fifthImgXFile},
        ],
        formData: formDataMap,
      );

      // Make API call to add item
      final response = await service.addItem(
        endpointUrl: 'products',
        itemData: form,
      );

      // Handle response
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllProducts();
          print('Product added');
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add product: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  updateProduct() async {
    try {
      // Check if productForUpdate is not null
      if (productForUpdate != null) {
        Map<String, dynamic> formDataMap = {
          'name': productNameCtrl.text,
          'description': productDescCtrl.text,
          'procategoryId': selectedCategory?.sId ?? '',
          'proSubCategoryId': selectedSubCategory?.sId ?? '',
          'proBrandId': selectedBrand?.sId ?? '',
          'price': productPriceCtrl.text,
          'offerPrice': productOffPriceCtrl.text.isEmpty
              ? productPriceCtrl.text
              : productOffPriceCtrl.text,
          'quantity': productQntCtrl.text,
          'provariantTypeId': selectedVariantType?.sId ?? '',
          'provariantId': selectedVariants,
        };

        final FormData form = await createFormDataForMultipleImage(imgXFiles: [
          {'image1': mainImgXFile},
          {'image2': secondImgXFile},
          {'image3': thirdImgXFile},
          {'image4': fourthImgXFile},
          {'image5': fifthImgXFile}
        ], formData: formDataMap);

        final response = await service.updateItem(
          endpointUrl: 'products',
          itemData: form,
          itemId: productForUpdate?.sId ?? '',
        );

        if (response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if (apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            print('Product updated');
            _dataProvider.getAllProducts();
          } else {
            SnackBarHelper.showErrorSnackBar(
                'Failed to update product: ${apiResponse.message}');
          }
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  submitProduct() {
    if (productForUpdate != null) {
      updateProduct();
    } else {
      addProduct();
    }
  }

  deleteProduct(Product product) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'products', itemId: product.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Product Deleted Successfully');
          _dataProvider.getAllProducts();
        } else {
          SnackBarHelper.showErrorSnackBar('Error ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  void pickImage({required int imageCardNumber}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (imageCardNumber == 1) {
        selectedMainImage = File(image.path);
        mainImgXFile = image;
      } else if (imageCardNumber == 2) {
        selectedSecondImage = File(image.path);
        secondImgXFile = image;
      } else if (imageCardNumber == 3) {
        selectedThirdImage = File(image.path);
        thirdImgXFile = image;
      } else if (imageCardNumber == 4) {
        selectedFourthImage = File(image.path);
        fourthImgXFile = image;
      } else if (imageCardNumber == 5) {
        selectedFifthImage = File(image.path);
        fifthImgXFile = image;
      }
      notifyListeners();
    }
  }

  Future<FormData> createFormDataForMultipleImage({
    required List<Map<String, XFile?>>? imgXFiles,
    required Map<String, dynamic> formData,
  }) async {
    // Loop over the provided image files and add them to the form data
    if (imgXFiles != null) {
      for (int i = 0; i < imgXFiles.length; i++) {
        XFile? imgXFile = imgXFiles[i]['image' + (i + 1).toString()];
        if (imgXFile != null) {
          // Check if it's running on the web
          if (kIsWeb) {
            String fileName = imgXFile.name;
            Uint8List byteImg = await imgXFile.readAsBytes();
            formData['image' + (i + 1).toString()] =
                MultipartFile(byteImg, filename: fileName);
          } else {
            String filePath = imgXFile.path;
            String fileName = filePath.split('/').last;
            formData['image' + (i + 1).toString()] =
                await MultipartFile(filePath, filename: fileName);
          }
        }
      }
    }

    // Create and return the FormData object
    final FormData form = FormData(formData);
    return form;
  }

  filterSubcategory(Category category) {
    selectedSubCategory = null;
    selectedBrand = null;
    selectedCategory = category;
    subCategoriesByCategory.clear();
    final newList = _dataProvider.subCategories
        .where((subcategory) => subcategory.categoryId?.sId == category.sId)
        .toList();
    subCategoriesByCategory = newList;

    notifyListeners();
  }

  filterBrand(SubCategory subCategory) {
    // Reset selectedBrand and selectedSubCategory
    selectedBrand = null;
    selectedSubCategory = subCategory;
    // Clear previous brand list
    brandsBySubCategory.clear();
    // Check if subCategory is not null and filter brands
    final newList = _dataProvider.brands.where((brand) {
      return brand.subcategoryId?.sId == subCategory.sId;
    }).toList();
    brandsBySubCategory = newList;

    notifyListeners();
  }

  filterVariant(VariantType variantType) {
    // Reset selectedVariants and selectedVariantType
    selectedVariants = [];
    selectedVariantType = variantType;

    // Check if variantType is not null and filter variants
    final newList = _dataProvider.variants.where((variant) {
      return variant.variantTypeId?.sId == variantType.sId;
    }).toList();

    // Extract variant names
    final List<String> variantNames =
        newList.map((variant) => variant.name ?? '').toList();

    // Update the list of variant names
    variantsByVariantType = variantNames;

    // Notify listeners to update UI
    notifyListeners();
  }

  setDataForUpdateProduct(Product? product) {
    if (product != null) {
      productForUpdate = product;

      productNameCtrl.text = product.name ?? '';
      productDescCtrl.text = product.description ?? '';
      productPriceCtrl.text = product.price.toString();
      productOffPriceCtrl.text = '${product.offerPrice}';
      productQntCtrl.text = '${product.quantity}';

      selectedCategory = _dataProvider.categories.firstWhereOrNull(
          (element) => element.sId == product.proCategoryId?.sId);

      final newListCategory = _dataProvider.subCategories
          .where((subcategory) =>
              subcategory.categoryId?.sId == product.proCategoryId?.sId)
          .toList();
      subCategoriesByCategory = newListCategory;
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == product.proSubCategoryId?.sId);

      final newListBrand = _dataProvider.brands
          .where((brand) =>
              brand.subcategoryId?.sId == product.proSubCategoryId?.sId)
          .toList();
      brandsBySubCategory = newListBrand;
      selectedBrand = _dataProvider.brands.firstWhereOrNull(
          (element) => element.sId == product.proBrandId?.sId);

      selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull(
          (element) => element.sId == product.proVariantTypeId?.sId);

      final newListVariant = _dataProvider.variants
          .where((variant) =>
              variant.variantTypeId?.sId == product.proVariantTypeId?.sId)
          .toList();
      final List<String> variantNames =
          newListVariant.map((variant) => variant.name ?? '').toList();
      variantsByVariantType = variantNames;
      selectedVariants = product.proVariantId ?? [];
    } else {
      clearFields();
    }
  }

  clearFields() {
    productNameCtrl.clear();
    productDescCtrl.clear();
    productPriceCtrl.clear();
    productOffPriceCtrl.clear();
    productQntCtrl.clear();

    selectedMainImage = null;
    selectedSecondImage = null;
    selectedThirdImage = null;
    selectedFourthImage = null;
    selectedFifthImage = null;

    mainImgXFile = null;
    secondImgXFile = null;
    thirdImgXFile = null;
    fourthImgXFile = null;
    fifthImgXFile = null;

    selectedCategory = null;
    selectedSubCategory = null;
    selectedBrand = null;
    selectedVariantType = null;
    selectedVariants = [];

    productForUpdate = null;

    subCategoriesByCategory = [];
    brandsBySubCategory = [];
    variantsByVariantType = [];
  }

  updateUI() {
    notifyListeners();
  }
}

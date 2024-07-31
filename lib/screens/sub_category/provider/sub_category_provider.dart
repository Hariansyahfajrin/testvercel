import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';

class SubCategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addSubCategoryFormKey = GlobalKey<FormState>();
  TextEditingController subCategoryNameCtrl = TextEditingController();
  Category? selectedCategory;
  SubCategory? subCategoryForUpdate;

  SubCategoryProvider(this._dataProvider);

  addSubCategory() async {
    try {
      // Membuat map untuk data subkategori
      Map<String, dynamic> subCategory = {
        'name': subCategoryNameCtrl.text,
        'categoryId': selectedCategory?.sId
      };

      // Menambahkan subkategori menggunakan API
      final response = await service.addItem(
          endpointUrl: 'subCategories', itemData: subCategory);

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllSubCategory();
          print('Sub category added');
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add Sub Category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e); // Mencetak error
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  updateSubCategory() async {
    try {
      if (subCategoryForUpdate != null) {
        Map<String, dynamic> subCategory = {
          'name': subCategoryNameCtrl.text,
          'categoryId': selectedCategory?.sId
        };
        final response = await service.updateItem(
            endpointUrl: 'subCategories',
            itemData: subCategory,
            itemId: subCategoryForUpdate?.sId ?? '');

        if (response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if (apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            print('Sub Category Updated');
            _dataProvider.getAllSubCategory();
          } else {
            SnackBarHelper.showErrorSnackBar(
                'Failed to update Sub Category: ${apiResponse.message}');
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

  submitsubCategory() {
    if (subCategoryForUpdate != null) {
      updateSubCategory();
    } else {
      addSubCategory();
    }
  }

  deleteSubCategory(SubCategory subCategory) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'subCategories', itemId: subCategory.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(
              'Sub Category Deleted Successfully');
          _dataProvider.getAllSubCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to delete Sub Category: ${apiResponse.message}');
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

  setDataForUpdateSubCategory(SubCategory? subCategory) {
    if (subCategory != null) {
      subCategoryForUpdate = subCategory;
      subCategoryNameCtrl.text = subCategory.name ?? '';
      selectedCategory = _dataProvider.categories.firstWhereOrNull(
          (element) => element.sId == subCategory.categoryId?.sId);
    } else {
      clearFields();
    }
  }

  clearFields() {
    subCategoryNameCtrl.clear();
    selectedCategory = null;
    subCategoryForUpdate = null;
  }

  updateUi() {
    notifyListeners();
  }
}

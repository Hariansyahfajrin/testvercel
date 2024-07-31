import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider);

  addCategory() async {
    try {
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar('Please Choose An Image!');
        return; // stop the program execution
      }

      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': 'no_data', // image path will be added from server side
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response =
          await service.addItem(endpointUrl: 'categories', itemData: form);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllCategory();
          print('category added');
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

  updateCategory() async {
    try {
      // Membuat map untuk data form
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': categoryForUpdate?.image ??
            '', // Menggunakan 'no_data' jika image tidak ada
      };

      // Membuat form data
      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      // Memperbarui kategori menggunakan API
      final response = await service.updateItem(
        endpointUrl: 'categories',
        itemData: form,
        itemId: categoryForUpdate?.sId ?? '', // Memastikan itemId ada
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          // Menggunakan print untuk log jika tidak menggunakan dart:developer
          print('Category updated successfully');
          // Memperbarui daftar kategori
          _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to update category: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e); // Mencetak error
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  submitCategory() {
    if (categoryForUpdate != null) {
      updateCategory();
    } else {
      addCategory();
    }
  }

  deleteCategory(Category category) async {
    try {
      // Menghapus kategori menggunakan API
      Response response = await service.deleteItem(
        endpointUrl: 'categories',
        itemId: category.sId ?? '', // Memastikan itemId ada
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Category Deleted Successfully');
          // Memperbarui daftar kategori setelah penghapusan
          _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar('Error ${apiResponse.message}');
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

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  //? to create form data for sending image with body
  Future<FormData> createFormData(
      {required XFile? imgXFile,
      required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}

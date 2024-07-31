import 'dart:io';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/poster.dart';

class PosterProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addPosterFormKey = GlobalKey<FormState>();
  TextEditingController posterNameCtrl = TextEditingController();
  Poster? posterForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  PosterProvider(this._dataProvider);

  addPoster() async {
    try {
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar('Please choose an image!');
        return; // Stop the function execution
      }

      Map<String, dynamic> formDataMap = {
        'posterName': posterNameCtrl.text,
        'image': 'no_data', // Image path will be added from the server side
      };

      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      final response = await service.addItem(
        endpointUrl: 'posters',
        itemData: form,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          print('Poster added');
          _dataProvider.getAllPosters(); // Fixed method name
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add poster: ${apiResponse.message}');
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

  updatePoster() async {
    try {
      if (posterForUpdate == null) {
        SnackBarHelper.showErrorSnackBar('No poster selected for update!');
        return; // Stop the function execution
      }

      Map<String, dynamic> formDataMap = {
        'posterName': posterNameCtrl.text,
        'image': posterForUpdate?.imageUrl ??
            '', // Fixed the field name to match your model
      };

      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      final response = await service.updateItem(
        endpointUrl: 'posters',
        itemData: form,
        itemId: posterForUpdate?.sId ?? '',
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          print('Poster updated');
          _dataProvider.getAllPosters();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update poster: ${apiResponse.message}');
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

  submitPoster() {
    if (posterForUpdate != null) {
      updatePoster();
    } else {
      addPoster();
    }
  }

  deletePoster(Poster poster) async {
    try {
      if (poster.sId == null || poster.sId!.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Poster ID is missing!');
        return; // Stop the function execution
      }

      final Response response = await service.deleteItem(
        endpointUrl: 'posters',
        itemId: poster.sId!,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar('Poster Deleted Successfully');
          _dataProvider.getAllPosters();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to delete poster: ${apiResponse.message}');
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

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  setDataForUpdatePoster(Poster? poster) {
    if (poster != null) {
      clearFields();
      posterForUpdate = poster;
      posterNameCtrl.text = poster.posterName ?? '';
    } else {
      clearFields();
    }
  }

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

  clearFields() {
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    posterForUpdate = null;
  }
}

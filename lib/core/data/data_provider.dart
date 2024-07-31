import '../../models/api_response.dart';
import '../../models/coupon.dart';
import '../../models/my_notification.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/variant_type.dart';
import '../../services/http_services.dart';
import '../../utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../../models/category.dart';
import '../../models/brand.dart';
import '../../models/sub_category.dart';
import '../../models/variant.dart';

class DataProvider extends ChangeNotifier {
  HttpService service = HttpService();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];

  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  List<Brand> get brands => _filteredBrands;

  List<VariantType> _allVariantTypes = [];
  List<VariantType> _filteredVariantTypes = [];
  List<VariantType> get variantTypes => _filteredVariantTypes;

  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];
  List<Variant> get variants => _filteredVariants;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> get products => _filteredProducts;

  List<Coupon> _allCoupons = [];
  List<Coupon> _filteredCoupons = [];
  List<Coupon> get coupons => _filteredCoupons;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];
  List<Poster> get posters => _filteredPosters;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

  List<MyNotification> _allNotifications = [];
  List<MyNotification> _filteredNotifications = [];
  List<MyNotification> get notifications => _filteredNotifications;

  DataProvider() {
    getAllProducts();
    getAllCategory();
    getAllSubCategory();
    getAllBrands();
    getAllVariantTypes();
    getAllVariant();
    getAllPosters();
  }

  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'categories');
      if (response.isOk) {
        ApiResponse<List<Category>> apiResponse =
            ApiResponse<List<Category>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Category.fromJson(item)).toList(),
        );

        _allCategories = apiResponse.data ?? [];
        _filteredCategories =
            List.from(_allCategories); // Initialize filtered list with all data
        notifyListeners();

        if (showSnack) SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (showSnack) SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }

    return _filteredCategories;
  }

  void filterCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      // Mendapatkan subkategori menggunakan API
      Response response = await service.getItems(endpointUrl: 'subCategories');
      if (response.isOk) {
        ApiResponse<List<SubCategory>> apiResponse =
            ApiResponse<List<SubCategory>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => SubCategory.fromJson(item)).toList(),
        );

        _allSubCategories = apiResponse.data ?? [];
        _filteredSubCategories = List.from(
            _allSubCategories); // Inisialisasi daftar yang difilter dengan semua data
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
              'Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (e) {
      print(e); // Mencetak error
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      }
      rethrow;
    }
    return _filteredSubCategories;
  }

  void filterSubCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredSubCategories = _allSubCategories.where((subcategory) {
        return (subcategory.name ?? '').toLowerCase().contains(lowerKeyword) ||
            (subcategory.categoryId?.name ?? '')
                .toLowerCase()
                .contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      // Mengirim permintaan untuk mendapatkan daftar brand
      Response response = await service.getItems(endpointUrl: 'brands');

      if (response.isOk) {
        // Mengurai respons JSON ke ApiResponse<List<Brand>>
        ApiResponse<List<Brand>> apiResponse =
            ApiResponse<List<Brand>>.fromJson(
          response.body,
          (json) => (json as List).map((item) => Brand.fromJson(item)).toList(),
        );

        // Menyimpan data brand ke dalam variabel
        _allBrands = apiResponse.data ?? [];
        _filteredBrands = List.from(
            _allBrands); // Inisialisasi daftar terfilter dengan semua data
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(e.toString());
      }
      rethrow;
    }

    // Mengembalikan daftar brand terfilter
    return _filteredBrands;
  }

  void filterBrands(String keyword) {
    if (keyword.isEmpty) {
      // Jika keyword kosong, tampilkan semua brand
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredBrands = _allBrands.where((brand) {
        final brandName = (brand.name ?? '').toLowerCase();
        final subcategoryName = (brand.subcategoryId?.name ?? '').toLowerCase();
        return brandName.contains(lowerKeyword) ||
            subcategoryName.contains(lowerKeyword);
      }).toList();
    }

    // Memperbarui UI dengan data terfilter
    notifyListeners();
  }

  Future<List<VariantType>> getAllVariantTypes({bool showSnack = false}) async {
    try {
      // Mengambil daftar tipe varian menggunakan API
      Response response = await service.getItems(endpointUrl: 'variantTypes');

      if (response.isOk) {
        // Menguraikan respons API menjadi objek ApiResponse
        ApiResponse<List<VariantType>> apiResponse =
            ApiResponse<List<VariantType>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => VariantType.fromJson(item)).toList(),
        );

        // Menyimpan data tipe varian
        _allVariantTypes = apiResponse.data ?? [];
        _filteredVariantTypes = List.from(
            _allVariantTypes); // Initialize filtered list with all data
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(e.toString());
      }
      rethrow;
    }

    // Mengembalikan daftar tipe varian terfilter
    return _filteredVariantTypes;
  }

  void filterVariantTypes(String keyword) {
    if (keyword.isEmpty) {
      // Jika keyword kosong, tampilkan semua tipe varian
      _filteredVariantTypes = List.from(_allVariantTypes);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredVariantTypes = _allVariantTypes.where((variantType) {
        return (variantType.name ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    // Memperbarui UI dengan data terfilter
    notifyListeners();
  }

  Future<List<Variant>> getAllVariant({bool showSnack = false}) async {
    try {
      // Mengirim permintaan untuk mendapatkan semua varian
      final response = await service.getItems(endpointUrl: 'variants');

      if (response.isOk) {
        // Mengolah respons API
        ApiResponse<List<Variant>> apiResponse =
            ApiResponse<List<Variant>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Variant.fromJson(item)).toList(),
        );

        _allVariants = apiResponse.data ?? [];
        _filteredVariants = List.from(
            _allVariants); // Inisialisasi daftar terfilter dengan semua data
        notifyListeners();

        // Menampilkan pesan sukses jika diperlukan
        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }

        return _filteredVariants;
      } else {
        // Menampilkan pesan error jika respons tidak OK
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
        return [];
      }
    } catch (e) {
      // Menangani kesalahan yang mungkin terjadi
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  void filterVariants(String keyword) {
    if (keyword.isEmpty) {
      // Jika keyword kosong, tampilkan semua varian
      _filteredVariants = List.from(_allVariants);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredVariants = _allVariants.where((variant) {
        // Memeriksa nama varian dan nama tipe varian
        final variantNameMatches =
            (variant.name ?? '').toLowerCase().contains(lowerKeyword);
        final variantTypeNameMatches = (variant.variantTypeId?.name ?? '')
            .toLowerCase()
            .contains(lowerKeyword);
        return variantNameMatches || variantTypeNameMatches;
      }).toList();
    }

    // Memperbarui UI dengan data terfilter
    notifyListeners();
  }

  Future<void> getAllProducts({bool showSnack = false}) async {
    try {
      // Fetching products from the service
      Response response = await service.getItems(endpointUrl: 'products');

      // Parsing the response
      ApiResponse<List<Product>> apiResponse =
          ApiResponse<List<Product>>.fromJson(
        response.body,
        (json) => (json as List).map((item) => Product.fromJson(item)).toList(),
      );

      // Updating the lists with fetched data
      _allProducts = apiResponse.data ?? [];
      _filteredProducts =
          List.from(_allProducts); // Initialize filtered list with all data

      // Notify listeners to update the UI
      notifyListeners();

      // Show success snack bar if required
      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      // Show error snack bar if required
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(e.toString());
      }
      // Optionally, log the error
      print(e);
    }
  }

  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      // If keyword is empty, show all products
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowerKeyword = keyword.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final productNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowerKeyword);
        final categoryNameContainsKeyword =
            product.proCategoryId?.name?.toLowerCase().contains(lowerKeyword) ??
                false;
        final subCategoryNameContainsKeyword = product.proSubCategoryId?.name
                ?.toLowerCase()
                .contains(lowerKeyword) ??
            false;

        // Combine all conditions
        return productNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword;
      }).toList();
    }

    // Notify listeners to update the UI
    notifyListeners();
  }

  void filterProductsByQuantity(String productQntType) {
    if (productQntType == 'All Product') {
      // Show all products
      _filteredProducts = List.from(_allProducts);
    } else if (productQntType == 'Out of Stock') {
      // Filter products with quantity equal to 0 (out of stock)
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 0;
      }).toList();
    } else if (productQntType == 'Limited Stock') {
      // Filter products with quantity equal to 1 (limited stock)
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 10;
      }).toList();
    } else if (productQntType == 'Other Stock') {
      // Filter products with quantity not equal to 0 or 1 (other stock)
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null &&
            product.quantity != 0 &&
            product.quantity != 1;
      }).toList();
    } else {
      // If no match, show all products
      _filteredProducts = List.from(_allProducts);
    }
    notifyListeners();
  }

  int calculateProductWithQuantity({int? quantity}) {
    int totalProduct = 0;

    // If quantity is null, return the total count of all products
    if (quantity == null) {
      totalProduct = _allProducts.length;
    } else {
      // Count the number of products that match the specified quantity
      for (Product product in _allProducts) {
        if (product.quantity != null && product.quantity == quantity) {
          totalProduct += 1; // Increment the count if quantity matches
        }
      }
    }

    return totalProduct;
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      final Response response = await service.getItems(endpointUrl: 'posters');

      if (response.isOk) {
        ApiResponse<List<Poster>> apiResponse =
            ApiResponse<List<Poster>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Poster.fromJson(item)).toList(),
        );

        _allPosters = apiResponse.data ?? [];
        _filteredPosters = List.from(_allPosters);
        notifyListeners();

        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
              'Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      }
      rethrow;
    }

    return _filteredPosters;
  }

  void filterPosters(String keyword) {
    if (keyword.isEmpty) {
      _filteredPosters = List.from(_allPosters);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredPosters = _allPosters.where((poster) {
        return (poster.posterName ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }

    notifyListeners();
  }

  Future<List<Coupon>> getAllCoupons({bool showSnack = false}) async {
    try {
      // Fetch the coupons from the API
      Response response = await service.getItems(endpointUrl: 'couponCodes');

      if (response.isOk) {
        // Parse the API response
        ApiResponse<List<Coupon>> apiResponse =
            ApiResponse<List<Coupon>>.fromJson(
          response.body,
          (json) =>
              (json as List).map((item) => Coupon.fromJson(item)).toList(),
        );

        // Update internal state
        _allCoupons = apiResponse.data ?? [];
        _filteredCoupons = List.from(_allCoupons);
        notifyListeners();

        // Show success message if required
        if (showSnack) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        }
      } else {
        // Show error message if request failed
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }

      // Return the filtered list of coupons
      return _filteredCoupons;
    } catch (e) {
      // Handle exceptions
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(e.toString());
      }
      rethrow;
    }
  }

  void filterCoupons(String keyword) {
    if (keyword.isEmpty) {
      _filteredCoupons = List.from(_allCoupons);
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredCoupons = _allCoupons.where((coupon) {
        return (coupon.couponCode ?? '').toLowerCase().contains(lowerKeyword);
      }).toList();
    }
    notifyListeners();
  }
}

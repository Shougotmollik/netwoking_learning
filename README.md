# 🚀 Production-Ready Dio API Client Setup

## 📦 Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP Client
  dio: ^5.4.0
  
  # Pretty Logger for API calls (Debug only)
  pretty_dio_logger: ^1.3.1
  
  # GetX for state management (if using)
  get: ^4.6.6

dev_dependencies:
  flutter_test:
    sdk: flutter
```

Run:
```bash
flutter pub get
```

---

## 🔧 Setup Instructions

### 1️⃣ Initialize in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:home_cache/services/dio_api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dio API Client
  await ApiClient.initialize();
  
  runApp(const MyApp());
}
```

---

### 2️⃣ After Login - Update Token

```dart
// After successful login, update the token in API client
await PrefsHelper.setString(AppConstants.bearerToken, token);
await ApiClient.updateToken();
```

---

### 3️⃣ On Logout - Clear Token

```dart
await PrefsHelper.remove(AppConstants.bearerToken);
ApiClient.clearToken();
```

---

## 📖 Usage Examples

### ✅ GET Request

```dart
try {
  final response = await ApiClient.get('/users');
  
  if (response.statusCode == 200) {
    print("Users: ${response.data}");
  }
} on ApiException catch (e) {
  print("Error: ${e.message}");
}
```

### ✅ GET with Query Parameters

```dart
final response = await ApiClient.get(
  '/users',
  queryParameters: {
    'page': 1,
    'limit': 10,
    'search': 'john',
  },
);
```

### ✅ GET with Custom Headers

```dart
final response = await ApiClient.get(
  '/api/data',
  headers: {
    'X-Custom-Header': 'Value',
    'X-API-Version': '2.0',
  },
);
```

---

### ✅ POST Request

```dart
try {
  final response = await ApiClient.post(
    '/auth/login',
    data: {
      'email': 'user@example.com',
      'password': 'password123',
    },
  );
  
  if (response.statusCode == 200) {
    final token = response.data['token'];
    // Save token
  }
} on ApiException catch (e) {
  print("Login failed: ${e.message}");
}
```

---

### ✅ POST Multipart (File Upload)

```dart
// Single file upload
final multipartFile = await ApiClient.fileFromPath(
  imageFile.path,
  filename: 'profile.jpg',
);

final response = await ApiClient.postMultipart(
  '/user/upload-avatar',
  fields: {
    'user_id': '123',
    'type': 'profile',
  },
  files: {
    'avatar': multipartFile, // field_name: file
  },
  onSendProgress: (sent, total) {
    print("Progress: ${(sent / total * 100).toStringAsFixed(0)}%");
  },
);
```

#### Multiple Files Upload

```dart
Map<String, MultipartFile> files = {};

for (int i = 0; i < imageFiles.length; i++) {
  final file = await ApiClient.fileFromPath(imageFiles[i].path);
  files['images[$i]'] = file; // images[0], images[1], etc.
}

final response = await ApiClient.postMultipart(
  '/posts/create',
  fields: {
    'title': 'My Post',
    'description': 'Description',
  },
  files: files,
);
```

---

### ✅ PUT Request

```dart
final response = await ApiClient.put(
  '/user/profile',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
);
```

---

### ✅ PUT Multipart

```dart
final multipartFile = await ApiClient.fileFromPath(imageFile.path);

final response = await ApiClient.putMultipart(
  '/posts/123',
  fields: {
    'title': 'Updated Title',
  },
  files: {
    'image': multipartFile,
  },
);
```

---

### ✅ PATCH Request

```dart
final response = await ApiClient.patch(
  '/users/123',
  data: {
    'name': 'Updated Name',
  },
);
```

---

### ✅ PATCH Multipart

```dart
final multipartFile = await ApiClient.fileFromPath(imageFile.path);

final response = await ApiClient.patchMultipart(
  '/user/profile',
  fields: {
    'bio': 'Updated bio',
  },
  files: {
    'avatar': multipartFile,
  },
);
```

---

### ✅ DELETE Request

```dart
// Simple delete
final response = await ApiClient.delete('/posts/123');

// Delete with body
final response = await ApiClient.delete(
  '/user/account',
  data: {
    'reason': 'No longer needed',
  },
);
```

---

### ✅ Download File

```dart
final savePath = '/storage/emulated/0/Download/file.pdf';

final response = await ApiClient.downloadFile(
  '/files/document.pdf',
  savePath,
  onReceiveProgress: (received, total) {
    print("Progress: ${(received / total * 100).toStringAsFixed(0)}%");
  },
);
```

---

### ✅ Cancel Request

```dart
final cancelToken = CancelToken();

// Start request
final futureResponse = ApiClient.get(
  '/large-data',
  cancelToken: cancelToken,
);

// Cancel it
cancelToken.cancel("Cancelled by user");
```

---

## 🎯 Advanced Features

### Custom Error Handling

```dart
try {
  final response = await ApiClient.get('/api/endpoint');
  
  if (response.statusCode == 200) {
    // Success
  }
} on ApiException catch (e) {
  if (e.statusCode == 401) {
    // Unauthorized - redirect to login
    Get.offAllNamed('/login');
  } else if (e.statusCode == -3) {
    // No internet
    showDialog("No internet connection");
  } else {
    // Other errors
    showDialog(e.message);
  }
}
```

### Upload Progress Tracking

```dart
final multipartFile = await ApiClient.fileFromPath(imageFile.path);

final response = await ApiClient.postMultipart(
  '/upload',
  fields: {'title': 'File'},
  files: {'file': multipartFile},
  onSendProgress: (sent, total) {
    setState(() {
      uploadProgress = (sent / total * 100);
    });
  },
);
```

---

## 🔐 Authentication Flow

```dart
// 1. Login
Future<bool> login(String email, String password) async {
  try {
    final response = await ApiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    
    if (response.statusCode == 200) {
      final token = response.data['token'];
      await PrefsHelper.setString(AppConstants.bearerToken, token);
      await ApiClient.updateToken();
      return true;
    }
    return false;
  } on ApiException catch (e) {
    print("Login error: ${e.message}");
    return false;
  }
}

// 2. Logout
Future<void> logout() async {
  await PrefsHelper.remove(AppConstants.bearerToken);
  ApiClient.clearToken();
  Get.offAllNamed('/login');
}
```

---

## 🎨 Features

✅ **All HTTP Methods**: GET, POST, PUT, PATCH, DELETE  
✅ **Multipart Support**: File uploads with progress  
✅ **Token Management**: Auto-inject bearer tokens  
✅ **Pretty Logging**: Beautiful API logs (debug mode only)  
✅ **Error Handling**: Comprehensive error messages  
✅ **Timeout Handling**: 30s timeout for all requests  
✅ **Cancel Requests**: CancelToken support  
✅ **Download Files**: With progress tracking  
✅ **Custom Headers**: Per-request header support  
✅ **Interceptors**: Auth & Error interceptors  
✅ **Production Ready**: Clean, scalable architecture  

---

## 🐛 Error Status Codes

| Code | Meaning |
|------|---------|
| `200` | Success |
| `201` | Created |
| `204` | No Content |
| `400` | Bad Request |
| `401` | Unauthorized |
| `403` | Forbidden |
| `404` | Not Found |
| `422` | Validation Error |
| `500` | Server Error |
| `-1` | Timeout |
| `-2` | Request Cancelled |
| `-3` | No Internet |
| `-4` | Certificate Error |

---

## 📝 Notes

- Logger only works in **debug mode** (automatically disabled in release)
- Token is auto-injected from `PrefsHelper`
- All responses are automatically parsed
- Errors are thrown as `ApiException` for consistent handling
- Multipart requests auto-detect content type

---

## 🚀 Migration from Old API Client

**Old:**
```dart
final response = await ApiClient.getData('/users');
```

**New:**
```dart
final response = await ApiClient.get('/users');
```

**Old Multipart:**
```dart
await ApiClient.postMultipartData(
  '/upload',
  {'key': 'value'},
  multipartBody: [MultipartBody('image', file)],
);
```

**New Multipart:**
```dart
final multipartFile = await ApiClient.fileFromPath(file.path);
await ApiClient.postMultipart(
  '/upload',
  fields: {'key': 'value'},
  files: {
    'image': multipartFile, // field_name: file
  },
);
```

---

## 📞 Support

For issues or questions, check the usage examples in `api_usage_examples.dart`.

Happy coding! 🎉

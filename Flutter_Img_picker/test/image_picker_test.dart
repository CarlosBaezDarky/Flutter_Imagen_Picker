import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_img_picker/main.dart'; // Reemplaza con la ruta correcta a tu archivo principal.

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  group('ImagePickerDemo', () {
    late MockImagePicker mockImagePicker;

    setUp(() {
      mockImagePicker = MockImagePicker();
    });

    testWidgets('should display a placeholder when no image is selected', (WidgetTester tester) async {
      // Construir la aplicación
      await tester.pumpWidget(const MyApp());

      // Verificar que el texto "No Image Selected" está presente
      expect(find.text('No Image Selected'), findsOneWidget);
    });

    testWidgets('should show image from gallery when gallery button is pressed', (WidgetTester tester) async {
      // Simulando la selección de una imagen desde la galería
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('path/to/selected/image.jpg'));

      // Construir la aplicación con el mock
      await tester.pumpWidget(MyAppWithMockedPicker(mockImagePicker));

      // Simular el presionado del botón de la galería
      await tester.tap(find.byIcon(Icons.photo_library));
      await tester.pumpAndSettle();

      // Verificar que se muestra la imagen seleccionada
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should show image from camera when camera button is pressed', (WidgetTester tester) async {
      // Simulando la captura de una imagen con la cámara
      when(mockImagePicker.pickImage(source: ImageSource.camera))
          .thenAnswer((_) async => XFile('path/to/captured/image.jpg'));

      // Construir la aplicación con el mock
      await tester.pumpWidget(MyAppWithMockedPicker(mockImagePicker));

      // Simular el presionado del botón de la cámara
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Verificar que se muestra la imagen tomada
      expect(find.byType(Image), findsOneWidget);
    });
  });
}

class MyAppWithMockedPicker extends StatelessWidget {
  final ImagePicker imagePicker;

  const MyAppWithMockedPicker(this.imagePicker, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ImagePickerDemo(imagePicker: imagePicker),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
  final ImagePicker imagePicker;

  const ImagePickerDemo({super.key, required this.imagePicker});

  @override
  State<ImagePickerDemo> createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  File? image;

  Future<void> _captureImageFromCamera() async {
    final pickedFile = await widget.imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      image = File(pickedFile!.path);
    });
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await widget.imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker Example')),
      body: Center(
        child: image == null
            ? const Text('No Image Selected')
            : Image.file(image!),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _pickImageFromGallery,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _captureImageFromCamera,
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}

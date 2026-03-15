import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_provider.dart';
import '../models/menu_model.dart';

class FormMenuPage extends StatefulWidget {
  final MenuModel? menu;

  const FormMenuPage({super.key, this.menu});

  @override
  State<FormMenuPage> createState() => _FormMenuPageState();
}

class _FormMenuPageState extends State<FormMenuPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final gambarController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      namaController.text = widget.menu!.nama;
      hargaController.text = widget.menu!.harga.toString();
      deskripsiController.text = widget.menu!.deskripsi;
      gambarController.text = widget.menu!.gambar;
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    gambarController.dispose();
    super.dispose();
  }

  String? validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama menu wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama menu minimal 3 karakter';
    }
    return null;
  }

  String? validateHarga(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga wajib diisi';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Harga harus berupa angka';
    }
    if (parsed <= 0) {
      return 'Harga harus lebih dari 0';
    }
    return null;
  }

  String? validateDeskripsi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi wajib diisi';
    }
    if (value.trim().length < 5) {
      return 'Deskripsi terlalu pendek';
    }
    return null;
  }

  String? validateGambar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Link gambar wajib diisi';
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return 'Link gambar harus berupa URL yang valid';
    }
    return null;
  }

  Future<void> simpanMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    final nama = namaController.text.trim();
    final harga = int.parse(hargaController.text.trim());
    final deskripsi = deskripsiController.text.trim();
    final gambar = gambarController.text.trim();

    try {
      if (widget.menu == null) {
        await menuProvider.tambahMenu(nama, harga, deskripsi, gambar);
      } else {
        await menuProvider.editMenu(
          widget.menu!.id!,
          nama,
          harga,
          deskripsi,
          gambar,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.menu == null
                ? 'Menu berhasil ditambahkan'
                : 'Menu berhasil diperbarui',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.menu != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  border: OutlineInputBorder(),
                ),
                validator: validateNama,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  hintText: 'Contoh: 15000',
                  border: OutlineInputBorder(),
                ),
                validator: validateHarga,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: validateDeskripsi,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: gambarController,
                decoration: const InputDecoration(
                  labelText: 'Link Gambar',
                  border: OutlineInputBorder(),
                ),
                validator: validateGambar,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : simpanMenu,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Update' : 'Tambah'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


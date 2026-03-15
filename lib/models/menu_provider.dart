import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_model.dart';

class MenuProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<MenuModel> _menus = [];
  bool _isLoading = false;

  List<MenuModel> get menus => _menus;
  bool get isLoading => _isLoading;

  Future<void> fetchMenus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('menus')
          .select()
          .order('id', ascending: true);

      _menus = (response as List)
          .map((item) => MenuModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambahMenu(
    String nama,
    int harga,
    String deskripsi,
    String gambar,
  ) async {
    try {
      await _supabase.from('menus').insert({
        'nama_menu': nama,
        'harga': harga,
        'deskripsi': deskripsi,
        'gambar': gambar,
      });

      await fetchMenus();
    } on PostgrestException catch (e) {
      throw Exception('Gagal menambah menu: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menambah menu');
    }
  }

  Future<void> editMenu(
    int id,
    String nama,
    int harga,
    String deskripsi,
    String gambar,
  ) async {
    try {
      await _supabase
          .from('menus')
          .update({
            'nama_menu': nama,
            'harga': harga,
            'deskripsi': deskripsi,
            'gambar': gambar,
          })
          .eq('id', id);

      await fetchMenus();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengedit menu: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengedit menu');
    }
  }

  Future<void> hapusMenu(int id) async {
    try {
      await _supabase.from('menus').delete().eq('id', id);
      await fetchMenus();
    } on PostgrestException catch (e) {
      throw Exception('Gagal menghapus menu: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus menu');
    }
  }
}
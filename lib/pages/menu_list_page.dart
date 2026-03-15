import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import '../models/menu_model.dart';
import '../models/menu_provider.dart';
import '../models/theme_provider.dart';
import 'form_menu_page.dart';

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await context.read<MenuProvider>().fetchMenus();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String formatHarga(int harga) {
    return 'Rp $harga';
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, MenuModel menu) async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Menu?'),
        content: Text("Yakin mau hapus '${menu.nama}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await menuProvider.hapusMenu(menu.id!);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu berhasil dihapus')),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _goToFormTambah() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormMenuPage()),
    );

    if (!context.mounted) return;

    try {
      await context.read<MenuProvider>().fetchMenus();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();
    final menus = provider.menus;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: false,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_btn',
            onPressed: _goToFormTambah,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'logout_btn',
            onPressed: logout,
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.logout),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : menus.isEmpty
              ? const Center(child: Text('Belum ada data menu'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 180,
                      collapsedHeight: 70,
                      toolbarHeight: 70,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      actions: [
                        IconButton(
                          tooltip: isDark
                              ? 'Pindah ke light mode'
                              : 'Pindah ke dark mode',
                          onPressed: () {
                            themeProvider.toggleTheme(!isDark);
                          },
                          icon: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: isDark ? Colors.amber : Colors.orange,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      flexibleSpace: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/bg.jpg',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: Text(
                          'Daftar Menu Batagorku',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final menu = menus[index];

                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormMenuPage(menu: menu),
                                  ),
                                );

                                if (!context.mounted) return;

                                try {
                                  await context.read<MenuProvider>().fetchMenus();
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: Card(
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isDark ? Colors.white12 : Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                elevation: isDark ? 1 : 3,
                                shadowColor:
                                    isDark ? Colors.white10 : Colors.black26,
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      menu.gambar,
                                      height: 110,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 110,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          8,
                                          8,
                                          8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menu.nama,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formatHarga(menu.harga),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              menu.deskripsi,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.grey,
                                              ),
                                            ),
                                            const Spacer(),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                onTap: () =>
                                                    _confirmDelete(context, menu),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isDark
                                                          ? Colors.white12
                                                          : Colors.black12,
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: isDark
                                                            ? Colors.white
                                                                .withOpacity(0.05)
                                                            : Colors.black
                                                                .withOpacity(0.12),
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete_outline,
                                                    size: 16,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: menus.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.60,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),
    );
  }
}

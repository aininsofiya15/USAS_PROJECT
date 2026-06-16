import 'package:flutter/material.dart';

class UsasHeader extends StatelessWidget implements PreferredSizeWidget {
  const UsasHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 100,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black, size: 35),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: SizedBox(
          height: 250, 
          child: Image.asset('assets/usas_logo.png', fit: BoxFit.contain),
        ),
      ),
      actions: const [SizedBox(width: 55)],
    );
  }
}

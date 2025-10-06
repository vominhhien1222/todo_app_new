import 'package:flutter/material.dart';

class CustomListtile extends StatelessWidget {
  final Icon? icon;
  final String title;
  final VoidCallback? ontap;

  const CustomListtile({super.key, this.icon, required this.title, this.ontap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ontap,
      leading: icon,
      title: Text(title, style: const TextStyle(fontSize: 19)),
    );
  }
}

import 'package:flutter/material.dart';

class ValidateBtn extends StatelessWidget {
  final String title;
  final VoidCallback ontap;
  final Color color;

  const ValidateBtn({
    super.key,
    required this.title,
    required this.ontap,
    this.color = const Color.fromARGB(255, 3, 163, 67),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 6,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              letterSpacing: 1.1,
              fontWeight: FontWeight.bold,
              color: Colors.white, // thêm chữ trắng
            ),
          ),
        ),
      ),
    );
  }
}

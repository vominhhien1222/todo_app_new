import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  final String selectOption;
  final List options;
  final VoidCallback ontap;
  final Icon icon;

  const CustomDropDown({
    super.key,
    required this.selectOption,
    required this.options,
    required this.ontap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      child: InkWell(
        onTap: ontap,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.indigo),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectOption,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

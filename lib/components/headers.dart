import 'package:flutter/material.dart';
import 'package:ns3_project/components/text_format.dart';

class HeadersApp extends StatelessWidget {
  const HeadersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 3),
                  child: Image.asset(
                    'assets/images/logo/Logo-app.png',
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 3),
                  child: const Text("NS3", style: text20PrimaryBold),
                ),
              ],
            ),
          ),
          Container(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.info_outline,
                color: Color(0xFF0F2C59),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

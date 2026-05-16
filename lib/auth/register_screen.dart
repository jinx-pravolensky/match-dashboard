import 'package:flutter/material.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/auth/components/component_form_register.dart'
    show ComponentFormRegister;

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  static String routeName = "/register-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(primary: true, body: RegisterScreenBody());
  }
}

class RegisterScreenBody extends StatefulWidget {
  const RegisterScreenBody({super.key});

  @override
  State<RegisterScreenBody> createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<RegisterScreenBody> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 5),
            child: const Text(
              'Sign Up',
              textAlign: TextAlign.center,
              style: text26PrimaryBold,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 30),
            child: const Text(
              'Halo 👋, Selamat Datang di NS3',
              textAlign: TextAlign.center,
              style: text16PrimaryBold,
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/logo/Logo-app.png',
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 15, bottom: 15),
            child: const Text(
              'Silahkan Daftar Akun Anda',
              textAlign: TextAlign.center,
              style: text14PrimaryBold,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 25, right: 25),
            child: ComponentFormRegister(),
          ),
        ],
      ),
    );
  }
}

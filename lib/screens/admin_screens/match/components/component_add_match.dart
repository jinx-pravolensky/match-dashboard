import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/service/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/components/text_format.dart';

class ComponentBuatMatch extends StatefulWidget {
  const ComponentBuatMatch({super.key});

  @override
  State<ComponentBuatMatch> createState() => _ComponentBuatMatchState();
}

class _ComponentBuatMatchState extends State<ComponentBuatMatch> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController matchIdController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController organizerController = TextEditingController();

  final FocusNode titleFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();
  final FocusNode organizerFocus = FocusNode();

  Future<void> _pilihTanggal(BuildContext context) async {
    DateTime today = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String hari = picked.day.toString().padLeft(2, '0');
        String bulan = picked.month.toString().padLeft(2, '0');
        dateController.text = "$hari-$bulan-${picked.year}";
      });
    }
  }

  Future<void> submitMatch() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: goldColor)),
      );

      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('userId');

      final url = Uri.parse('${ApiConfig.baseUrl}/match/create-match');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'matchCustomId': matchIdController.text.trim(),
            'title': titleController.text.trim(),
            'location': locationController.text.trim(),
            'date': dateController.text.trim(),
            'organizer': organizerController.text.trim(),
            'adminId': adminId,
          }),
        );

        Navigator.pop(context);

        if (response.statusCode == 201) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'BERHASIL',
            desc: 'Data Pertandingan berhasil dibuat!',
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            btnOkColor: primaryColor,
            btnOkText: 'Selesai',
            btnOkOnPress: () {
              Navigator.pop(context, true);
            },
          ).show();
        } else {
          final errorData = jsonDecode(response.body);

          _showErrorDialog(
            'GAGAL',
            errorData['message'] ?? "Gagal membuat pertandingan",
          );
        }
      } catch (e) {
        Navigator.pop(context);

        _showErrorDialog('KONEKSI GAGAL', "Gagal terhubung ke server.");
      }
    }
  }

  void _showErrorDialog(String title, String pesan) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title,
      desc: pesan,
      btnOkColor: const Color(0xFFD32F2F),
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text("Form Buat Match", style: text16PrimaryBold),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 10),
              const Text("ID Match", style: text14greyBold),
              const SizedBox(height: 6),
              _buildStyledField(
                controller: matchIdController,
                hint: "Masukkan ID...",
                icon: Icons.document_scanner_rounded,
                errorMsg: "ID Match tidak boleh kosong",
                action: TextInputAction.next,
                nextFocus: titleFocus,
                formatter: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9@#\-_]'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Nama Pertandingan", style: text14greyBold),
              const SizedBox(height: 6),
              _buildStyledField(
                controller: titleController,
                hint: "Masukkan Nama...",
                icon: Icons.assignment_rounded,
                errorMsg: "Nama pertandingan tidak boleh kosong",
                focusNode: titleFocus,
                action: TextInputAction.next,
                nextFocus: locationFocus,
                formatter: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Lokasi", style: text14greyBold),
              const SizedBox(height: 6),
              _buildStyledField(
                controller: locationController,
                hint: "Masukkan Lokasi...",
                icon: Icons.article_rounded,
                errorMsg: "Lokasi tidak boleh kosong",
                focusNode: locationFocus,
                action: TextInputAction.done,
                formatter: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Tanggal", style: text14greyBold),
              const SizedBox(height: 6),
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: () => _pilihTanggal(context),
                style: text14PrimaryBold,
                decoration: InputDecoration(
                  hintText: "Pilih tanggal...",
                  prefixIcon: const Icon(
                    Icons.calendar_month_rounded,
                    color: goldColor,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: secondaryColor,
                      width: 3,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Tanggal tidak boleh kosong"
                    : null,
              ),
              const SizedBox(height: 10),
              const Text("Penyelenggara", style: text14greyBold),
              const SizedBox(height: 6),
              _buildStyledField(
                controller: organizerController,
                hint: "Masukkan Nama...",
                icon: Icons.assignment_add,
                errorMsg: "Penyelenggara tidak boleh kosong",
                focusNode: organizerFocus,
                action: TextInputAction.done,
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: submitMatch,
                  child: const Text("Submit", style: text16WhiteBold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String errorMsg,
    TextInputAction? action,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    List<TextInputFormatter>? formatter,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: action,
      inputFormatters: formatter,
      style: text13PrimaryBold,

      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },

      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: goldColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: secondaryColor, width: 3),
        ),
      ),

      validator: (value) => value == null || value.isEmpty ? errorMsg : null,
    );
  }
}

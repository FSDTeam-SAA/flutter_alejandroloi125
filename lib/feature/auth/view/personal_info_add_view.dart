import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
// Removed StarText since we don't want asterisks
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

class PersonalInfoAddView extends StatefulWidget {
  const PersonalInfoAddView({super.key});

  @override
  State<PersonalInfoAddView> createState() => _PersonalInfoAddViewState();
}

class _PersonalInfoAddViewState extends State<PersonalInfoAddView> {
  final List<String> _genders = const [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
    'Other',
  ];

  String? _gender;
  Country? _country;

  void _pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (c) => setState(() => _country = c),
      countryListTheme: CountryListThemeData(
        backgroundColor: const Color(0xFF1E1F22),
        textStyle: const TextStyle(color: Colors.white),
        flagSize: 20,
        searchTextStyle: const TextStyle(color: Colors.white),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
          filled: true,
          fillColor: const Color(0xFF0B0B0B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x22FFFFFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x22FFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white54),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
      ),
    );
  }

  InputDecoration _decoration(String hint, {String? label}) => InputDecoration(
    hintText: hint,
    labelText: label,
    hintStyle: const TextStyle(color: Colors.white), // hint white
    labelStyle: const TextStyle(color: Colors.white),
    floatingLabelStyle: const TextStyle(color: Colors.white),
    filled: true,
    fillColor: const Color(0xFF1E1F22),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x22FFFFFF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white54),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        title: const Text("Personal Information", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "To create your new account, provide your information.",
              style: text16,
            ),

            const SizedBox(height: 14),
            const Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const CustomTextField(hintText: "Enter your name"),

            const SizedBox(height: 14),
            const Text("Age", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const CustomTextField(hintText: "Enter your age"),

            const SizedBox(height: 14),
            const Text("Gender", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              isExpanded: true,
              hint: const Text('Select gender', style: TextStyle(color: Colors.white)), // white placeholder
              items: _genders.map((g) {
                final selected = _gender == g;
                return DropdownMenuItem<String>(
                  value: g,
                  child: Row(
                    children: [
                      Text(g, style: const TextStyle(color: Colors.white)),
                      const Spacer(),
                      if (selected)
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFFFF7A00)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _gender = v),
              decoration: _decoration(''), // hint comes from `hint:` above
              dropdownColor: const Color(0xFF1E1F22),
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: MediaQuery.of(context).size.height * .45,
              validator: (v) => v == null || v.isEmpty ? 'Please select a gender' : null,
            ),

            const SizedBox(height: 14),
            const Text("Nationality", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickCountry,
              child: AbsorbPointer(
                child: TextFormField(
                  readOnly: true,
                  decoration: _decoration('Select country').copyWith(
                    suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  ),
                  controller: TextEditingController(
                    text: _country == null ? '' : '${_country!.flagEmoji} ${_country!.name}',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 14),
            const Text("Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const CustomTextField(hintText: "Enter your address"),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 50),
        child: bottomWidget(text: "Update"),
      ),
    );
  }
}

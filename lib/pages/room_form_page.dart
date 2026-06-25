import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../providers/room_provider.dart';
import '../utils/constants.dart';

class RoomFormPage extends StatefulWidget {
  final RoomModel? room; // null = tambah baru

  const RoomFormPage({super.key, this.room});

  @override
  State<RoomFormPage> createState() => _RoomFormPageState();
}

class _RoomFormPageState extends State<RoomFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberCtrl = TextEditingController();

  String _roomType = 'Standard';
  int _bedCount = 1;
  String _status = AppConstants.statusAvailable;
  String _cleanStatus = AppConstants.cleanBersih;

  bool get isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final r = widget.room!;
      _roomNumberCtrl.text = r.roomNumber;
      _roomType = r.roomType;
      _bedCount = r.bedCount;
      _status = r.status;
      _cleanStatus = r.cleanStatus;
    }
  }

  @override
  void dispose() {
    _roomNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final prov = context.read<RoomProvider>();

    if (isEditing) {
      final updated = widget.room!.copyWith(
        roomNumber: _roomNumberCtrl.text.trim(),
        roomType: _roomType,
        bedCount: _bedCount,
        status: _status,
        cleanStatus: _cleanStatus,
      );
      await prov.updateRoom(updated);
    } else {
      final newRoom = RoomModel(
        id: '',
        roomNumber: _roomNumberCtrl.text.trim(),
        roomType: _roomType,
        bedCount: _bedCount,
        status: _status,
        cleanStatus: _cleanStatus,
        isOccupied: false,
        isDayUse: false,
      );
      await prov.addRoom(newRoom);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Kamar berhasil diperbarui' : 'Kamar berhasil ditambahkan',
          ),
          backgroundColor: const Color(0xFFD4A853),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Kamar' : 'Tambah Kamar Baru',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Nomor Kamar ──────────────────────────────────────
              _FormSection(
                title: 'Informasi Dasar',
                icon: Icons.hotel,
                child: Column(
                  children: [
                    _StyledTextFormField(
                      controller: _roomNumberCtrl,
                      label: 'Nomor Kamar',
                      hint: 'Contoh: 101, A-203',
                      icon: Icons.door_front_door_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nomor kamar tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ─── Tipe Kamar ────────────────────────────────
                    _StyledDropdown<String>(
                      label: 'Tipe Kamar',
                      icon: Icons.category_outlined,
                      value: _roomType,
                      items: AppConstants.roomTypes,
                      itemLabel: (v) => v,
                      onChanged: (v) => setState(() => _roomType = v!),
                    ),
                    const SizedBox(height: 16),

                    // ─── Jumlah Kasur ──────────────────────────────
                    _StyledDropdown<int>(
                      label: 'Jumlah Kasur',
                      icon: Icons.bed_outlined,
                      value: _bedCount,
                      items: [1, 2],
                      itemLabel: (v) => '$v Kasur',
                      onChanged: (v) => setState(() => _bedCount = v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Status ───────────────────────────────────────────
              _FormSection(
                title: 'Status',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _StyledDropdown<String>(
                      label: 'Status Operasional',
                      icon: Icons.settings_outlined,
                      value: _status,
                      items: [
                        AppConstants.statusAvailable,
                        AppConstants.statusOutOfService,
                      ],
                      itemLabel: (v) => v == AppConstants.statusAvailable
                          ? 'Tersedia'
                          : 'Out of Service',
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: 16),
                    _StyledDropdown<String>(
                      label: 'Status Kebersihan',
                      icon: Icons.cleaning_services_outlined,
                      value: _cleanStatus,
                      items: [
                        AppConstants.cleanBersih,
                        AppConstants.cleanKotor,
                      ],
                      itemLabel: (v) =>
                          v == AppConstants.cleanBersih ? 'Bersih' : 'Kotor',
                      onChanged: (v) => setState(() => _cleanStatus = v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─── Save Button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A853),
                    foregroundColor: const Color(0xFF0A0F1E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Kamar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: _save,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form Section ─────────────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFD4A853), size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Styled Text Form Field ───────────────────────────────────────────
class _StyledTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const _StyledTextFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4A853)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}

// ─── Styled Dropdown ──────────────────────────────────────────────────
class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFF1E2D45),
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4A853)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/remedy_view_model.dart';
import 'package:artriapp/models/api_responses/remedy.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class AddRemedyPage extends StatefulWidget {
  final Remedy? remedyToEdit;

  const AddRemedyPage({super.key, this.remedyToEdit});

  @override
  State<AddRemedyPage> createState() => _AddRemedyPageState();
}

class _AddRemedyPageState extends State<AddRemedyPage> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay? _selectedTime;
  List<int> _selectedDays = [];
  int? _reminderMinutes;

  final List<String> _dayLabels = ['seg', 'ter', 'qua', 'qui', 'sex', 'sab', 'dom'];

  final Map<int?, String> _reminderOptions = {
    null: 'Sem lembrete',
    0: 'Na hora',
    5: '5 min antes',
    10: '10 min antes',
    15: '15 min antes',
    30: '30 min antes',
    60: '1 hora antes',
  };

  @override
  void initState() {
    super.initState();
    if (widget.remedyToEdit != null) {
      final r = widget.remedyToEdit!;
      _nameController.text = r.name;
      _dosageController.text = r.dosage;

      final timeParts = r.hour.split(':');
      if (timeParts.length == 2) {
        _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      }

      _selectedDays = List.from(r.daysOfWeek);
      _reminderMinutes = r.reminderMinutes;
    }
  }

  void _saveRemedy() {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha os campos de nome, dosagem e horário.')));
      return;
    }

    // NOVA VALIDAÇÃO: Exige ao menos 1 dia selecionado
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione ao menos um dia da semana.')));
      return;
    }

    final formattedTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    final viewModel = context.read<RemedyViewModel>();

    final remedy = Remedy(
      id: widget.remedyToEdit?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      dosage: _dosageController.text,
      hour: formattedTime,
      daysOfWeek: _selectedDays,
      reminderMinutes: _reminderMinutes,
      userId: viewModel.currentUserId,
    );

    if (widget.remedyToEdit != null) {
      viewModel.updateRemedy(remedy);
    } else {
      viewModel.addRemedy(remedy);
    }

    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        title: Text('MEDICAMENTOS', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nome:'),
            TextField(controller: _nameController, decoration: _inputDecoration()),
            const SizedBox(height: 20),

            _buildLabel('Dosagem:'),
            TextField(controller: _dosageController, decoration: _inputDecoration()),
            const SizedBox(height: 20),

            _buildLabel('Horário:'),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());
                if (time != null) setState(() => _selectedTime = time);
              },
              child: Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : '_ : _',
                style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Dias da semana:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isSelected = _selectedDays.contains(index);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected ? _selectedDays.remove(index) : _selectedDays.add(index);
                  }),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.lightBrown : Colors.grey[300],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _dayLabels[index],
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            _buildLabel('Lembrete:'),
            DropdownButtonFormField<int?>(
              value: _reminderMinutes,
              decoration: _inputDecoration(),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.alarm, color: AppColors.darkGreen),
              items: _reminderOptions.entries.map((entry) {
                return DropdownMenuItem<int?>(
                  value: entry.key,
                  child: Text(entry.value, style: GoogleFonts.montserrat(fontSize: 16)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _reminderMinutes = val),
            ),
            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                onPressed: _saveRemedy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03A64A),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('Salvar', style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 18, color: AppColors.darkGreen, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black54)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkGreen, width: 2)),
    );
  }
}
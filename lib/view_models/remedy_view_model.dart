import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artriapp/models/api_responses/remedy.dart';
import '../services/notification_service.dart';

class RemedyViewModel extends ChangeNotifier {
  List<Remedy> _allRemedies = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isEmpty => _allRemedies.isEmpty;

  // Em vez de bool, mapeamos o ID do remédio para a DATA em que foi consumido ("YYYY-MM-DD")
  final Map<int, String> _consumedDates = {};

  final int currentUserId = 1;

  int get _todayIndex => DateTime.now().weekday - 1;

  // Helper para gerar a string exata do dia de hoje
  String get _todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<Remedy> get unconsumedRemedies => _allRemedies
      .where((r) => r.daysOfWeek.contains(_todayIndex) && !isTaken(r.id))
      .toList();

  List<Remedy> get consumedRemedies => _allRemedies
      .where((r) => r.daysOfWeek.contains(_todayIndex) && isTaken(r.id))
      .toList();

  List<Remedy> get otherDaysRemedies => _allRemedies
      .where((r) => !r.daysOfWeek.contains(_todayIndex))
      .toList();

  RemedyViewModel() {
    NotificationService().init(onAction: (payload) {
      if (payload != null) {
        final id = int.tryParse(payload);
        if (id != null) {
          _consumedDates[id] = _todayString;
          _saveChecklistLocally();
          notifyListeners();
        }
      }
    });
  }

  // É considerado "tomado" apenas se a data salva no mapa for igual ao dia de hoje
  bool isTaken(int id) {
    return _consumedDates[id] == _todayString;
  }

  void toggleTaken(int id) {
    if (isTaken(id)) {
      _consumedDates.remove(id); // Desmarcar
    } else {
      _consumedDates[id] = _todayString; // Marcar como consumido hoje
    }
    _saveChecklistLocally();
    notifyListeners();
  }

  Future<void> fetchRemedies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega os medicamentos
      final String? remediesJson = prefs.getString('remedies_user_$currentUserId');
      if (remediesJson != null) {
        final List<dynamic> decodedList = jsonDecode(remediesJson);
        _allRemedies = decodedList.map((item) => Remedy.fromMap(item)).toList();
      } else {
        _allRemedies = [];
      }

      // Carrega o histórico de checklist
      final String? checklistJson = prefs.getString('checklist_user_$currentUserId');
      if (checklistJson != null) {
        final Map<String, dynamic> decodedChecklist = jsonDecode(checklistJson);
        _consumedDates.clear();
        decodedChecklist.forEach((key, value) {
          _consumedDates[int.parse(key)] = value.toString();
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados locais: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_allRemedies.map((r) => r.toMap()).toList());
    await prefs.setString('remedies_user_$currentUserId', encodedData);
  }

  Future<void> _saveChecklistLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedChecklist = jsonEncode(
        _consumedDates.map((key, value) => MapEntry(key.toString(), value))
    );
    await prefs.setString('checklist_user_$currentUserId', encodedChecklist);
  }

  void addRemedy(Remedy remedy) {
    _allRemedies.add(remedy);
    _scheduleNotification(remedy);
    _saveDataLocally();
    notifyListeners();
  }

  void updateRemedy(Remedy updatedRemedy) {
    final index = _allRemedies.indexWhere((r) => r.id == updatedRemedy.id);
    if (index != -1) {
      _allRemedies[index] = updatedRemedy;
      NotificationService().cancelNotification(updatedRemedy.id);
      _scheduleNotification(updatedRemedy);
      _saveDataLocally();
      notifyListeners();
    }
  }

  void deleteRemedy(int id) {
    _allRemedies.removeWhere((r) => r.id == id);
    _consumedDates.remove(id);
    NotificationService().cancelNotification(id);
    _saveDataLocally();
    _saveChecklistLocally();
    notifyListeners();
  }

  void _scheduleNotification(Remedy remedy) {
    if (remedy.reminderMinutes != null) {
      final timeParts = remedy.hour.split(':');
      NotificationService().scheduleRemedyNotification(
        id: remedy.id,
        title: 'Hora do seu remédio!',
        body: '${remedy.name} - ${remedy.dosage}',
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
        daysOfWeek: remedy.daysOfWeek,
        reminderMinutes: remedy.reminderMinutes!,
      );
    }
  }
}
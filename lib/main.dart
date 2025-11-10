// main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:html' as html;

// Notification and Sound Service for Web
class AlarmNotificationService {
  static final Map<int, Timer> _activeTimers = {};
  static html.AudioElement? _audioPlayer;

  static void initialize() {
    // Pre-load audio element
    _audioPlayer = html.AudioElement();
  }

  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Function() onAlarmTriggered,
  }) async {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.isNegative) return;

    // Cancel existing timer for this ID if any
    _activeTimers[id]?.cancel();

    // Schedule new timer
    _activeTimers[id] = Timer(difference, () {
      _triggerAlarm(title, body);
      onAlarmTriggered();
    });
  }

  static void _triggerAlarm(String title, String body) {
    // Play alarm sound - using a web-compatible sound URL
    _playAlarmSound();

    // Show browser notification if permission granted
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    } else if (html.Notification.permission != 'denied') {
      html.Notification.requestPermission().then((permission) {
        if (permission == 'granted') {
          html.Notification(title, body: body);
        }
      });
    }
  }

  static void _playAlarmSound() {
    try {
      // Using a free alarm sound from a reliable CDN
      _audioPlayer?.src =
          'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3';
      _audioPlayer?.loop = true;
      _audioPlayer?.volume = 1.0;
      _audioPlayer?.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  static void stopAlarmSound() {
    _audioPlayer?.pause();
    _audioPlayer?.currentTime = 0;
  }

  static void cancelAlarm(int id) {
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);
  }

  static void cancelAllAlarms() {
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    stopAlarmSound();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AlarmNotificationService.initialize();

  // Request notification permission on startup
  html.Notification.requestPermission();

  runApp(const AlarmApp());
}

class AlarmApp extends StatelessWidget {
  const AlarmApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AlarmHomePage(),
    );
  }
}

class Alarm {
  final String id;
  final TimeOfDay time;
  final String label;
  bool isActive;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    this.isActive = true,
  });
}

class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({Key? key}) : super(key: key);

  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  List<Alarm> alarms = [];
  Alarm? _ringingAlarm;

  @override
  void dispose() {
    AlarmNotificationService.cancelAllAlarms();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm App'),
        elevation: 2,
        actions: [
          if (_ringingAlarm != null)
            IconButton(
              icon: const Icon(Icons.notifications_active, color: Colors.red),
              onPressed: _showRingingAlarmDialog,
              tooltip: 'Alarm Ringing!',
            ),
        ],
      ),
      body: Stack(
        children: [
          alarms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.alarm, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No alarms set',
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add an alarm',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = alarms[index];
                    final isRinging = _ringingAlarm?.id == alarm.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: isRinging ? Colors.red.shade50 : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          isRinging ? Icons.notifications_active : Icons.alarm,
                          size: 40,
                          color: isRinging
                              ? Colors.red
                              : (alarm.isActive ? Colors.blue : Colors.grey),
                        ),
                        title: Text(
                          _formatTime(alarm.time),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isRinging ? Colors.red : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alarm.label,
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (alarm.isActive)
                              Text(
                                _getTimeUntilAlarm(alarm.time),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isRinging)
                              ElevatedButton(
                                onPressed: () => _dismissAlarm(alarm),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('DISMISS'),
                              )
                            else ...[
                              Switch(
                                value: alarm.isActive,
                                onChanged: (value) {
                                  setState(() {
                                    alarm.isActive = value;
                                    if (value) {
                                      _scheduleAlarm(alarm);
                                    } else {
                                      _cancelAlarm(alarm);
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteAlarm(alarm);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getTimeUntilAlarm(TimeOfDay time) {
    final now = DateTime.now();
    var alarmTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    final difference = alarmTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return 'Rings in ${hours}h ${minutes}m';
    } else {
      return 'Rings in ${minutes}m';
    }
  }

  Future<void> _addAlarm() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final TextEditingController labelController = TextEditingController();

    if (!mounted) return;

    final String? label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alarm Label'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(
            hintText: 'Enter alarm label',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, labelController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (label == null) return;

    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: pickedTime,
      label: label.isEmpty ? 'Alarm' : label,
    );

    setState(() {
      alarms.add(alarm);
    });

    await _scheduleAlarm(alarm);
  }

  Future<void> _scheduleAlarm(Alarm alarm) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await AlarmNotificationService.scheduleAlarm(
      id: int.parse(alarm.id),
      title: '⏰ Alarm',
      body: alarm.label,
      scheduledTime: scheduledDate,
      onAlarmTriggered: () {
        setState(() {
          _ringingAlarm = alarm;
        });
        _showRingingAlarmDialog();
      },
    );

    if (mounted) {
      final timeUntil = scheduledDate.difference(now);
      final hours = timeUntil.inHours;
      final minutes = timeUntil.inMinutes.remainder(60);

      String timeMessage = 'Alarm set for ${_formatTime(alarm.time)}';
      if (hours > 0) {
        timeMessage += ' (in ${hours}h ${minutes}m)';
      } else {
        timeMessage += ' (in ${minutes}m)';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(timeMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showRingingAlarmDialog() {
    if (_ringingAlarm == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: const [
            Icon(Icons.alarm, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('ALARM!', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(_ringingAlarm!.time),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _ringingAlarm!.label,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _snoozeAlarm(_ringingAlarm!);
              Navigator.pop(context);
            },
            child: const Text('SNOOZE (5 min)'),
          ),
          ElevatedButton(
            onPressed: () {
              _dismissAlarm(_ringingAlarm!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DISMISS'),
          ),
        ],
      ),
    );
  }

  void _dismissAlarm(Alarm alarm) {
    AlarmNotificationService.stopAlarmSound();
    setState(() {
      alarm.isActive = false;
      _ringingAlarm = null;
    });
    _cancelAlarm(alarm);
  }

  void _snoozeAlarm(Alarm alarm) {
    AlarmNotificationService.stopAlarmSound();

    final now = DateTime.now();
    final snoozeTime = now.add(const Duration(minutes: 5));

    AlarmNotificationService.scheduleAlarm(
      id: int.parse(alarm.id),
      title: '⏰ Alarm (Snoozed)',
      body: alarm.label,
      scheduledTime: snoozeTime,
      onAlarmTriggered: () {
        setState(() {
          _ringingAlarm = alarm;
        });
        _showRingingAlarmDialog();
      },
    );

    setState(() {
      _ringingAlarm = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm snoozed for 5 minutes'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _cancelAlarm(Alarm alarm) async {
    AlarmNotificationService.cancelAlarm(int.parse(alarm.id));
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    await _cancelAlarm(alarm);
    setState(() {
      alarms.remove(alarm);
      if (_ringingAlarm?.id == alarm.id) {
        _ringingAlarm = null;
        AlarmNotificationService.stopAlarmSound();
      }
    });
  }
}

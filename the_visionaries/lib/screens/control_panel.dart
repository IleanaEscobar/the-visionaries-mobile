import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  bool isOn = false;
  double fanSpeed = 0.0;
  double lastSpeed = 50.0;

  bool isConnecting = false;
  bool isConnected = false;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _speedChar;

  static const String deviceName = 'NanoESP32Fan';
  static final Guid serviceUuid = Guid('12345678-1234-1234-1234-1234567890ab');
  static final Guid speedCharUuid = Guid(
    'abcdefab-1234-1234-1234-abcdefabcdef',
  );

  static const Color _fanButtonColor = Color(0xFF065791);
  static const Color _unselectedButtonColor = Color(0xFFFFFFFF);

  @override
  void dispose() {
    _device?.disconnect();
    super.dispose();
  }

  Future<void> connectBle() async {
    setState(() => isConnecting = true);

    ScanResult? found;
    final sub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.device.platformName == deviceName) {
          found = r;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
      await Future.delayed(const Duration(seconds: 6));
      await FlutterBluePlus.stopScan();

      if (found == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('BLE device not found')));
        return;
      }

      _device = found!.device;
      await _device!.connect(timeout: const Duration(seconds: 8));

      final services = await _device!.discoverServices();
      for (final s in services) {
        if (s.uuid == serviceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid == speedCharUuid) {
              _speedChar = c;
              break;
            }
          }
        }
      }

      if (_speedChar == null) {
        throw Exception('Speed characteristic not found');
      }

      setState(() => isConnected = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('BLE error: $e')));
    } finally {
      await sub.cancel();
      if (mounted) setState(() => isConnecting = false);
    }
  }

  Future<void> sendFanSpeedBle(double speed) async {
    if (_speedChar == null) return;
    final v = speed.clamp(0, 100).round();
    await _speedChar!.write([v], withoutResponse: true);
  }

  Future<void> setFanPreset(double speed) async {
    setState(() {
      fanSpeed = speed;
      lastSpeed = speed;
      isOn = speed > 0;
    });
    await sendFanSpeedBle(speed);
  }

  Future<void> togglePower() async {
    setState(() {
      if (isOn) {
        if (fanSpeed > 0) lastSpeed = fanSpeed;
        fanSpeed = 0;
        isOn = false;
      } else {
        fanSpeed = lastSpeed;
        isOn = fanSpeed > 0;
      }
    });
    await sendFanSpeedBle(fanSpeed);
  }

  Widget _buildSpeedButton({
    required String label,
    required double speed,
    required bool enabled,
  }) {
    final isSelected = isOn && fanSpeed.round() == speed.round();

    return Center(
      child: SizedBox(
        width: 96,
        height: 96,
        child: ElevatedButton(
          onPressed: enabled ? () => setFanPreset(speed) : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            side: const BorderSide(color: _fanButtonColor, width: 1),
            backgroundColor: isSelected
                ? _fanButtonColor
                : _unselectedButtonColor,
            foregroundColor: isSelected ? Colors.white : _fanButtonColor,
            padding: EdgeInsets.zero,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Temporarily commented out BLE-only UI for local button testing.
            Text(
              isConnected ? 'BLE: Connected' : 'BLE: Disconnected',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isConnecting
                  ? null
                  : () async {
                      if (!isConnected) {
                        await connectBle();
                      } else {
                        await _device?.disconnect();
                        setState(() {
                          isConnected = false;
                          _speedChar = null;
                        });
                      }
                    },
              child: Text(isConnected ? 'Disconnect BLE' : 'Connect BLE'),
            ),
            const SizedBox(height: 24),
            _buildSpeedButton(label: 'High', speed: 100, enabled: isConnected),
            const SizedBox(height: 12),
            _buildSpeedButton(label: 'Medium', speed: 60, enabled: isConnected),
            const SizedBox(height: 12),
            _buildSpeedButton(label: 'Low', speed: 30, enabled: isConnected),

            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: isConnected ? togglePower : null,
                child: Text(isOn ? 'Off' : 'On'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

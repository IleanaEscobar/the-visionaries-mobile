import 'dart:async';
import 'package:flutter/material.dart';
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

  // temp name
  static const String deviceName = 'NanoESP32_Fan';
  static final Guid serviceUuid = Guid('12345678-1234-1234-1234-1234567890ab');
  static final Guid speedCharUuid = Guid(
    'abcdefab-1234-1234-1234-abcdefabcdef',
  );

  static const Color _fanButtonColor = Color(0xFF065791);
  static const Color _unselectedButtonColor = Color(0xFFFFFFFF);

  Future<BluetoothDevice?> _scanForNamedDevice({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final completer = Completer<BluetoothDevice?>();

    final sub = FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        if (r.device.platformName == deviceName && !completer.isCompleted) {
          completer.complete(r.device);
          break;
        }
      }
    });

    await FlutterBluePlus.startScan();

    final found = await completer.future.timeout(
      timeout,
      onTimeout: () => null,
    );

    await FlutterBluePlus.stopScan();
    await sub.cancel();

    return found;
  }

  Future<void> connectBle() async {
    setState(() => isConnecting = true);

    try {
      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Bluetooth adapter not ready'),
          );

      // Auto-connect by hardcoded device name
      final picked = await _scanForNamedDevice();
      if (!mounted) return;

      if (picked == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device "$deviceName" not found')),
        );
        return;
      }

      _device = picked;
      await _device!.connect(timeout: const Duration(seconds: 8));

      _device!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected && mounted) {
          setState(() {
            isConnected = false;
            _speedChar = null;
            isOn = false;
          });
        }
      });

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
        throw Exception(
          'Selected device does not expose required fan characteristic',
        );
      }

      setState(() => isConnected = true);
    } catch (e) {
      await FlutterBluePlus.stopScan();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('BLE error: $e')));
    } finally {
      if (mounted) setState(() => isConnecting = false);
    }
  }

  String _speedToCommand(double speed) {
    final v = speed.round();
    if (v <= 0) return 'OFF';
    if (v >= 90) return 'HIGH'; // High button (100)
    if (v >= 45) return 'MED'; // Medium button (60)
    return 'LOW'; // Low button (30)
  }

  Future<void> sendFanSpeedBle(double speed) async {
    if (_speedChar == null) return;
    final command = _speedToCommand(speed);
    await _speedChar!.write(command.codeUnits, withoutResponse: false);
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

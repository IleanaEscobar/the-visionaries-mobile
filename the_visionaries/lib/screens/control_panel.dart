import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/app_language.dart';
import '../services/app_theme.dart';
import 'settings_menu_screen.dart';

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
  bool _dismissedNoBlePopupForDev = false;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _speedChar;

  // temp name
  static const String deviceName = 'NanoESP32_Fan';
  static final Guid serviceUuid = Guid('12345678-1234-1234-1234-1234567890ab');
  static final Guid speedCharUuid = Guid(
    'abcdefab-1234-1234-1234-abcdefabcdef',
  );

  Future<void> _handleBleTap() async {
    if (isConnecting) return;
    if (!isConnected) {
      await connectBle();
    } else {
      await _device?.disconnect();
      if (!mounted) return;
      setState(() {
        isConnected = false;
        _speedChar = null;
      });
    }
  }

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
          SnackBar(
            content: Text(
              context.tr(
                'device_not_found',
                params: {'deviceName': deviceName},
              ),
            ),
          ),
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
            _dismissedNoBlePopupForDev = false;
          });
        }
      });
      // hello world

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

      setState(() {
        isConnected = true;
        _dismissedNoBlePopupForDev = false;
      });
    } catch (e) {
      await FlutterBluePlus.stopScan();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('ble_error', params: {'error': '$e'})),
        ),
      );
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
    required bool isDark,
  }) {
    final isSelected = isOn && fanSpeed.round() == speed.round();
    final baseBackground = isDark
        ? const Color(0xFF1F2126)
        : const Color(0xFFDCE6F2);
    final selectedBackground = isDark
        ? const Color(0xFF2A4D7E)
        : const Color(0xFFB9D4F1);
    final textColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark
        ? const Color(0x00000000)
        : const Color(0x1F4A7FAF);

    return Center(
      child: SizedBox(
        width: 300,
        height: 74,
        child: ElevatedButton(
          onPressed: enabled ? () => setFanPreset(speed) : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: isSelected ? selectedBackground : baseBackground,
            foregroundColor: textColor,
            disabledBackgroundColor: isSelected
                ? selectedBackground.withValues(alpha: 0.65)
                : baseBackground.withValues(alpha: 0.65),
            disabledForegroundColor: textColor.withValues(alpha: 0.6),
            elevation: 0,
            shadowColor: shadowColor,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40 / 2,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bleConnectedText = context.tr('ble_connected');
    final bleDisconnectedText = context.tr('ble_disconnected');
    final highText = context.tr('speed_high');
    final mediumText = context.tr('speed_medium');
    final lowText = context.tr('speed_low');
    final fanStatusLabel = context.tr('fan_status_label');
    final fanStatusOn = context.tr('fan_status_on');
    final fanStatusOff = context.tr('fan_status_off');
    final popupMessageText = context.tr('control_popup_message');
    final popupConnectText = context.tr('control_popup_connect_device');
    final popupSkipText = context.tr('control_popup_skip_dev');
    final showNoBlePopup = !isConnected && !_dismissedNoBlePopupForDev;
    final isDark = context.appTheme.isDark;

    final backgroundColor = isDark
        ? const Color(0xFF3A3B3F)
        : const Color(0xFFEAF4FC);
    final cardShadow = isDark
        ? const Color(0x00000000)
        : const Color(0x1F4A7FAF);
    final headingColor = isDark
        ? const Color(0xFFE8EFF8)
        : const Color(0xFF637382);
    final iconColor = isDark
        ? const Color(0xFFD8E8F9)
        : const Color(0xFF1A69B2);
    final powerBg = isDark ? const Color(0xFF202226) : const Color(0xFFDCE6F2);
    final powerIcon = isDark
        ? const Color(0xFF8D9298)
        : const Color(0xFF2E69BA);
    final bleColor = isConnected
        ? (isDark ? const Color(0xFFE4F4FF) : const Color(0xFF1C84D3))
        : (isDark ? const Color(0xFF9FA6AE) : const Color(0xFF7B90A8));
    final fanStatusText =
        '$fanStatusLabel: ${isOn ? fanStatusOn : fanStatusOff}';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 240,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFFEBEDF0)
                              : const Color(0xFF1E549A),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                left: isDark ? 120.0 : 5.0,
                                top: 2.5,
                                child: Container(
                                  width: 115,
                                  height: 59,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1F2126)
                                        : const Color(0xFFBFD8F1),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () =>
                                          context.appTheme.setDark(false),
                                      child: Center(
                                        child: Icon(
                                          Icons.wb_sunny_outlined,
                                          color: isDark
                                              ? const Color(0xFF1B1F24)
                                              : const Color(0xFF1F6CC0),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () =>
                                          context.appTheme.setDark(true),
                                      child: Center(
                                        child: Icon(
                                          Icons.nightlight_round,
                                          color: isDark
                                              ? const Color(0xFFE4EEF9)
                                              : const Color(0xFFE8F1FB),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        fanStatusText,
                        style: TextStyle(
                          color: headingColor,
                          fontSize: 23 / 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSpeedButton(
                        label: lowText,
                        speed: 30,
                        enabled: isConnected,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildSpeedButton(
                        label: mediumText,
                        speed: 60,
                        enabled: isConnected,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildSpeedButton(
                        label: highText,
                        speed: 100,
                        enabled: isConnected,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: 98,
                        height: 98,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: powerBg,
                            boxShadow: [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: isConnected ? togglePower : null,
                            iconSize: 52,
                            color: powerIcon,
                            disabledColor: powerIcon.withValues(alpha: 0.5),
                            icon: const Icon(Icons.power_settings_new),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: _handleBleTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.circle, size: 12, color: bleColor),
                              const SizedBox(width: 10),
                              Text(
                                isConnected
                                    ? bleConnectedText
                                    : bleDisconnectedText,
                                style: TextStyle(
                                  color: bleColor,
                                  fontSize: 27 / 2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.bluetooth, color: bleColor, size: 26),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (_) => false);
                        },
                        child: const Text('DEV: Back to Start'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 51,
            left: 38,
            width: 38,
            height: 20,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsMenuScreen()),
              ),
              child: Icon(Icons.menu, color: iconColor, size: 33),
            ),
          ),
          if (showNoBlePopup) ...[
            const Positioned.fill(
              child: ModalBarrier(dismissible: false, color: Color(0x993F6E99)),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FC),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bluetooth,
                        size: 78,
                        color: Color(0xFF065791),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        popupMessageText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B2140),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: isConnecting ? null : connectBle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4A8C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: isConnecting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  popupConnectText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() => _dismissedNoBlePopupForDev = true);
                        },
                        child: Text(popupSkipText),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (_) => false);
                        },
                        child: const Text('DEV: Back to Start'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

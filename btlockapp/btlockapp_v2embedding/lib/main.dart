import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fingerprint Bluetooth Lock',
      home: const LockScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  LockScreenState createState() => LockScreenState();
}

class LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  BluetoothConnection? connection;

  bool isAuthenticated = false;
  bool isConnecting = false;

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to unlock the Bluetooth device',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      setState(() {
        isAuthenticated = didAuthenticate;
      });

      if (didAuthenticate) {
        debugPrint('Fingerprint authenticated');
        _connectToBluetooth();
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
    }
  }

  void _connectToBluetooth() async {
    setState(() {
      isConnecting = true;
    });

    try {
      final device = BluetoothDevice(
        name: "HC-05",
        address: "00:00:00:00:00:00",
        type: BluetoothDeviceType.classic,
      );

      connection = await BluetoothConnection.toAddress(device.address);
      debugPrint('Connected to Bluetooth device');

      connection?.input?.listen((data) {
        debugPrint('Received data: ${String.fromCharCodes(data)}');
      });
    } catch (e) {
      debugPrint('Bluetooth connection error: $e');
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Bluetooth Lock'),
      ),
      body: Center(
        child: isAuthenticated
            ? const Text("Unlocked!", style: TextStyle(fontSize: 24))
            : ElevatedButton(
                onPressed: _authenticate,
                child: isConnecting
                    ? const CircularProgressIndicator()
                    : const Text('Unlock with Fingerprint'),
              ),
      ),
    );
  }
}

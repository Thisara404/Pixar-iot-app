import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import '../models/led_state.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _ipController = TextEditingController();

  bool _ledState = false;
  bool _isLoading = false;
  bool _isConnected = false;
  String _statusMessage = 'Not connected';
  String _lastMessage = '';

  late AnimationController _ledAnimationController;
  late Animation<double> _ledAnimation;

  @override
  void initState() {
    super.initState();
    _ipController.text = '192.168.1.100';
    _checkConnection();

    _ledAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ledAnimation = Tween<double>(begin: 150, end: 160).animate(
      CurvedAnimation(parent: _ledAnimationController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _ledAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    setState(() => _isLoading = true);
    _apiService.setBaseUrl(_ipController.text.trim());
    final isConnected = await _apiService.testConnection();

    setState(() {
      _isConnected = isConnected;
      _statusMessage = isConnected ? 'Connected to NodeMCU' : 'Connection failed';
      _isLoading = false;
    });

    if (isConnected) _getLedStatus();
  }

  Future<void> _getLedStatus() async {
    setState(() => _isLoading = true);
    final ledState = await _apiService.getLedStatus();
    setState(() {
      _isLoading = false;
      if (ledState != null) {
        _ledState = ledState.ledState;
        _lastMessage = ledState.message;
        _isConnected = true;
        _statusMessage = 'Connected to NodeMCU';
        if (_ledState) _ledAnimationController.forward();
        else _ledAnimationController.reverse();
      } else {
        _isConnected = false;
        _statusMessage = 'Failed to get LED status';
      }
    });
  }

  Future<void> _turnLedOn() async {
    setState(() => _isLoading = true);
    final ledState = await _apiService.turnLedOn();
    setState(() {
      _isLoading = false;
      if (ledState != null) {
        _ledState = ledState.ledState;
        _lastMessage = ledState.message;
        _isConnected = true;
        _statusMessage = 'Connected to NodeMCU';
        _ledAnimationController.forward();
      } else {
        _isConnected = false;
        _statusMessage = 'Failed to turn LED ON';
      }
    });
  }

  Future<void> _turnLedOff() async {
    setState(() => _isLoading = true);
    final ledState = await _apiService.turnLedOff();
    setState(() {
      _isLoading = false;
      if (ledState != null) {
        _ledState = ledState.ledState;
        _lastMessage = ledState.message;
        _isConnected = true;
        _statusMessage = 'Connected to NodeMCU';
        _ledAnimationController.reverse();
      } else {
        _isConnected = false;
        _statusMessage = 'Failed to turn LED OFF';
      }
    });
  }

  void _showIpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('NodeMCU IP Address', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _ipController,
            decoration: InputDecoration(
              labelText: 'IP Address',
              hintText: '192.168.1.100',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkConnection();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Connect', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple[700]!, Colors.blue[400]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LED Control',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: _showIpDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _ledAnimationController,
                          builder: (context, child) {
                            return GestureDetector(
                              onTap: _isConnected && !_isLoading ? _getLedStatus : null,
                              child: Container(
                                width: _ledAnimation.value,
                                height: _ledAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _ledState
                                      ? RadialGradient(colors: [Colors.green[300]!, Colors.green[700]!])
                                      : RadialGradient(colors: [Colors.grey[300]!, Colors.grey[600]!]),
                                  boxShadow: _ledState
                                      ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 20)]
                                      : [],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.lightbulb,
                                    size: 60,
                                    color: _ledState ? Colors.yellow[100] : Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'LED is ${_ledState ? 'ON' : 'OFF'}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _ledState ? Colors.green[700] : Colors.grey[700],
                          ),
                        ),
                        if (_lastMessage.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _lastMessage,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading || !_isConnected ? null : _turnLedOn,
                              icon: _isLoading && _ledState
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.power_settings_new),
                              label: const Text('Turn ON'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isLoading || !_isConnected ? null : _turnLedOff,
                              icon: _isLoading && !_ledState
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.power_off),
                              label: const Text('Turn OFF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _getLedStatus,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.refresh),
                          label: const Text('Check Status'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isConnected ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isConnected ? Icons.wifi : Icons.wifi_off,
                                color: _isConnected ? Colors.green[700] : Colors.red[700],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _statusMessage,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isConnected ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
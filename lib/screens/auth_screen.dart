import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/network_provider.dart';
import '/models/instance_configiration_provider.dart';
import '/helpers/app_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Properties

  var _instanceConfigured = true;

  // Private methods

  void _checkInstanceConfiguration() async {
    final provider =
        Provider.of<InstanceConfigurationProvider>(context, listen: false);
    final baseUrl = await provider.baseUrl;
    final clientId = await provider.clientId;
    final isConfigured = baseUrl != null &&
        baseUrl.isNotEmpty &&
        clientId != null &&
        clientId.isNotEmpty;
    setState(() {
      _instanceConfigured = isConfigured;
    });
  }

  // Lifecycle

  @override
  void initState() {
    super.initState();
    _checkInstanceConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/open_project_logo.png'),
              Column(
                children: [
                  CupertinoButton.filled(
                    onPressed: _instanceConfigured
                        ? Provider.of<NetworkProvider>(context, listen: false)
                            .authorize
                        : null,
                    child: const Text('Log in'),
                  ),
                  CupertinoButton(
                    onPressed: () => AppRouter.routeToInstanceConfiguration(
                      context: context,
                      completion: _checkInstanceConfiguration,
                    ),
                    child: const Text('Configure instance'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

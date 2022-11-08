import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/instance_configiration_provider.dart';

class InstanceConfigurationScreen extends StatefulWidget {
  // Properties
  final Function completion;

  const InstanceConfigurationScreen(this.completion, {super.key});

  @override
  State<InstanceConfigurationScreen> createState() =>
      _InstanceConfigurationScreenState();
}

class _InstanceConfigurationScreenState
    extends State<InstanceConfigurationScreen> {
  final _form = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _clientIdController = TextEditingController();

  // Private methods
  void _save() async {
    _form.currentState?.save();
    widget.completion();
  }

  void _setInitialData() async {
    final provider =
        Provider.of<InstanceConfigurationProvider>(context, listen: false);
    final baseUrl = await provider.baseUrl ?? '';
    final clientId = await provider.clientId ?? '';
    setState(() {
      _baseUrlController.text = baseUrl;
      _clientIdController.text = clientId;
    });
  }

  // Lifecycle

  @override
  void initState() {
    super.initState();
    _setInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Instance Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(labelText: 'Base URL'),
                      onSaved: (newValue) =>
                          Provider.of<InstanceConfigurationProvider>(context,
                                  listen: false)
                              .setBaseUrl(newValue),
                    ),
                    TextFormField(
                      controller: _clientIdController,
                      decoration: const InputDecoration(labelText: 'Client ID'),
                      onSaved: (newValue) =>
                          Provider.of<InstanceConfigurationProvider>(context,
                                  listen: false)
                              .setClientId(newValue),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

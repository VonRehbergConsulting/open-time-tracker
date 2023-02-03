import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/instance_configuration/instance_configuration_bloc.dart';

// ignore: must_be_immutable
class InstanceConfigurationPage extends EffectBlocPage<
    InstanceConfigurationBloc,
    InstanceConfigurationState,
    InstanceConfigurationEffect> {
  final _form = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _clientIdController = TextEditingController();

  String _baseUrl = '';
  String _clientID = '';

  final Function completion;

  InstanceConfigurationPage(this.completion);

  void _save(BuildContext context) async {
    _form.currentState?.save();
    context.read<InstanceConfigurationBloc>().saveData(_baseUrl, _clientID);
  }

  @override
  void onEffect(BuildContext context, InstanceConfigurationEffect effect) {
    effect.when(
      update: (baseUrl, clientID) {
        _baseUrlController.text = baseUrl;
        _clientIdController.text = clientID;
      },
      complete: () {
        completion();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildState(BuildContext context, InstanceConfigurationState state) {
    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.35;

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
                      onSaved: (newValue) => _baseUrl = newValue ?? '',
                    ),
                    TextFormField(
                      controller: _clientIdController,
                      decoration: const InputDecoration(labelText: 'Client ID'),
                      onSaved: (newValue) => _clientID = newValue ?? '',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => _save(context),
                  child: const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

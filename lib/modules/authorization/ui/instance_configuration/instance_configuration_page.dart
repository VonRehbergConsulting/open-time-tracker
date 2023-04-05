import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/filled_button.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/instance_configuration/instance_configuration_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final buttonWidth = deviceSize.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).instance_configuration_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _baseUrlController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .instance_configuration_base_url),
                    onSaved: (newValue) => _baseUrl = newValue ?? '',
                  ),
                  TextFormField(
                    controller: _clientIdController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .instance_configuration_client_id),
                    onSaved: (newValue) => _clientID = newValue ?? '',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: SizedBox(
                width: buttonWidth,
                child: FilledButton(
                  onPressed: () => _save(context),
                  text: AppLocalizations.of(context).generic_save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

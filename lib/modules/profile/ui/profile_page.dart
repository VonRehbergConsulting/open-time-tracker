import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/asset_images.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_card.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/modules/profile/ui/profile_bloc.dart';

class ProfilePage
    extends EffectBlocPage<ProfileBloc, ProfileState, ProfileEffect> {
  const ProfilePage({super.key});

  @override
  void onEffect(BuildContext context, ProfileEffect effect) {
    effect.when(
      logout: () {
        // Pop the profile page so AppRouter can navigate to login
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildGradientUserCard(BuildContext context, String? userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ConfiguredCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color.fromRGBO(33, 147, 147, 1),
                Theme.of(context).primaryColor,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? AppLocalizations.of(context).profile_title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).profile_subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildState(BuildContext context, ProfileState state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).profile_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card with Gradient
            _buildGradientUserCard(context, state.userName),

            const SizedBox(height: 24),

            // Calendar Integration Section
            _buildSectionTitle(
              context,
              AppLocalizations.of(context).calendar_title,
            ),
            const SizedBox(height: 8),
            _buildCalendarTile(context, state),

            const SizedBox(height: 24),

            // Project Filters Section
            _buildSectionTitle(
              context,
              AppLocalizations.of(context).profile_project_filters_title,
            ),
            const SizedBox(height: 8),
            _buildProjectFiltersTile(context, state),

            const SizedBox(height: 24),

            // Logout Section
            _buildSectionTitle(
              context,
              AppLocalizations.of(context).profile_logout_title,
            ),
            const SizedBox(height: 8),
            _buildLogoutTile(context),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCalendarTile(BuildContext context, ProfileState state) {
    return ConfiguredCard(
      child: ListTile(
        leading: SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(AssetImages.microsoftCalendar),
        ),
        title: Text(
          state.isCalendarConnected
              ? AppLocalizations.of(context).profile_calendar_connected
              : AppLocalizations.of(context).profile_calendar_disconnected,
        ),
        subtitle: Text(
          state.isCalendarConnected
              ? AppLocalizations.of(context).calendar_disconnect
              : AppLocalizations.of(context).calendar_connect,
          style: TextStyle(
            color: state.isCalendarConnected ? Colors.green : Colors.grey,
          ),
        ),
        trailing: Icon(
          state.isCalendarConnected
              ? Icons.check_circle
              : Icons.circle_outlined,
          color: state.isCalendarConnected ? Colors.green : Colors.grey,
        ),
        onTap: state.isCalendarConnected
            ? context.read<ProfileBloc>().disconnectCalendar
            : context.read<ProfileBloc>().connectCalendar,
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ConfiguredCard(
      child: ListTile(
        leading: const Icon(Icons.logout, size: 40, color: Colors.red),
        title: Text(AppLocalizations.of(context).profile_logout_description),
        trailing: const Icon(Icons.chevron_right),
        onTap: context.read<ProfileBloc>().logout,
      ),
    );
  }

  Widget _buildProjectFiltersTile(BuildContext context, ProfileState state) {
    return ConfiguredCard(
      child: Column(
        children: [
          SwitchListTile(
            value: state.showOnlyProjectsWithTasks,
            title: Text(
              AppLocalizations.of(context)
                  .profile_project_filters_only_with_tasks,
            ),
            onChanged: context.read<ProfileBloc>().setShowOnlyProjectsWithTasks,
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: state.doNotLoadProjectList,
            title: Text(
              AppLocalizations.of(context).profile_project_filters_lazy_load,
            ),
            onChanged: context.read<ProfileBloc>().setDoNotLoadProjectList,
          ),
        ],
      ),
    );
  }
}

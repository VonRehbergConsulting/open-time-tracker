// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get generic_error => 'Algo salió mal';

  @override
  String get generic_save => 'Guardar';

  @override
  String get generic_yes => 'Sí';

  @override
  String get generic_no => 'No';

  @override
  String get generic_warning => 'Advertencia';

  @override
  String get generic_retry => 'Reintentar';

  @override
  String get generic_total => 'Total';

  @override
  String get generic_monday_short => 'Lun';

  @override
  String get generic_tuesday_short => 'Mar';

  @override
  String get generic_wednesday_short => 'Mié';

  @override
  String get generic_thursday_short => 'Jue';

  @override
  String get generic_friday_short => 'Vie';

  @override
  String get generic_saturday_short => 'Sáb';

  @override
  String get generic_sunday_short => 'Dom';

  @override
  String get generic_deletion_warning =>
      'Tus datos se eliminarán permanentemente';

  @override
  String get generic__in_progress => 'En curso';

  @override
  String get generic_accept => 'Aceptar';

  @override
  String get generic_decline => 'Rechazar';

  @override
  String get generic_today => 'Hoy';

  @override
  String get generic_yesterday => 'Ayer';

  @override
  String get authorization_log_in => 'Iniciar sesión';

  @override
  String get authorization_configure_instance => 'Configurar instancia';

  @override
  String get instance_configuration_title => 'Configuración de instancia';

  @override
  String get instance_configuration_base_url => 'URL base';

  @override
  String get instance_configuration_client_id => 'ID de cliente';

  @override
  String get instance_configuration__invalid_url => 'La URL no es válida';

  @override
  String get time_entries_list_title => 'Registros de tiempo';

  @override
  String get time_entries_list_change_working_hours =>
      'Cambiar horas de trabajo';

  @override
  String get time_entries_list_empty => 'No hay trabajo registrado hoy';

  @override
  String get work_package_list_empty => 'No hay tareas';

  @override
  String get work_packages_filter__title => 'Filtros';

  @override
  String get analytics_title => 'Analíticas';

  @override
  String get analytics_empty => 'No hay tiempo registrado esta semana';

  @override
  String get analytics_weekdays_title => 'Distribución por días';

  @override
  String get analytics_projects_title => 'Distribución por proyectos';

  @override
  String get time_entry_summary_title => 'Resumen';

  @override
  String get time_entry_summary_task => 'Tarea';

  @override
  String get time_entry_summary_project => 'Proyecto';

  @override
  String get time_entry_summary_time_spent => 'Tiempo dedicado';

  @override
  String get time_entry_summary_comment => 'Comentario';

  @override
  String get timer_warning =>
      'Tus cambios actuales no se guardarán. ¿Continuar?';

  @override
  String get timer_start => 'Iniciar';

  @override
  String get timer_pause => 'Pausar';

  @override
  String get timer_resume => 'Reanudar';

  @override
  String get timer_finish => 'Finalizar';

  @override
  String get timer_add_5_min => '+5 min';

  @override
  String get timer_add_15_min => '+15 min';

  @override
  String get timer_add_30_min => '+30 min';

  @override
  String get comment_suggestions_title => 'Elige un comentario';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_subtitle => 'Administra tu cuenta';

  @override
  String get profile_calendar_connected => 'Conectado';

  @override
  String get profile_calendar_disconnected => 'No conectado';

  @override
  String get profile_logout_title => 'Cerrar sesión';

  @override
  String get profile_logout_description => 'Cerrar sesión de tu cuenta';

  @override
  String get profile_logout_button => 'Cerrar sesión';

  @override
  String get calendar_title => 'Notificaciones del calendario';

  @override
  String get calendar_connect => 'Conectar calendario';

  @override
  String get calendar_disconnect => 'Desconectar calendario';

  @override
  String get notifications_calendar_title => 'La reunión está por comenzar';

  @override
  String get notifications_calendar_body =>
      'Abrir para iniciar un temporizador';

  @override
  String get notification_selection_list__title => 'Elegir tarea';

  @override
  String get notification_selection_list__time_entries_header =>
      'Trabajo reciente';

  @override
  String get notification_selection_list__work_packages_header =>
      'Tareas activas';

  @override
  String get projects_list__title => 'Proyectos';

  @override
  String get projects_list__updated_at => 'Actualizado';

  @override
  String get analytics_consent_request__title => 'Compartir datos técnicos';

  @override
  String get analytics_consent_request__text =>
      'Ayúdanos a mejorar la estabilidad y el rendimiento de la app compartiendo informes de fallos y datos de sesión anónimos. No se recopila información personal.';

  @override
  String get analytics_consent_request__privacy_policy =>
      'Política de privacidad';

  @override
  String get monthly_overview_title => 'Resumen mensual';

  @override
  String get monthly_overview_week => 'Semana';

  @override
  String get monthly_overview_current_week => 'Semana actual';

  @override
  String get monthly_overview_weekly => 'Semanal';

  @override
  String get monthly_overview_monthly => 'Mensual';

  @override
  String get monthly_overview_total => 'Total';

  @override
  String get weekday_monday => 'Lun';

  @override
  String get weekday_tuesday => 'Mar';

  @override
  String get weekday_wednesday => 'Mié';

  @override
  String get weekday_thursday => 'Jue';

  @override
  String get weekday_friday => 'Vie';

  @override
  String get weekday_saturday => 'Sáb';

  @override
  String get weekday_sunday => 'Dom';

  @override
  String get export_report_title => 'Exportar informe';

  @override
  String get export_report_date_range => 'Rango de fechas';

  @override
  String get export_report_start_date => 'Fecha de inicio';

  @override
  String get export_report_end_date => 'Fecha de fin';

  @override
  String get export_report_project_filter => 'Filtro de proyecto (opcional)';

  @override
  String get export_report_all_projects => 'Todos los proyectos';

  @override
  String get export_report_select_projects => 'Seleccionar proyectos';

  @override
  String get export_report_add_more_projects => 'Agregar más proyectos';

  @override
  String get export_report_search_projects => 'Buscar proyectos...';

  @override
  String get export_report_clear_selection => 'Limpiar selección';

  @override
  String get export_report_no_projects => 'No hay proyectos disponibles';

  @override
  String get export_report_format => 'Formato de exportación';

  @override
  String get export_report_xlsx => 'Exportar como Excel (XLSX)';

  @override
  String get export_report_pdf => 'Exportar como PDF';

  @override
  String get export_report_period => 'Período';

  @override
  String get export_report_column_date => 'Fecha';

  @override
  String get export_report_column_project => 'Proyecto';

  @override
  String get export_report_column_work_package => 'Paquete de trabajo';

  @override
  String get export_report_column_hours => 'Horas';

  @override
  String get export_report_column_comment => 'Comentario';

  @override
  String get export_report_pdf_summary_by_project => 'Resumen por proyecto';

  @override
  String get export_report_pdf_total_hours => 'Horas totales';

  @override
  String get export_report_excel_open_success =>
      'Informe de Excel abierto correctamente';

  @override
  String get export_report_excel_open_failed =>
      'No se pudo abrir el archivo de Excel. Revisa la configuración de tu visor de archivos.';

  @override
  String get export_report_network_fetch_failed =>
      'Error de red al obtener los registros de tiempo. Revisa tu conexión.';

  @override
  String get export_report_excel_save_failed =>
      'No se pudo guardar el archivo de Excel. Revisa los permisos de almacenamiento.';

  @override
  String get export_report_excel_export_failed =>
      'No se pudo exportar el informe de Excel. Inténtalo de nuevo.';

  @override
  String get export_report_pdf_create_success =>
      'Informe PDF creado correctamente';

  @override
  String get export_report_pdf_save_failed =>
      'No se pudo guardar el archivo PDF. Revisa los permisos de almacenamiento.';

  @override
  String get export_report_pdf_export_failed =>
      'No se pudo exportar el informe PDF. Inténtalo de nuevo.';
}

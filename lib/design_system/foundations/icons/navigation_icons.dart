import 'package:flutter/material.dart';

/// Icônes officielles de navigation de ForeverCare AI.
///
/// Toutes les icônes liées à la navigation doivent être
/// utilisées via cette classe.
abstract final class NavigationIcons {
  NavigationIcons._();

  //--------------------------------------------------------------------------
  // Navigation principale
  //--------------------------------------------------------------------------

  static const IconData home = Icons.home_rounded;

  static const IconData dashboard = Icons.dashboard_rounded;

  static const IconData menu = Icons.menu_rounded;

  static const IconData back = Icons.arrow_back_rounded;

  static const IconData forward = Icons.arrow_forward_rounded;

  static const IconData close = Icons.close_rounded;

  //--------------------------------------------------------------------------
  // Recherche
  //--------------------------------------------------------------------------

  static const IconData search = Icons.search_rounded;

  static const IconData filter = Icons.filter_list_rounded;

  static const IconData sort = Icons.sort_rounded;

  //--------------------------------------------------------------------------
  // Notifications
  //--------------------------------------------------------------------------

  static const IconData notifications = Icons.notifications_rounded;

  static const IconData notificationsOff = Icons.notifications_off_rounded;

  //--------------------------------------------------------------------------
  // Profil
  //--------------------------------------------------------------------------

  static const IconData profile = Icons.account_circle_rounded;

  static const IconData settings = Icons.settings_rounded;

  //--------------------------------------------------------------------------
  // Actions
  //--------------------------------------------------------------------------

  static const IconData add = Icons.add_rounded;

  static const IconData edit = Icons.edit_rounded;

  static const IconData delete = Icons.delete_rounded;

  static const IconData save = Icons.save_rounded;

  static const IconData refresh = Icons.refresh_rounded;

  static const IconData more = Icons.more_vert_rounded;
}

class SecurityInfoModel {
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> securitySettings;
  final Map<String, dynamic> installedApps;
  final Map<String, dynamic> accessibility;
  final Map<String, dynamic> notificationAccess;
  final Map<String, dynamic> deviceAdmins;

  const SecurityInfoModel({
    required this.deviceInfo,
    required this.securitySettings,
    required this.installedApps,
    required this.accessibility,
    required this.notificationAccess,
    required this.deviceAdmins,
  });

  factory SecurityInfoModel.fromMap(Map<String, dynamic> map) {
    return SecurityInfoModel(
      deviceInfo: Map<String, dynamic>.from(map["deviceInfo"] ?? const {}),
      securitySettings: Map<String, dynamic>.from(
        map["securitySettings"] ?? const {},
      ),
      installedApps: Map<String, dynamic>.from(
        map["installedApps"] ?? const {},
      ),
      accessibility: Map<String, dynamic>.from(
        map["accessibility"] ?? const {},
      ),
      notificationAccess: Map<String, dynamic>.from(
        map["notificationAccess"] ?? const {},
      ),
      deviceAdmins: Map<String, dynamic>.from(map["deviceAdmins"] ?? const {}),
    );
  }
}

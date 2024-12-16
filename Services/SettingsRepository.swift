class SettingsRepository {
    static let shared = SettingsRepository()
    private let dbManager: DatabaseManager? = DatabaseManager.shared
    
    private init() {}
    
    func save(settings: Settings) {
        guard let dbManager = dbManager else {
            print("Database connection is nil")
            return
        }
        dbManager.saveSettings(settings)
    }
    
    func fetchSettings() -> Settings? {
        guard let dbManager = dbManager else {
            print("Database connection is nil")
            return nil
        }
        return dbManager.fetchSettings()
    }
}

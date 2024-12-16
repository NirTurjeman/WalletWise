import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?
    
    //MARK: - Settings Db
    
    private let SettingsTable = Table("settings")
    private let settingsId = Expression<Int64>("id")
    private let monthlyLimit = Expression<Int64>("monthly_limit")
    private let language = Expression<String>("language")
    private let currency = Expression<String>("currency")
    private let notificationsEnabled = Expression<Bool>("notifications_enabled")
    
    //MARK: - Transaction Db
    private let transactions = Table("transactions")
    private let transId = Expression<Int64>("id")
    private let transAmount = Expression<Double>("amount")
    private let transDate = Expression<String>("date")
    private let transCategory = Expression<String>("category")
    private let transLocation = Expression<String>("location")
    private static let currency = Currency.USD
    private let transLastCardNums = Expression<String>("last_card_nums")
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/database.sqlite3")
            createTransactionTable()
            createSettingsTables()
        } catch {
            print("Error initializing database: \(error)")
        }
    }
    func sortTransactionsByDate(transactions: [Transaction]) -> [Transaction] {
        return transactions.sorted { $0.date < $1.date }
    }
    func sortTransactionsByAmount(transactions: [Transaction]) -> [Transaction]{
        return transactions.sorted { $0.amount > $1.amount }
    }
    private func createTransactionTable() {
        guard let db = db else { return }
        do {
            try db.run(transactions.create(ifNotExists: true) { t in
                t.column(transId, primaryKey: true)
                t.column(transCategory)
                t.column(transAmount)
                t.column(transLocation)
                t.column(transDate)
                t.column(transLastCardNums)
            })
            print("Transactions table created successfully.")
        } catch {
            print("Error creating transactions table: \(error)")
        }
    }
    
    func insertTransaction(category: String, amount: Double, location: String,lastCardNums: String) {
        guard let db = db else { return }
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            
            let insert = transactions.insert(
                transCategory <- category,
                transAmount <- amount,
                transLocation <- location,
                transDate <- dateString,
                transLastCardNums <- lastCardNums
            )
            try db.run(insert)
            print("Transaction inserted successfully.")
        } catch {
            print("Error inserting transaction: \(error)")
        }
    }
    func fetchAllTransactions() -> [Transaction] {
        var results: [Transaction] = []
        
        guard let db = db else {
            print("Database connection is nil")
            return results
        }
        
        do {
            for row in try db.prepare(transactions) {
                let transaction = Transaction(
                    id: row[transId],
                    category: row[transCategory],
                    amount: row[transAmount],
                    location: row[transLocation],
                    date: row[transDate],
                    lastCardNumber: row[transLastCardNums]
                )
                results.append(transaction)
            }
        } catch {
            print("Error fetching all transactions: \(error)")
        }
        
        return results
    }

    func fetchTransactionsByMonth(month: Int) -> [Transaction] {
        guard let db = db else { return [] }
        var results: [Transaction] = []
        
        do {
            let calendar = Calendar.current
            let now = Date()
            guard let startOfMonth = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: month)),
                  let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)?.addingTimeInterval(-1) else {
                print("Error calculating date range")
                return []
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startDateString = dateFormatter.string(from: startOfMonth)
            let endDateString = dateFormatter.string(from: endOfMonth)
            for row in try db.prepare(transactions.filter(transDate >= startDateString && transDate <= endDateString)) {
                let transaction = Transaction(
                    id: row[transId],
                    category: row[transCategory],
                    amount: row[transAmount],
                    location: row[transLocation],
                    date: row[transDate],
                    lastCardNumber: row[transLastCardNums]
                )
                results.append(transaction)
            }
        } catch {
            print("Error fetching transactions: \(error)")
        }
        
        return results
    }

    func fetchNumberOfTransactions() -> Int {
        guard let db = db else { return 0 }
        do {
            return try db.scalar(transactions.count)
        } catch {
            print("Error fetching number of transactions: \(error)")
            return 0
        }
    }
    func deleteTransaction(byId id: Int64) {
        guard let db = db else { return }
        do {
            let transaction = transactions.filter(transId == id)
            try db.run(transaction.delete())
            print("Transaction with ID \(id) deleted successfully.")
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
    static func getDefualtCurrency() -> Currency {
        return currency
    }
//MARK: - Settings Db
    func saveSettings(_ settings: Settings) {
        guard let db = db else {
            print("Database connection is nil")
            return
        }

        do {
            if try db.scalar(SettingsTable.count) > 0 {
                try db.run(SettingsTable.update(
                    monthlyLimit <- settings.monthlyLimit,
                    language <- settings.language.rawValue,
                    currency <- settings.currency.rawValue,
                    notificationsEnabled <- settings.notification
                ))
                print("Settings updated successfully!")
            } else {
                try db.run(SettingsTable.insert(
                    monthlyLimit <- settings.monthlyLimit,
                    language <- settings.language.rawValue,
                    currency <- settings.currency.rawValue,
                    notificationsEnabled <- settings.notification
                ))
                print("Settings saved successfully!")
            }
        } catch {
            print("Error saving settings: \(error)")
        }
    }

    func fetchSettings() -> Settings? {
        var result: Settings?
        
        guard let db = db else {
            print("Database connection is nil")
            return nil
        }
        
        do {
            for row in try db.prepare(SettingsTable) {
                let settings = WalletWise.Settings(
                    monthlyLimit: row[monthlyLimit],
                    language: Language(rawValue: row[language]) ?? .EN,
                    currency: Currency(rawValue: row[currency]) ?? .USD,
                    notification: row[notificationsEnabled]
                )
                result = settings
            }
        } catch {
            print("Error fetching settings: \(error)")
        }
        
        return result
    }
    private func createSettingsTables() {
        guard let db = db else { return }
        do {
            try db.run(SettingsTable.create(ifNotExists: true) { t in
                t.column(settingsId, primaryKey: true)
                t.column(currency)
                t.column(language)
                t.column(notificationsEnabled)
                t.column(monthlyLimit)
            })
            print("Settings table created successfully.")
        } catch {
            print("Error creating transactions table: \(error)")
        }
    }
}

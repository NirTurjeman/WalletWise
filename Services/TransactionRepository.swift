import Foundation

class TransactionRepository {
    static let shared = TransactionRepository()
    private let dbManager = DatabaseManager.shared

    private init() {}

    func addTransaction(category: String, amount: Double, location: String,lastCardNums: String) {
        dbManager.insertTransaction(category: category, amount: amount, location: location,lastCardNums: lastCardNums)
    }

    func getAllTransactions() -> [Transaction] {
        return dbManager.fetchAllTransactions()
    }
    func getTransactionByMonth(month: Int) -> [Transaction] {
        let allTransactions = dbManager.fetchTransactionsByMonth(month: month)
        return allTransactions
    }
    func deleteTransaction(byId id: Int64) {
        DatabaseManager.shared.deleteTransaction(byId: id)
    }
    func sortTransactionsByDate(transaction: [Transaction]) -> [Transaction] {
        return dbManager.sortTransactionsByDate(transactions: transaction)
    }

    func sortTransactionsByAmount(transaction: [Transaction]) -> [Transaction] {
        return dbManager.self.sortTransactionsByAmount(transactions: transaction)
    }
}

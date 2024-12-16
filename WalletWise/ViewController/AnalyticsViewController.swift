import UIKit
import SwiftUI

class AnalyticsViewController: UIViewController {
    
    @IBOutlet weak var returnButton: UIImageView!
    @IBOutlet weak var chartsView: UIView!
    @IBOutlet weak var chartType: UISegmentedControl!
    @IBOutlet weak var card1: UIView!
    @IBOutlet weak var price_Card1: UILabel!
    @IBOutlet weak var card2: UIView!
    @IBOutlet weak var price_Card2: UILabel!
    @IBOutlet weak var card3: UIView!
    @IBOutlet weak var date_Card3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        chartType.addTarget(self, action: #selector(chartTypeChanged), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnButtonTapped))
        returnButton.isUserInteractionEnabled = true
        returnButton.addGestureRecognizer(tapGesture)
        loadBarChart()
        chartTypeUI()
        styleCard(card1)
        styleCard(card2)
        styleCard(card3)
        avgPriceCard()
        topExpensesCard()
        peakDayCard()
    }
    
    @objc func chartTypeChanged() {
        switch chartType.selectedSegmentIndex {
        case 0:
            loadBarChart()
        case 1:
            loadPieChart()
        default:
            break
        }
    }
    
    // MARK: - Load Bar Chart
    private func loadBarChart() {
        clearChartView()
        
        let data = [
            ChartData(month: "Jan", value: 37.4, lineValue: 15.7),
            ChartData(month: "Feb", value: 30.5, lineValue: 14.1),
            ChartData(month: "Mar", value: 36.1, lineValue: 14.5),
            ChartData(month: "Apr", value: 34.3, lineValue: 21.2),
            ChartData(month: "May", value: 43.7, lineValue: 22.6),
            ChartData(month: "Jun", value: 31.8, lineValue: 16.4),
        ]
        
        let chartView = AnalyticsChartView(data: data)
        let hostingController = UIHostingController(rootView: chartView)
        
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        chartsView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: chartsView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: chartsView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: chartsView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: chartsView.trailingAnchor)
        ])
        chartsView.addSubview(chartType)
        hostingController.didMove(toParent: self)
    }
    
    // MARK: - Load Pie Chart
    func loadPieChart() {
        clearChartView()
        
        let pieData = [
            PieChartData(label: "Quarter 1", value: 14, color: .green),
            PieChartData(label: "Quarter 2", value: 14, color: .yellow),
            PieChartData(label: "Quarter 3", value: 34, color: .orange),
            PieChartData(label: "Quarter 4", value: 38, color: .blue)
        ]
        
        let pieChartView = PieChartView(data: pieData)
        let hostingController = UIHostingController(rootView: pieChartView)
        
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        chartsView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: chartsView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: chartsView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: chartsView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: chartsView.trailingAnchor)
        ])
        chartsView.addSubview(chartType)
        hostingController.didMove(toParent: self)
    }
    
    
    // MARK: - ClearUI Charts
    private func clearChartView() {
        chartsView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - ChartType UI
    func chartTypeUI() {
        chartType.removeAllSegments()
        chartType.insertSegment(withTitle: "Bar Chart", at: 0, animated: false)
        chartType.insertSegment(withTitle: "Pie Chart", at: 1, animated: false)
        chartType.selectedSegmentIndex = 0
    }
    //MARK: - Cards UI
    func styleCard(_ card: UIView) {
        card.layer.cornerRadius = 12
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.backgroundColor = UIColor.white
    }
    func avgPriceCard() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currencySymbol = SettingsRepository.shared.fetchSettings()?.currency.currencySymbol ?? ""
        let transactions = TransactionRepository.shared.getTransactionByMonth(month: currentMonth)
        
        let totalValue = transactions.reduce(0.0) { partialResult, transaction in
            partialResult + transaction.amount
        }
        
        let avgPrice = transactions.isEmpty ? 0.0 : totalValue / Double(transactions.count)
        
        DispatchQueue.main.async {
            self.price_Card1.text = String(format: "\(currencySymbol) %.2f", avgPrice)
        }
    }
    func topExpensesCard() {
        let transactions = TransactionRepository.shared.getTransactionByMonth(month: Calendar.current.component(.month, from: Date()))
        let currencySymbol = SettingsRepository.shared.fetchSettings()?.currency.currencySymbol ?? ""
        if let topExpense = transactions.max(by: { $0.amount < $1.amount }) {
            let topExpenseValue = topExpense.amount
            self.price_Card2.text = String(format: "\(currencySymbol) %.2f", topExpenseValue)
        } else {
            self.price_Card2.text = "No Expenses"
        }
    }
    func peakDayCard() {
        let transactions = TransactionRepository.shared.getTransactionByMonth(month: Calendar.current.component(.month, from: Date()))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var transactionCountByDay: [String: Int] = [:]
        for transaction in transactions {
            guard let date = dateFormatter.date(from: transaction.date) else { continue }
            let dayKey = dateFormatter.string(from: date)
            transactionCountByDay[dayKey, default: 0] += 1
        }
        let peakDay = transactionCountByDay.max { $0.value < $1.value }

        DispatchQueue.main.async {
            if let peakDay = peakDay {
                let dayString = peakDay.key
                if let peakDate = dateFormatter.date(from: dayString) {
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    self.date_Card3.text = dateFormatter.string(from: peakDate)
                }
            } else {
                self.date_Card3.text = "No Data"
            }
        }
    }
    private func setupReturnButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(getter: returnButton))
        returnButton.isUserInteractionEnabled = true
        returnButton.addGestureRecognizer(tapGesture)
    }
    @objc func returnButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

}

import UIKit
import SQLite
class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,SettingsDelegate {
    @IBOutlet weak var menuIcon: UIButton!
    @IBOutlet weak var limitView: UIView!
    @IBOutlet weak var expDivLim_LBL: UILabel!
    @IBOutlet weak var price_LBL: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sortButton: UIButton!
    private let shapeLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let percentageLabel = UILabel()
    private var expensePrice = 0
    private var limitPrice = 1
    private var curnnecySymbol: String = "$"
    private var outerDotView: UIView?
    private var transactions: [Transaction] = {
        let currentMonth = Calendar.current.component(.month, from: Date())
        return TransactionRepository.shared.getTransactionByMonth(month: currentMonth)
    }()
    private var settings:Settings? = SettingsRepository.shared.fetchSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        if let settings = settings {
            curnnecySymbol = settings.currency.currencySymbol
            limitPrice = Int(settings.monthlyLimit)
        }
        setupArc()
        setupMenuButton()
        setFormattedPriceLabel()
        sortButtonUI(sortButton)
        addViewUI(to: limitView)
        setupCardView(collectionView: collectionView)
    }
    // MARK: - Menu
    private func setupMenuButton() {
        let menu = UIMenu(children: [
            UIAction(title: "Analytics", image: UIImage(systemName: "chart.bar"), handler: { _ in
                self.navigateToAnalytics()
            }),
            UIAction(title: "Settings", image: UIImage(systemName: "gear"), handler: { _ in
                self.navigateToSettings()
            })
        ])
        
        menuIcon.menu = menu
        menuIcon.showsMenuAsPrimaryAction = true
    }
    private func navigateToAnalytics() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let analyticsVC = storyboard.instantiateViewController(withIdentifier: "AnalyticsViewController") as? AnalyticsViewController {
            analyticsVC.modalPresentationStyle = .fullScreen
            present(analyticsVC, animated: true, completion: nil)
        }
    }

    private func navigateToSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingsViewController {
            settingsVC.modalPresentationStyle = .overCurrentContext
            settingsVC.modalTransitionStyle = .crossDissolve
            settingsVC.delegate = self
            present(settingsVC, animated: true, completion: nil)
        } else {
            print("Error: Could not instantiate SettingsViewController")
        }
    }
    func didUpdateSettings(settings:Settings) {
        collectionView.reloadData()
        self.settings = settings
        limitPrice = Int(settings.monthlyLimit)
        curnnecySymbol = settings.currency.currencySymbol
        setFormattedPriceLabel()
    }
    // MARK: - HardCoded Transactions
    func hardCodedTrans() {
        DatabaseManager.shared.insertTransaction(category: "Amazon",amount: 83,location: "Null",lastCardNums: "9813")
        DatabaseManager.shared.insertTransaction(category: "Netflix", amount: 50.3, location: "Null",lastCardNums: "9813")
        DatabaseManager.shared.insertTransaction(category: "Ali-Express", amount: 2.5, location: "Null",lastCardNums: "4511")
        DatabaseManager.shared.insertTransaction(category: "Uber",amount: 8.3,location: "Null",lastCardNums: "4511")
    }
    func deleteHardCodedTrans() {
        while DatabaseManager.shared.fetchNumberOfTransactions() > 0 {
            let transaction = DatabaseManager.shared.fetchTransactionsByMonth(month: Calendar.current.component(.month, from: Date()))[0]
            DatabaseManager.shared.deleteTransaction(byId: transaction.id)
        }
    }
    // MARK: - UICARD
    func setupCardView(collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        cell.applyRandomGradient(to: cell)
        guard indexPath.row < transactions.count else { return cell }

        let transaction = transactions[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: transaction.date) {
            dateFormatter.dateFormat = "dd/MM/yy"
            let formattedDate = dateFormatter.string(from: date)
            cell.Date.text = "Date: \(formattedDate)"
        } else {
            cell.Date.text = "Date: Null"
        }

        cell.companyLabel.text = transaction.category
        cell.amountLabel.text = "\(curnnecySymbol)\(transaction.amount)"
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at index: \(indexPath.row)")

        let currentMonth = Calendar.current.component(.month, from: Date())
        let transactions = TransactionRepository.shared.getTransactionByMonth(month: currentMonth)

        guard indexPath.row < transactions.count else { return }
        let selectedTransaction = transactions[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newVC = storyboard.instantiateViewController(withIdentifier: "MainStoryboard") as? PopupCardViewController {
            newVC.transaction = selectedTransaction
            newVC.modalPresentationStyle = .overCurrentContext
            newVC.modalTransitionStyle = .crossDissolve
            present(newVC, animated: true, completion: nil)
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 200)
    }
    func refrashCards(transactions: [Transaction]) {
        self.transactions = transactions
        DispatchQueue.main.async {
               self.collectionView.reloadData()
               self.collectionView.collectionViewLayout.invalidateLayout()
           }

    }
    
    // MARK: - Custom UI Functions
    func setFormattedPriceLabel(){
        let totalAmount = calculateMonthlyTotal()
        expensePrice = Int(totalAmount)
        animateProgress(to: CGFloat(expensePrice) / CGFloat(limitPrice))
        let price = String(format: "%@ %.2f", curnnecySymbol, totalAmount)
        let priceParts = price.split(separator: ".")
        let beforeDot = String(priceParts[0])
        let afterDot = String(priceParts[1])
        let fullText = "\(beforeDot).\(afterDot)"
        let attributedString = NSMutableAttributedString(string: fullText)
        if let range = fullText.range(of: ".\(afterDot)") {
            let nsRange = NSRange(range, in: fullText)
            let grayColorWithAlpha = UIColor.gray.withAlphaComponent(0.5)
            attributedString.addAttribute(.foregroundColor, value: grayColorWithAlpha, range: nsRange)
            expDivLim_LBL.text = "\(beforeDot) / \(limitPrice)"
            
        }
        price_LBL.attributedText = attributedString
    }
    
    func calculateMonthlyTotal() -> Double {
        let transactions = TransactionRepository.shared.getAllTransactions()
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return 0.0 }
        
        let filteredTransactions = transactions.filter { transaction in
            guard let transactionDate = dateFormatter.date(from: transaction.date) else { return false }
            return transactionDate >= startOfMonth && transactionDate <= now
        }
        
        return filteredTransactions.reduce(0.0) { $0 + $1.amount }
    }
    
    // MARK: - LIMIT UI
    func addViewUI(to view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        
        // Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        
        // Border
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.layer.borderWidth = 1
        
        // Background
        view.backgroundColor = UIColor.systemGray5
    }

    func setupArc() {
        let center = CGPoint(x: limitView.bounds.midX, y: limitView.bounds.maxY - 60)
        let radius: CGFloat = limitView.bounds.width / 2 - 55
        let startAngle = -CGFloat.pi * 1.1
        let endAngle = CGFloat.pi * 0.1
        
        
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(endAngle), clockwise: true)
        
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 17
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.3
        shapeLayer.shadowOffset = CGSize(width: 4, height: 4)
        shapeLayer.shadowRadius = 8
        limitView.layer.addSublayer(shapeLayer)
    
        progressLayer.path = circularPath.cgPath
        progressLayer.lineWidth = 17
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .butt
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.black.cgColor
        limitView.layer.addSublayer(progressLayer)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = limitView.bounds
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1).cgColor,
            UIColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1).cgColor,
            UIColor(red: 0.7, green: 0.2, blue: 0.1, alpha: 1).cgColor

        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.mask = progressLayer
        limitView.layer.addSublayer(gradientLayer)
    }
    
    func setupPercentageLabel(to value: CGFloat) {
        let clampedValue = min(max(value, 0), 1)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        percentageLabel.center = CGPoint(x: limitView.bounds.midX, y: limitView.bounds.midY + 20)
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 32)
        percentageLabel.text = "\(Int64(clampedValue * 100))%"
        limitView.addSubview(percentageLabel)
    }

    
    func animateProgress(to value: CGFloat) {
        let clampedValue = min(max(value, 0), 1)
        setupPercentageLabel(to: clampedValue)
        outerDotView?.layer.removeAllAnimations()
        outerDotView?.removeFromSuperview()
        let newOuterDotView = UIView()
        newOuterDotView.frame.size = CGSize(width: 25, height: 25)
        newOuterDotView.backgroundColor = .white
        newOuterDotView.layer.cornerRadius = 12.5
        newOuterDotView.layer.masksToBounds = true
        
        let innerDotView = UIView()
        innerDotView.frame.size = CGSize(width: 13, height: 13)
        innerDotView.backgroundColor = .lightGray
        innerDotView.layer.cornerRadius = 6.5
        innerDotView.layer.masksToBounds = true
        innerDotView.center = CGPoint(x: newOuterDotView.bounds.midX, y: newOuterDotView.bounds.midY)
        
        newOuterDotView.addSubview(innerDotView)
        limitView.addSubview(newOuterDotView)
        limitView.bringSubviewToFront(newOuterDotView)
        outerDotView = newOuterDotView
        
        let center = CGPoint(x: limitView.bounds.midX, y: limitView.bounds.maxY - 60)
        let radius: CGFloat = limitView.bounds.width / 2 - 55
        updateDotPosition(dotView: newOuterDotView, percentage: clampedValue, center: center, radius: radius)
        let dotAnimation = CAKeyframeAnimation(keyPath: "position")
        dotAnimation.path = createArcPath(center: center, radius: radius, startAngle: -CGFloat.pi * 1.1, endAngle: -CGFloat.pi * 1.1 + clampedValue * (CGFloat.pi * 1.2)).cgPath
        dotAnimation.duration = 1.5
        dotAnimation.fillMode = .forwards
        dotAnimation.isRemovedOnCompletion = false
        newOuterDotView.layer.add(dotAnimation, forKey: "dotAnimation")
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = clampedValue
        animation.duration = 1.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        limitView.bringSubviewToFront(newOuterDotView)
    }


    
    func createArcPath(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    func updateDotPosition(dotView: UIView, percentage: CGFloat, center: CGPoint, radius: CGFloat) {
        let clampedPercentage = min(max(percentage, 0), 1)
        let angle = -CGFloat.pi * 1.1 + clampedPercentage * (CGFloat.pi * 1.2)
        let dotX = center.x + radius * cos(angle)
        let dotY = center.y + radius * sin(angle)
        dotView.center = CGPoint(x: dotX, y: dotY)
    }

    
    //MARK: -Sort Button
    func sortButtonUI(_ sender: UIButton) {
        let menu = UIMenu(children: [
            UIAction(title: "Date", handler: { action in
                self.sortButton.setTitle("Date", for: .normal)
                self.refrashCards(transactions: TransactionRepository.shared.sortTransactionsByDate(transaction: self.transactions))
            }),
            UIAction(title: "Price", handler: { action in
                self.sortButton.setTitle("Price", for: .normal)
                print("Price sorting")
                let sortedTransactions = TransactionRepository.shared.sortTransactionsByAmount(transaction: self.transactions)
                self.refrashCards(transactions: sortedTransactions)

            })
        ])
        sortButton.menu = menu
        sortButton.showsMenuAsPrimaryAction = true
        DispatchQueue.main.async {
            self.sortButton.setTitle("Sort-By", for: .normal)
        }
    }
    //MARK: - Refrash app
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // אחזור והגדרת הערכים מחדש
        settings = SettingsRepository.shared.fetchSettings()
        collectionView.reloadData()
        
    }
}



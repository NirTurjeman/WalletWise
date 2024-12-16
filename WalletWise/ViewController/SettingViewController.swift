import UIKit

protocol SettingsDelegate: AnyObject {
    func didUpdateSettings(settings: Settings)
}
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var returnButton: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    weak var delegate: SettingsDelegate?
    
    let settings: [String] = [
        "Currency",
        "Language",
        "Notifications",
        "Monthly Limit"
    ]
    
    var isNotificationsEnabled: Bool = false
    var monthlyLimit: Int64 = 0
    var language: Language = .EN
    var currency: Currency = .USD
    private var settingsRepository: Settings? = SettingsRepository.shared.fetchSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        tableView.delegate = self
        tableView.dataSource = self
        setupReturnButton()
        loadSettings()
        tableStyle()
    }
    
    private func loadSettings() {
        if let settings = settingsRepository {
            isNotificationsEnabled = settings.notification
            monthlyLimit = settings.monthlyLimit
            language = settings.language
            currency = settings.currency
        }
    }
    
    private func setupReturnButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnTapped))
        returnButton.isUserInteractionEnabled = true
        returnButton.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let setting = settings[indexPath.row]
        cell.textLabel?.text = setting
        
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        switch setting {
        case "Notifications":
            let switchView = UISwitch(frame: .zero)
            switchView.isOn = isNotificationsEnabled
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            
        case "Monthly Limit":
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            textField.borderStyle = .roundedRect
            textField.text = "\(monthlyLimit)"
            textField.placeholder = "Enter Limit"
            textField.keyboardType = .numberPad
            textField.delegate = self
            textField.tag = indexPath.row
            textField.inputAccessoryView = createDoneToolbar()
            cell.accessoryView = textField
            
        case "Language", "Currency":
            cell.accessoryType = .disclosureIndicator
            
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSetting = settings[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch selectedSetting {
        case "Language":
            showLanguageOptions()
        case "Currency":
            showCurrencyOptions()
        default:
            break
        }
    }
    func tableStyle(){
        tableView.layer.cornerRadius = 15
        tableView.layer.masksToBounds = true
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowRadius = 4
    }
    // MARK: - UITextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == settings.firstIndex(of: "Monthly Limit") {
            monthlyLimit = Int64(textField.text ?? "0") ?? 0
            print("Monthly Limit set to: \(monthlyLimit)")
        }
    }
    
    // MARK: - Create Done Toolbar
    
    private func createDoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.items = [flexSpace, doneButton]
        return toolbar
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Language Options
    
    private func showLanguageOptions() {
        let alert = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)
        let languages = ["English", "Hebrew"]
        
        for language in languages {
            let action = UIAlertAction(title: language, style: .default) { _ in
                self.language = Language(rawValue: language)!
                print("Selected Language: \(language)")
                self.tableView.reloadData()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Currency Options
    
    private func showCurrencyOptions() {
        let alert = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
        
        let currencies = [Currency.ILS, Currency.USD, Currency.EUR, Currency.GBP, Currency.AUD]
        
        for currency in currencies {
            let action = UIAlertAction(title: currency.rawValue, style: .default) { _ in
                self.currency = currency
                print("Selected Currency: \(currency.rawValue)")
                self.tableView.reloadData()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Return Action
    
    @objc private func returnTapped() {
        delegate?.didUpdateSettings(settings: Settings(monthlyLimit: monthlyLimit, language: language, currency: currency, notification: isNotificationsEnabled))
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        let settings = Settings(
            monthlyLimit: monthlyLimit,
            language: language,
            currency: currency,
            notification: isNotificationsEnabled
        )
        SettingsRepository.shared.save(settings: settings)
        print("Settings saved: \(settings)")
        delegate?.didUpdateSettings(settings: Settings(monthlyLimit: monthlyLimit, language: language, currency: currency, notification: isNotificationsEnabled))
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didToggleSwitch(_ sender: UISwitch) {
        if settings[sender.tag] == "Notifications" {
            isNotificationsEnabled = sender.isOn
            print("Notifications are now \(isNotificationsEnabled ? "Enabled" : "Disabled")")
        }
    }
}

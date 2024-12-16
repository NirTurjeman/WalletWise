import UIKit
import MapKit

protocol PopupCardDelegate: AnyObject {
    func didClosePopup(with data: String)
}
class PopupCardViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var grayLine: UIView!
    @IBOutlet weak var closePopup_IMG: UIImageView!
    @IBOutlet weak var company_LBL: UILabel!
    @IBOutlet weak var date_LBL: UILabel!
    @IBOutlet weak var cardNumber_LBL: UILabel!
    @IBOutlet weak var amount_LBL: UILabel!
    @IBOutlet weak var MapView: UIView!
    @IBOutlet weak var location_LBL: UILabel!
    let mapView = MKMapView()
    @IBOutlet weak var cardView: UIView!
    public var transaction: Transaction?
        weak var delegate: PopupCardDelegate?
        
        // MARK: - View Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupMapView()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePopupTapped))
            closePopup_IMG.isUserInteractionEnabled = true
            closePopup_IMG.addGestureRecognizer(tapGesture)
            addViewUI(to: cardView)
            overrideUserInterfaceStyle = .light
        }
        
        // MARK: - Setup UI
        private func setupUI() {
            guard let transaction = transaction else { return }
            
            company_LBL.text = "\(transaction.category)"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: transaction.date) {
                dateFormatter.dateFormat = "dd/MM/yy , hh:mm"
                let formattedDate = dateFormatter.string(from: date)
                date_LBL.text = "Date: \(formattedDate)"
            } else {
                date_LBL.text = "Date: Null"
            }

            cardNumber_LBL.text = "Card Number: ****\(transaction.lastCardNumber)"
            amount_LBL.text = "\(Currency.USD.currencySymbol)\(transaction.amount)"
        }
        
// MARK: - Setup MapView
    private func setupMapView() {
        let containerView = UIView(frame: MapView.frame)
        containerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.cornerRadius = 5
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        containerView.addSubview(MapView)
        MapView.frame = containerView.bounds
        MapView.layer.cornerRadius = 10
        MapView.layer.masksToBounds = true
        
        mapView.frame = MapView.bounds
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        MapView.addSubview(mapView)
        MapView.addSubview(location_LBL)
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
        // MARK: - Add Marker
        func addMarker(at coordinate: CLLocationCoordinate2D) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        
        // MARK: - Button Actions
        @objc private func closePopupTapped() {
            delegate?.didClosePopup(with: "Close")
            dismiss(animated: true, completion: nil)
        }
        //MARK: - View Card UI
    func addViewUI(to view: UIView) {
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = false
        
        // Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 6
        
        // Border
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.layer.borderWidth = 1
        // Background
        view.backgroundColor = UIColor.white
    }
    }

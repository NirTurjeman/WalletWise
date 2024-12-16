import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    private var bgColor: UIColor?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = false
        bgColor = self.backgroundColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.layer.shadowRadius = 4
        self.Date.isUserInteractionEnabled = false
        self.amountLabel.isUserInteractionEnabled = false
        self.companyLabel.isUserInteractionEnabled = false
    }
    func applyRandomGradient(to view: UIView) {
        let gradients = [
            [UIColor(red: 255/255.0, green: 132/255.0, blue: 87/255.0, alpha: 1).cgColor, // Coral
             UIColor(red: 255/255.0, green: 186/255.0, blue: 82/255.0, alpha: 1).cgColor], // Texas Rose
            [UIColor(red: 255/255.0, green: 245/255.0, blue: 224/255.0, alpha: 1).cgColor, // #FFF5E0
                    UIColor(red: 255/255.0, green: 216/255.0, blue: 181/255.0, alpha: 1).cgColor] , // #FFD8B5
            [UIColor(red: 255/255.0, green: 153/255.0, blue: 122/255.0, alpha: 1).cgColor, // #FF997A
                 UIColor(red: 255/255.0, green: 184/255.0, blue: 143/255.0, alpha: 1).cgColor]  // #FFB88F
        ]
        
        let randomIndex = Int.random(in: 0..<gradients.count)
        let selectedGradient = gradients[randomIndex]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = selectedGradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = view.layer.cornerRadius
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

}


enum Currency: String {
    case ILS = "ILS" // Israeli Shekel
    case USD = "USD" // US Dollar
    case EUR = "EUR" // Euro
    case GBP = "GBP" // British Pound Sterling
    case AUD = "AUD" // Australian Dollar
}

extension Currency {
    var currencySymbol: String {
        switch self {
        case .ILS: return "₪"
        case .USD: return "$"
        case .GBP: return "£"
        case .EUR: return "€"
        case .AUD: return "AU$"
        }
    }
}


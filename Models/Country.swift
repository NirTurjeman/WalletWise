enum CountryCode: String {
    case IL = "IL" // Israel
    case US = "US" // United States
    case CA = "CA" // Canada
    case GB = "GB" // United Kingdom
    case DE = "DE" // Germany
    case FR = "FR" // France
    case IT = "IT" // Italy
    case ES = "ES" // Spain
    case NL = "NL" // Netherlands
    case SE = "SE" // Sweden
    case CH = "CH" // Switzerland
    case AU = "AU" // Australia
    case NZ = "NZ" // New Zealand
}

extension CountryCode {
    var defaultCurrency: Currency {
        switch self {
        case .IL: return .ILS
        case .US: return .USD
        case .CA: return .USD
        case .GB: return .GBP
        case .DE, .FR, .IT, .ES, .NL, .SE, .CH: return .EUR
        case .AU, .NZ: return .AUD
        }
    }
}

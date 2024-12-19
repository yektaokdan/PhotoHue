import CoreImage

enum FilterType: String, CaseIterable, Identifiable {
    case original
    case sepia
    case mono
    case vibrant
    case noir
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .original: return "Orijinal"
        case .sepia: return "Sepya"
        case .mono: return "Mono"
        case .vibrant: return "Canlı"
        case .noir: return "Noir"
        }
    }
    
    func createFilter(intensity: Double) -> CIFilter {
        switch self {
        case .original:
            return CIFilter.colorControls()
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.intensity = Float(intensity)
            return filter
        case .mono:
            let filter = CIFilter.photoEffectMono()
            return filter
        case .vibrant:
            let filter = CIFilter.colorControls()
            filter.saturation = Float(1 + intensity)
            filter.brightness = Float(0.1 * intensity)
            return filter
        case .noir:
            let filter = CIFilter.photoEffectNoir()
            return filter
        }
    }
} 
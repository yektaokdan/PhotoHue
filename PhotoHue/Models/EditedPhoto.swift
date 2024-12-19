import SwiftUI

struct EditedPhoto: Identifiable, Codable {
    let id: String
    let date: Date
    let assetIdentifier: String
    let filterType: String
    let filterIntensity: Double
    
    init(id: String = UUID().uuidString, assetIdentifier: String, filterType: String, filterIntensity: Double) {
        self.id = id
        self.date = Date()
        self.assetIdentifier = assetIdentifier
        self.filterType = filterType
        self.filterIntensity = filterIntensity
    }
} 
import SwiftUI
import Photos

class EditedPhotosViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var editedPhotos: [EditedPhoto] = []
    private let userDefaults = UserDefaults.standard
    
    override init() {
        super.init()
        loadEditedPhotos()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func loadEditedPhotos() {
        if let data = userDefaults.data(forKey: "editedPhotos"),
           let photos = try? JSONDecoder().decode([EditedPhoto].self, from: data) {
            Task {
                let validPhotos = await filterValidPhotos(photos)
                await MainActor.run {
                    self.editedPhotos = validPhotos.sorted(by: { $0.date > $1.date })
                    self.saveToUserDefaults(validPhotos)
                }
            }
        }
    }
    
    private func filterValidPhotos(_ photos: [EditedPhoto]) async -> [EditedPhoto] {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: photos.map { $0.assetIdentifier }, options: nil)
        return photos.filter { photo in
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetIdentifier], options: nil)
            return assets.count > 0
        }
    }
    
    func saveEditedPhoto(_ photo: EditedPhoto) {
        editedPhotos.insert(photo, at: 0)
        saveToUserDefaults(editedPhotos)
    }
    
    private func saveToUserDefaults(_ photos: [EditedPhoto]) {
        if let data = try? JSONEncoder().encode(photos) {
            userDefaults.set(data, forKey: "editedPhotos")
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.loadEditedPhotos()
        }
    }
} 
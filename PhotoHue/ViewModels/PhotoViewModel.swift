import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var imageSelection: PhotosPickerItem? {
        didSet { loadImage() }
    }
    @Published var selectedFilter: FilterType = .original
    @Published var filterIntensity: Double = 0.5 {
        didSet { applyFilter() }
    }
    @Published var showingSaveSuccess = false
    @Published var errorMessage = ""
    @Published var showingErrorAlert = false
    
    private var originalImage: UIImage?
    private let context = CIContext()
    private let editedPhotosViewModel = EditedPhotosViewModel()
    
    private func loadImage() {
        Task {
            guard let item = imageSelection else { return }
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            
            await MainActor.run {
                originalImage = uiImage
                selectedImage = uiImage
            }
        }
    }
    
    func capturePhoto() {
        // Kamera işlevselliği burada uygulanacak
    }
    
    func resetImage() {
        selectedImage = originalImage
        filterIntensity = 0.5
        selectedFilter = .original
    }
    
    func saveImage() {
        guard let image = selectedImage else { return }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        if let assetID = request.placeholderForCreatedAsset?.localIdentifier {
                            // Düzenlenen fotoğraf bilgilerini kaydet
                            DispatchQueue.main.async {
                                let editedPhoto = EditedPhoto(
                                    assetIdentifier: assetID,
                                    filterType: self.selectedFilter.name,
                                    filterIntensity: self.filterIntensity
                                )
                                self.editedPhotosViewModel.saveEditedPhoto(editedPhoto)
                            }
                        }
                    }) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                self.showingSaveSuccess = true
                                self.resetToInitialState()
                            } else if let error = error {
                                self.showError("Fotoğraf kaydedilemedi: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    self.showError("Fotoğrafı kaydetmek için galeri izni gerekiyor.")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
    
    private func resetToInitialState() {
        selectedImage = nil
        originalImage = nil
        imageSelection = nil
        selectedFilter = .original
        filterIntensity = 0.5
    }
    
    private func applyFilter() {
        guard let originalImage = originalImage,
              let ciImage = CIImage(image: originalImage) else { return }
        
        let filter = selectedFilter.createFilter(intensity: filterIntensity)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        selectedImage = UIImage(cgImage: cgImage)
    }
} 
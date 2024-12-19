import SwiftUI
import Photos

struct EditedPhotosView: View {
    @StateObject private var viewModel = EditedPhotosViewModel()
    @State private var selectedPhoto: EditedPhoto?
    @State private var showingFullScreenPhoto = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.editedPhotos.isEmpty {
                    ContentUnavailableView {
                        Label("Düzenlenmiş Fotoğraf Yok", systemImage: "photo.stack")
                    } description: {
                        Text("PhotoHue ile düzenlediğiniz fotoğraflar burada listelenecek")
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(viewModel.editedPhotos) { photo in
                                EditedPhotoCell(photo: photo)
                                    .aspectRatio(1, contentMode: .fill)
                                    .onTapGesture {
                                        selectedPhoto = photo
                                        showingFullScreenPhoto = true
                                    }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Düzenlenenler")
            .fullScreenCover(isPresented: $showingFullScreenPhoto) {
                if let photo = selectedPhoto {
                    FullScreenPhotoView(photo: photo)
                }
            }
        }
    }
}

struct FullScreenPhotoView: View {
    let photo: EditedPhoto
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetIdentifier], options: nil)
        
        if let asset = fetchResult.firstObject {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            
            await withCheckedContinuation { continuation in
                manager.requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFit,
                    options: option
                ) { result, _ in
                    self.image = result
                    continuation.resume()
                }
            }
        }
    }
}

struct EditedPhotoCell: View {
    let photo: EditedPhoto
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                    .overlay(alignment: .bottomTrailing) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(photo.filterType)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("\(Int(photo.filterIntensity * 100))%")
                                .font(.caption2)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(12)
                    }
                    .overlay(alignment: .topTrailing) {
                        Text(photo.date.formatted(.relative(presentation: .named)))
                            .font(.caption2)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(8)
                    }
            } else {
                if isLoading {
                    ProgressView()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    ContentUnavailableView {
                        Label("Fotoğraf Bulunamadı", systemImage: "photo.badge.exclamationmark")
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        isLoading = true
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetIdentifier], options: nil)
        
        if let asset = fetchResult.firstObject {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            option.isNetworkAccessAllowed = true
            
            await withCheckedContinuation { continuation in
                manager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: 400, height: 400),
                    contentMode: .aspectFill,
                    options: option
                ) { result, info in
                    self.image = result
                    self.isLoading = false
                    continuation.resume()
                }
            }
        } else {
            isLoading = false
        }
    }
} 
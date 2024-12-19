import SwiftUI
import PhotosUI

struct PhotoEditorView: View {
    @StateObject private var viewModel = PhotoViewModel()
    @State private var showingSaveAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.05).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Fotoğraf önizleme alanı
                    if let image = viewModel.selectedImage {
                        GeometryReader { geo in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: geo.size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(radius: 10)
                                .padding()
                                .animation(.spring(), value: image)
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                    } else {
                        Button {
                            showingImagePicker = true
                        } label: {
                            ContentUnavailableView {
                                Label("Fotoğraf Ekle", systemImage: "photo.on.rectangle")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            } description: {
                                Text("Galeriden bir fotoğraf seçin veya\nkamera ile yeni bir fotoğraf çekin")
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                    }
                    
                    // Filtre kontrolleri
                    if viewModel.selectedImage != nil {
                        VStack(spacing: 25) {
                            // Filtre seçenekleri
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(FilterType.allCases) { filter in
                                        FilterButton(
                                            filter: filter,
                                            isSelected: viewModel.selectedFilter == filter,
                                            action: {
                                                withAnimation {
                                                    viewModel.selectedFilter = filter
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Yoğunluk ayarı
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Filtre Yoğunluğu")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(Int(viewModel.filterIntensity * 100))%")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Slider(value: $viewModel.filterIntensity, in: 0...1)
                                    .tint(.blue)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("PhotoHue")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    PhotosPicker(selection: $viewModel.imageSelection,
                               matching: .images) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .symbolEffect(.bounce, value: viewModel.imageSelection)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: viewModel.capturePhoto) {
                        Image(systemName: "camera")
                    }
                    .buttonStyle(.bordered)
                }
                
                if viewModel.selectedImage != nil {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: viewModel.resetImage) {
                            Label("Sıfırla", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button {
                            viewModel.saveImage()
                        } label: {
                            Label("Kaydet", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotosPicker(selection: $viewModel.imageSelection,
                           matching: .images) {
                    Text("Fotoğraf Seç")
                }
            }
            .alert("Başarılı", isPresented: $viewModel.showingSaveSuccess) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Fotoğraf başarıyla galeriye kaydedildi.")
            }
            .alert("Hata", isPresented: $viewModel.showingErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
} 
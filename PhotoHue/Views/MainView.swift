import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            PhotoEditorView()
                .tabItem {
                    Label("Düzenle", systemImage: "wand.and.stars")
                }
            
            EditedPhotosView()
                .tabItem {
                    Label("Galeri", systemImage: "photo.stack")
                }
        }
    }
} 
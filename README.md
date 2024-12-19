# PhotoHue - Photo Filter App

PhotoHue is a simple and elegant iOS photo filter application built with SwiftUI. Users can apply various filters to their photos and save them to their photo library.

## Features

- Apply various photo filters with adjustable intensity
- Save edited photos to photo library
- View edited photos history with filter details
- Full screen photo preview
- Clean and modern UI design
- Support for both light and dark mode
- Turkish localization support

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository 

```bash
git clone https://github.com/yourusername/PhotoHue.git
```

1. Open PhotoHue.xcodeproj in Xcode

2. Build and run the project

## Usage

1. Launch the app and tap the "+" button or empty photo area to select a photo
2. Choose a filter from the available options
3. Adjust the filter intensity using the slider
4. Tap "Save" to save the edited photo
5. View your edited photos in the Gallery tab

## Architecture

- MVVM (Model-View-ViewModel) architecture
- SwiftUI for UI
- Core Image for photo filters
- PhotosUI for photo picker and library access
- UserDefaults for storing edit history

## Main Components

- `PhotoEditorView`: Main photo editing interface
- `EditedPhotosView`: Gallery view for edited photos
- `FilterType`: Available filter types and configurations
- `PhotoViewModel`: Business logic for photo editing
- `EditedPhotosViewModel`: Management of edited photos history

## Permissions

The app requires the following permissions:
- Photo Library access for saving and loading photos

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- SwiftUI framework
- Core Image framework
- Apple's PhotosUI
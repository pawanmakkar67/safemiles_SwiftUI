
import SwiftUI
import WebKit

struct PDFView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct PDFViewer: View {
    let urlString: String
    let title: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isDownloading = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CommonHeader(
                    title: title,
                    leftIcon: "left",
                    rightIcon: "arrow.down.doc",
                    onLeftTap: {
                        presentationMode.wrappedValue.dismiss()
                    },
                    onRightTap: {
                        downloadAndSavePDF()
                    }
                )
                
                if !urlString.isEmpty {
                    PDFView(urlString: urlString)
                } else {
                    Spacer()
                    Text("Invalid PDF URL")
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            
            if isDownloading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView("Downloading...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }
    
    func downloadAndSavePDF() {
        guard let url = URL(string: urlString) else { return }
        isDownloading = true
        
        URLSession.shared.downloadTask(with: url) { localURL, response, error in
            DispatchQueue.main.async {
                isDownloading = false
                
                if let localURL = localURL {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                    do {
                        if FileManager.default.fileExists(atPath: tempURL.path) {
                            try FileManager.default.removeItem(at: tempURL)
                        }
                        try FileManager.default.copyItem(at: localURL, to: tempURL)
                        presentDocumentPicker(for: tempURL)
                    } catch {
                        print("Error saving temp file: \(error)")
                    }
                } else {
                    print("Download failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }
    
    func presentDocumentPicker(for url: URL) {
        let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(picker, animated: true)
        }
    }
    
    func sharePDF(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            // For iPad compatibility
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = rootViewController.view
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

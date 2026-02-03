
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
    
    var body: some View {
        VStack(spacing: 0) {
            CommonHeader(
                title: title,
                leftIcon: "arrow.left",
                onLeftTap: {
                    presentationMode.wrappedValue.dismiss()
                },
                onRightTap: {}
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
    }
}

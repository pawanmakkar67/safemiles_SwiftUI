import SwiftUI
import PencilKit

struct SignatureView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var onSaved: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2.0)
        canvasView.backgroundColor = .clear // Important for overlay usage
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update logic if needed
    }
}

extension PKCanvasView {
    func asImage() -> UIImage {
        let drawingImage = self.drawing.image(from: self.bounds, scale: 1.0)
        return drawingImage
    }
}

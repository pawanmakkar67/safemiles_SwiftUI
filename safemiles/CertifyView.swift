import SwiftUI

struct CertifyView: View {
    @ObservedObject var viewModel: LogsViewModel
    @State private var lines: [[CGPoint]] = []
    @State private var currentLine: [CGPoint] = []
    @State private var isCertified = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Constants matching UIKit design approximate
    private let drawingHeight: CGFloat = 200
    private let cornerRadius: CGFloat = 10
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if let log = viewModel.currentLog, log.log?.certified == false {
                    
                    Text("Draw your signature here")
                        .font(AppFonts.bodyText)
                        .foregroundColor(AppColors.textGray)
                        .padding(.top)
                    
                    // Signature Drawing Area
                    ZStack {
                        // Border View (mimicking signatureDrawingView1)
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.black, lineWidth: 1)
                            .background(Color.white)
                            .frame(height: drawingHeight + 10)
                        
                        // Drawing Canvas (mimicking signatureDrawingView)
                        Canvas { context, size in
                            for line in lines {
                                var path = Path()
                                path.addLines(line)
                                context.stroke(path, with: .color(.black), lineWidth: 2)
                            }
                            // Draw current line
                            var path = Path()
                            path.addLines(currentLine)
                            context.stroke(path, with: .color(.black), lineWidth: 2)
                        }
                        .frame(height: drawingHeight)
                        .padding(5) // Inner padding
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let newPoint = value.location
                                    if value.translation.width == 0 && value.translation.height == 0 {
                                        // Start of line
                                        currentLine = [newPoint]
                                    } else {
                                        currentLine.append(newPoint)
                                    }
                                }
                                .onEnded { _ in
                                    lines.append(currentLine)
                                    currentLine = []
                                }
                        )
                    }
                    .padding(.horizontal,20)
                    .padding(.vertical,5)

                    Button("Clear signature") {
                        lines = []
                        currentLine = []
                    }
                    .font(AppFonts.bodyText)
                    .foregroundColor(AppColors.textGray)
                    .padding(.vertical, 5)
                    
                    Text("I hereby certify that my data entries and my record of duty status for this 24-hour period are true and correct.")
                        .font(AppFonts.captionText)
                        .foregroundColor(AppColors.textGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Buttons
                    Button(action: submitSignature) {
                        Text("Submit")
                            .font(AppFonts.buttonText)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.buttonActive)
                            .cornerRadius(8)
                    }
                    .padding()
                    .padding(.top, 5)
                } else {
                    // Already Certified State
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal.fill")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 80, height: 80)
                             .foregroundColor(AppColors.statusGreen)
                        
                        Text("Already Certified")
                            .font(AppFonts.cardTitle)
                            .bold()
                        
                        if let signatureUrl = viewModel.currentLog?.log?.signature, !signatureUrl.isEmpty {
                            // Show signature if URL is available (optional enhancement)
                            Text("Signature on file")
                                .font(AppFonts.captionText)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 50)
                }
            }
            .padding(.bottom, 20)
        }
        .background(AppColors.background)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func submitSignature() {
        if lines.isEmpty {
            alertMessage = "Please draw your signature first."
            showAlert = true
            return
        }
        
        let renderer = ImageRenderer(content:
            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line)
                    context.stroke(path, with: .color(.black), lineWidth: 2)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 60, height: drawingHeight)
        )
        
        if let image = renderer.uiImage, let pngData = image.pngData() {
            viewModel.certifyLog(signature: image) { success, message in
                alertMessage = message
                showAlert = true
                if success {
                    lines = [] // Clear after success
                }
            }
        } else {
            alertMessage = "Failed to capture signature."
            showAlert = true
        }
    }
}

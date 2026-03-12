import SwiftUI
import Combine

struct ProcessingView: View {
    var onComplete: () -> Void
    @StateObject private var viewModel = HomeViewModel()
    @State private var dotCount = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Exact Center Logo Design
                ZStack {
                    // Outer dark ring
                    Circle()
                        .stroke(Color(hex: "1F2937"), lineWidth: 6)
                        .frame(width: 160, height: 160)
                    
                    // Translucent inner border
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                        .frame(width: 142, height: 142)
                    
                    // Main Gradient Circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "0EA5E9"), Color(hex: "0369A1")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    Image("safemiles_white")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                }
                
                VStack(spacing: 20) {
                    Text("Loading")
                        .font(AppFonts.title2)
                        .foregroundStyle(.white)
                    
                    // Animated Dots
                    HStack(spacing: 12) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color(hex: "0EA5E9"))
                                .frame(width: 12, height: 12)
                                .opacity(dotCount == index ? 1.0 : 0.3)
                        }
                    }
                }
                .padding(.top, 10)
                
                
                Text("Preparing your workspace...")
                    .font(AppFonts.loginSubtitle)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                startLoading()
            }
        }
        .onReceive(timer) { _ in
            withAnimation {
                dotCount = (dotCount + 1) % 3
            }
        }
    }
    
    private func startLoading() {
        // Fetch major APIs
        Task {
            // We call refreshData which handles fetchRecap, getLiveStatus, getVehicles, getCoDrivers
            // And we also need getMyProfile separately as it's not in refreshData currently
            
            viewModel.getMyProfile()
            await viewModel.refreshData()
            
            // Small delay to ensure smooth transition
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            DispatchQueue.main.async {
                onComplete()
            }
        }
    }
}

#Preview {
    ProcessingView(onComplete: {})
}

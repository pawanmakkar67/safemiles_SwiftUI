
import SwiftUI

struct InformationPacketView: View {
    @Binding var showSideMenu: Bool
    @ObservedObject var bleManager = BLEManager.shared
    @State private var showBluetoothScan = false
    @State private var showPDF = false
    @State private var selectedPDFUrl = ""
    @State private var selectedPDFTitle = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationLink(destination: BluetoothScanningView(), isActive: $showBluetoothScan) {
                }
                
                NavigationLink(destination: PDFViewer(urlString: selectedPDFUrl, title: selectedPDFTitle), isActive: $showPDF) {
                    EmptyView()
                }
                
                // Common Header
                CommonHeader(
                    title: "Information Packet",
                    leftIcon: "Menu",
                    onLeftTap: {
                        withAnimation {
                            showSideMenu = true
                        }
                    },
                    onRightTap: {
                    }
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Card 1: User Manual
                        InfoPacketCard(title: "User Manual", icon: "doc.text") {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("The user's manual, instruction sheet, and malfunction instruction sheet can be in electronic form. This is in accordance with the federal register titled \"Regulatory Guidance Concerning Electronic Signatures and Documents\" (76 FR 411).")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button(action: {
                                    openPDF(url: ApiList.manualPDF, title: "User Manual")
                                }) {
                                    Text("VIEW USER MANUAL")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                                .background(Color.black)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Card 2: Instructions
                        InfoPacketCard(title: "Instructions", icon: "doc.text") {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("In addition to the above, a supply of blank driver's records of duty status (RODS) graph-grids sufficient to record the driver's duty status and other related information for a minimum of 8 days must be onboard the commercial motor vehicle (CMV).")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button(action: {
                                    openPDF(url: ApiList.instructionsPDF, title: "Instructions")
                                }) {
                                    Text("VIEW INSTRUCTIONS")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                                .background(Color.black)
                                .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .onAppear {
            showSideMenu = false
        }
    }
    
    func openPDF(url: String, title: String) {
        self.selectedPDFUrl = url
        self.selectedPDFTitle = title
        self.showPDF = true
    }
}

struct InfoPacketCard<Content: View>: View {
    let title: String
    let icon: String // Added icon support
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "555555")) // Dark gray icon
                
                Text(title)
                    .font(.headline) // Larger title
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading) {
                content
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}


import SwiftUI

struct MainContainerView: View {
    @State private var showSideMenu = false
    @State private var selectedMenuOption: SideMenuOption? = .home
    
    @ObservedObject var fontManager = FontManager.shared
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    // Main Content
                    MainTabView(showSideMenu: $showSideMenu)
                    
                    // Hidden Navigation Links for Side Menu
                    VStack {
                        NavigationLink(tag: .dotInspection, selection: $selectedMenuOption, destination: {
                            DotInspectionView(showSideMenu: $showSideMenu).navigationBarHidden(true)
                        }) { EmptyView() }
                        
                        NavigationLink(tag: .rules, selection: $selectedMenuOption, destination: {
                            RulesView(showSideMenu: $showSideMenu).navigationBarHidden(true)
                        }) { EmptyView() }
                        
                        NavigationLink(tag: .coDriver, selection: $selectedMenuOption, destination: {
                            CoDriverView(showSideMenu: $showSideMenu, onLogout: {
                                // Handle Logout / App State Reset
                                UserDefaults.removeAllKeys()
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    NotificationCenter.default.post(name: NSNotification.Name("LogoutNotification"), object: nil)
                                }
                            }).navigationBarHidden(true)
                        }) { EmptyView() }
                        
                        NavigationLink(tag: .selectVehicle, selection: $selectedMenuOption, destination: {
                            SelectVehicleView(showSideMenu: $showSideMenu).navigationBarHidden(true)
                        }) { EmptyView() }
                        
                        NavigationLink(tag: .infoPacket, selection: $selectedMenuOption, destination: {
                            InformationPacketView(showSideMenu: $showSideMenu).navigationBarHidden(true)
                        }) { EmptyView() }
                    }
                    .frame(width: 0, height: 0)
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            SideMenuView(isShowing: $showSideMenu, selectedOption: $selectedMenuOption)
        }
        .id(fontManager.scaleIndex) // Forces redraw of entire view hierarchy when font scale changes
        .onChange(of: selectedMenuOption) { newValue in
            if newValue == .logout {
                // Handle Logout
                selectedMenuOption = nil // Reset
                UserDefaults.removeAllKeys()
                NotificationCenter.default.post(name: NSNotification.Name("LogoutNotification"), object: nil)
            }
        }
    }
}

import SwiftUI

struct MainTabView: View {
    @Binding var showSideMenu: Bool
    @State private var selection = 0
    
    init(showSideMenu: Binding<Bool>) {
        self._showSideMenu = showSideMenu
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // Adjust item positioning to make the tab bar feel larger/less cramped
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        itemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    // Placeholder View for Tabs
    struct PlaceHolderView: View {
        let title: String
        var body: some View {
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(AppColors.textGray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
        }
    }
    
    @State private var isDriving = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                HomeView(showSideMenu: $showSideMenu)
                    .tabItem {
                        Label("Home", image: "Home")
                    }
                    .tag(0)
                
                DvirView(showSideMenu: $showSideMenu)
                    .tabItem {
                        Label("DVIR", image: "DVIR")
                    }
                    .tag(1)
                
                LogsView(showSideMenu: $showSideMenu)
                    .tabItem {
                        Label("Logs", image: "Logs")
                    }
                    .tag(2)
                
                AccountView(showSideMenu: $showSideMenu)
                    .tabItem {
                        Label("Account", image: "user_ic")
                    }
                    .tag(3)
            }
            .tint(AppColors.buttonActive) // Active tab color
            .hideTabBar(isDriving)
            
            if isDriving {
                // Robust overlay to block interaction with the tab bar area
                Color.black.opacity(0.001) // Nearly transparent but interaction-catching
                    .frame(height: 100) // Ensure it covers the entire tab bar and safe area
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Explicitly consume taps to prevent them from reaching the tab bar
                    }
                    .allowsHitTesting(true)
            }
        }
        .onChange(of: selection) { newValue in
            if isDriving && newValue != 0 {
                selection = 0
            }
            showSideMenu = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .drivingStatusChanged)) { note in
            if let status = note.object as? Bool {
                withAnimation {
                    isDriving = status
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .recapUpdate)) { _ in
            if let code = Global.shared.recapvalues?.last_event?.code?.lowercased() {
                withAnimation {
                    isDriving = (code == "d")
                }
            }
        }
        .onAppear {
            if let code = Global.shared.recapvalues?.last_event?.code?.lowercased() {
                isDriving = (code == "d")
            }
        }
    }
}

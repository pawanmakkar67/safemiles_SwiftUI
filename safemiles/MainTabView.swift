import SwiftUI

struct MainTabView: View {
    @Binding var showSideMenu: Bool
    @State private var selection = 0
    
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
    
    var body: some View {
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
        .onChange(of: selection) { _ in
            showSideMenu = false
        }
    }
}

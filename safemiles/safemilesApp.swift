//
//  safemilesApp.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import SwiftUI
import IQKeyboardManagerSwift
internal import IQKeyboardToolbarManager

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .alwaysShow
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        return true
    }
}

@main
struct safemilesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    enum AppState {
        case splash
        case login
        case content
    }
    
    @State private var appState: AppState = .splash
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState {
                case .splash:
                    SplashScreen()
                        .onAppear {
                            // Simulate splash delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    if UserDefaults.getLoginUser() != nil {
                                        appState = .content
                                    } else {
                                        appState = .login
                                    }
                                }
                            }
                        }
                case .login:
                    LoginView {
                        // On login success
                        withAnimation {
                            appState = .content
                        }
                    }
                case .content:
                    MainContainerView()
                }
            }
            .preferredColorScheme(.light)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LogoutNotification"))) { _ in
                withAnimation {
                    self.appState = .login
                }
            }
        }
    }
}

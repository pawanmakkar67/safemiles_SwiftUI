import SwiftUI


enum SideMenuOption {
    case coDriver
    case home
    case dotInspection
    case rules
    case infoPacket
    case selectVehicle
    case logout
}

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @Binding var selectedOption: SideMenuOption?
    
    // Custom Colors for this view matching the screenshot
    // Using AppColors from ColorConstants.swift
    
    var body: some View {
        ZStack {
            // Dimmed background - Always present but only visible/interactive when showing
            Color.black.opacity(isShowing ? 0.5 : 0) // Keep standard opacity logic or use AppColors.black.opacity
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
                .allowsHitTesting(isShowing) // Pass touches through when hidden
            
            HStack {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // --- Header ---
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            // Profile Image Placeholder
                            Circle()
                                .fill(AppColors.grayOpacity50)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(AppColors.white.opacity(0.5))
                                        .font(AppFonts.title)
                                )
                            
                            Spacer()
                            
                            // Menu Icon (Hamburger)
                            Button(action: {
                                withAnimation {
                                    isShowing = false
                                }
                            }) {
                                Image("Menu")
                                    .font(AppFonts.iconMedium)
                                    .foregroundColor(AppColors.textWhite)
                            }
                        }
                        
                        // User Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Global.shared.myProfile?.user?.first_name ?? "Android Studio")
                                .font(AppFonts.cardTitle)
                                .foregroundColor(AppColors.textWhite)
                            
                            Text(Global.shared.myProfile?.user?.email ?? "android.studio@android.com")
                                .font(AppFonts.bodyText)
                                .foregroundColor(AppColors.textGray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50) // Safe Area adjustment
                    .padding(.bottom, 20)
                    
                    // --- Menu Items ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            sideMenuButton(title: "Home", icon: "Home", option: .home)
                            sideMenuButton(title: "DOT Inspection", icon: "Tick", option: .dotInspection)
                            sideMenuButton(title: "Rules", icon: "Rules", option: .rules)
                            sideMenuButton(title: "Co-Driver", icon: "coDriver", option: .coDriver)
                            sideMenuButton(title: "Select Vehicle", icon: "selectVehicle", option: .selectVehicle)
                            sideMenuButton(title: "Information Packet", icon: "infoPacket", option: .infoPacket)
                            
                        }
                    }
                    
                    Spacer()
                    
                    // --- Footer ---
                    Button(action: {
                        selectedOption = .logout
                        // Logout Logic handled by parent or here if needed, but keeping consistent with enum
                    }) {
                        HStack(spacing: 16) {
                            Image("logout")
                            .font(AppFonts.buttonText)
                            .rotationEffect(.degrees(180)) // Flip to point out
                        
                        Text("Log Out")
                            .font(AppFonts.callout)
                        }
                        .foregroundColor(AppColors.textGray)
                        .padding(20)
                    }
                    .padding(.bottom, 30)
                }
                .frame(width: 300) // Fixed width for menu
                .background(AppColors.sideMenuBackground)
                .offset(x: isShowing ? 0 : -300) // Slide in/out
                
                Spacer()
            }
            NavigationLink(destination: EmptyView(), isActive: .constant(false)) { EmptyView() }
        }
    }
    
    // Helper View Builder for Menu Items
    @ViewBuilder
    private func sideMenuButton(title: String, icon: String, option: SideMenuOption) -> some View {
        let isSelected = selectedOption == option
        let contentColor = isSelected ? AppColors.sideMenuSelected : AppColors.sideMenuUnselected
        
        Button(action: {
            selectedOption = option
            isShowing = false
        }) {
            HStack(spacing: 16) {
                Image(icon)
                    .font(AppFonts.iconSmall)
                    .foregroundColor(contentColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(AppFonts.callout)
                    .foregroundColor(contentColor)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(isSelected ? AppColors.white.opacity(0.05) : AppColors.clear) // Highlight background if selected
        }
        .overlay(
            Rectangle()
                .frame(width: 4, height: nil, alignment: .leading)
                .foregroundColor(isSelected ? contentColor : AppColors.clear),
            alignment: .leading
        )
    }
}

// Helper Row Component
struct MenuRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: {
            // Navigation logic
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(AppFonts.iconSmall)
                    .foregroundColor(AppColors.textGray) // Gray icon
                    .frame(width: 24)
                
                Text(text)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.textGray) // Gray text
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
    }
}

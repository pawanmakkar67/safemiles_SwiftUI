//
//  SplashScreen.swift
//  safemiles
//
//  Created by pc on 29/01/26.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack {
                Image(systemName: "shield.fill") // Placeholder logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)
                
                Text("SafeMiles")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
            }
        }
    }
}

#Preview {
    SplashScreen()
}

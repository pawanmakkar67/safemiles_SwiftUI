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
            Color(red: 10/255, green: 10/255, blue: 10/255).ignoresSafeArea()
            
            VStack {
                Image("safemile_logo_ic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("SafeMiles")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundStyle(AppColors.white)
            }
        }
    }
}

#Preview {
    SplashScreen()
}

//
//  AboutView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/06/03.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var configStore: SettingsStore
    var body: some View {
        VStack(){
            Icon()
            Text("Randomizer").fontSemiBold(size: 40)
        }
    }
}

struct Icon: View {
    @EnvironmentObject var configStore: SettingsStore
    let rectSize: CGFloat = 160
    var body: some View{
        ZStack(){
            RoundedRectangle(cornerRadius: CGFloat(rectSize/6.4*1.5))
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: configStore.giveBackground()),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: rectSize, height: rectSize)
            VStack(){
                Text("No.2").fontLight(size: 16)
                Text("52").fontSemiBoldRound(size: 78, rolling: false)
                Spacer().frame(height: 0.1)
                HStack(){
                    Text("Next")
                        .fontSemiBold(size: 18)
                        .padding(2)
                        .frame(width: 55, height: 30)
                        .glassIconMaterial(cornerRadius: 8)
                    Spacer().frame(width: 13)
                    Text("Reset")
                        .fontSemiBold(size: 18)
                        .padding(2)
                        .frame(width: 55, height: 30)
                        .glassIconMaterial(cornerRadius: 8)
                }
            }
        }
        
    }
}

#Preview {
    AboutView()
        .environmentObject(SettingsStore())
}

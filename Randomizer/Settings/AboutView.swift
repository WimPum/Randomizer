//
//  AboutView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/06/03.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var configStore: SettingsStore
    @Binding var isPresented: Bool
    
    // アプリバージョン
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        VStack(){
            Spacer(minLength: 30)
            Icon()
            Text("Randomizer").font(.system(size: CGFloat(40), weight: .semibold, design: .default))
            //Spacer().frame(height: 100)
            Text("v\(appVersion)").padding(1)
            Text("iOS \(UIDevice.current.systemVersion)").padding(1)
            Link("Website", destination: URL(string: "https://wimpum.github.io/Rndsite/")!).padding(1)
            Link("View code on GitHub", destination: URL(string: "https://github.com/WimPum/Randomizer")!).padding(1)
            Spacer()
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    isPresented = false
                }){//どうしよう？
                    Text("Done")
                        .bold()
                        .padding(5)
                }
            }
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
                    Spacer().frame(width: 18)
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

//#Preview {
//    AboutView()
//        .environmentObject(SettingsStore())
//}

//
//  ExternalView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import SwiftUI

struct ExternalView: View {
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjになった設定
    @EnvironmentObject var externalStore: ExternalBridge
    var body: some View {
        ZStack(){
            LinearGradient(gradient: Gradient(colors: configStore.giveBackground()),
                           startPoint: .top, endPoint: .bottom)//このcolorsだけ変えればいいはず
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: configStore.giveBackground())
            VStack(){
//                Text(verbatim: String(externalStore.externalNumber)).fontSemiBoldRound(size: 2000, rolling: false) // rollingも変えられるようにする
                Text(verbatim: "\(externalStore.externalRollSeq![externalStore.externalRollCount-1])")
                    .fontSemiBoldRound(size: 2000, rolling: externalStore.isExternalRolling)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .minimumScaleFactor(0.2)
            }.padding()
        }
    }
}

#Preview {
    ExternalView()
        .environmentObject(SettingsStore())
        .environmentObject(ExternalBridge.shared)
}

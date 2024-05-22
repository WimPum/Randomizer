//
//  ExternalView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import SwiftUI

struct LandscapeView: View {
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjになった設定
    @EnvironmentObject var randomStore: RandomizerState
    var body: some View {
        ZStack(){
            LinearGradient(gradient: Gradient(colors: configStore.giveBackground()),
                           startPoint: .top, endPoint: .bottom)//このcolorsだけ変えればいいはず
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: configStore.giveBackground())
            VStack(){
//                Text(verbatim: String(externalStore.externalNumber)).fontSemiBoldRound(size: 2000, rolling: false) // rollingも変えられるようにする
                Text(verbatim: "\(randomStore.rollDisplaySeq![randomStore.rollListCounter-1])")
                    .fontSemiBoldRound(size: 2000, rolling: randomStore.isTimerRunning)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .minimumScaleFactor(0.2)
            }.padding()
        }
    }
}

#Preview {
    LandscapeView()
        .environmentObject(SettingsStore())
        .environmentObject(RandomizerState.shared)
}

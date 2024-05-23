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
    @State private var showingAlert: Bool = false
    var body: some View {
        ZStack(){
            LinearGradient(gradient: Gradient(colors: configStore.giveBackground()),
                           startPoint: .top, endPoint: .bottom)//このcolorsだけ変えればいいはず
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: configStore.giveBackground())
            Button(action: {
                if randomStore.isButtonPressed == false{
                    randomStore.isButtonPressed = true
                    print("big number pressed")
                    buttonNext()
                }
            }){
                Text(verbatim: "\(randomStore.rollDisplaySeq![randomStore.rollListCounter-1])")
                    .fontSemiBoldRound(size: 320, rolling: randomStore.isTimerRunning)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .minimumScaleFactor(0.2)
            }.disabled(randomStore.isButtonPressed)
                .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in//振ったら
                    if randomStore.isButtonPressed == false{
                        randomStore.isButtonPressed = true
                        print("device shaken!")
                        buttonNext()
                    }
                }
            .alert("All drawn", isPresented: $showingAlert) {
                // アクションボタンリスト
            } message: {
                Text("press Start over to reset")
            }
        }
    }
    
    func buttonNext() {
        if randomStore.drawCount >= randomStore.drawLimit{ // チェック
            self.showingAlert.toggle()
            randomStore.isButtonPressed = false
        }
        else{
            randomStore.randomNumberPicker(mode: 1, configStore: configStore)//まとめました
        }
    }
}

#Preview {
    LandscapeView()
        .environmentObject(SettingsStore())
        .environmentObject(RandomizerState.shared)
}

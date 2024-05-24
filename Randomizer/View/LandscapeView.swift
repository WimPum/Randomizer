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
        .onAppear{
            initReset()
        }
    }
    
    func initReset() {//起動時に実行 No.0/表示: 0
        randomStore.isButtonPressed = false // 操作できない状態にしない
        randomStore.drawLimit = randomStore.maxBoxValueLock - randomStore.minBoxValueLock + 1
        print("HistorySequence \(randomStore.historySeq as Any)\ntotal would be No.\(randomStore.drawLimit)")
//        for i in 1...99990{
//            randomStore.historySeq!.append(i)
//            print(i)
//        }//履歴に数字をたくさん追加してパフォーマンス計測 O(N) は重い。。。
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

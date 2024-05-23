//
//  RandomizerState.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/22.
//

import SwiftUI

// 外部ディスプレイ対応
// 参考：https://useyourloaf.com/blog/swiftui-supporting-external-screens/

final class RandomizerState: ObservableObject{
    //main
    @AppStorage("minValue") var minBoxValueLock: Int = 1 // min->maxの順
    @AppStorage("maxValue") var maxBoxValueLock: Int = 50//Start Overを押すまでここにkeep
    @Published var drawCount: Int = 0       //今何回目か
    @Published var drawLimit: Int = 0       //何回まで引けるか
    @Published var realAnswer: Int = 0      //本当の答え
    
    //history&Shuffler
    @Published var historySeq: [Int]? = []     //履歴 ない時は0じゃなくてEmpty
    @Published var remainderSeq: [Int] = [0]    //弾いていって残った数字 ロール用
    @Published var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//名前をセーブするなら変更
    @Published var rollListCounter: Int = 1     //ロールのリスト上を移動
    @Published var isTimerRunning: Bool = false
    @Published var isButtonPressed: Bool = false//同時押しを無効にするDirtyHack
    @Published var rollTimer: Timer?
    @Published var rollSpeed: Double = 25       //実際のスピードをコントロール 25はrollMaxSpeed
    let rollMinSpeed: Double = 0.4//始めは早く段々遅く　の設定 デフォルトは4倍にして使います。
    let rollMaxSpeed: Double = 6
    
    static let shared = RandomizerState() // 参考
    
    func randomNumberPicker(mode: Int, configStore: SettingsStore){//アクションを一つにまとめた mode 1はNext, mode 2はリセット
        drawLimit = maxBoxValueLock - minBoxValueLock + 1 // ここで異常を起こしている可能性あり?
        
        if mode == 1{ // mode 1はnext
            drawCount += 1 // draw next number
        }
        else if mode == 2{
            drawCount = 1
        }
        remainderSeq = [Int]()
        
        rollSpeed = interpolateQuadratic(t: 0, minValue: rollMinSpeed * Double(configStore.rollingSpeed + 3), maxValue: rollMaxSpeed * Double(configStore.rollingSpeed)) //速度計算 0?????
        
        rollListCounter = 1
        
        let remaining = drawLimit - drawCount + 1 // 残り
        print("\(remaining) numbers remaining")
        realAnswer = give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq)
        logging(realAnswer: realAnswer) // ログ　releaseでは消す
        if configStore.isRollingOn && remaining > 1{
            let ifRemainedMore = remaining > configStore.rollingCountLimit // ロール用に選ぶ数字の量を決定 少ない時は残りの数 多ければrollingCountLimitの数選ぶ
            var historySeqforRoll = [Int]()     //履歴
            var pickedNumber: Int//上のhistorySeqforRollとともに下のforループでのみ使用
            for _ in (1...Int(ifRemainedMore ? configStore.rollingCountLimit : remaining)){ // trueなら前
                if ifRemainedMore{
                    remainderSeq.append(give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq))//ここ変えます
                }else{
                    repeat{
                        pickedNumber = give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq)
                    }while(historySeqforRoll.contains(pickedNumber))
                    historySeqforRoll.append(pickedNumber)
                    remainderSeq.append(pickedNumber)
                }
            }
            rollDisplaySeq = giveRandomSeq(contents: remainderSeq, length: configStore.rollingCountLimit, realAnswer: realAnswer)
            startTimer(configStore: configStore)//ロール開始, これで履歴にも追加
        }else{//1番最後と、ロールを無効にした場合こっちになります
            configStore.giveRandomBgNumber()
            historySeq?.append(realAnswer)//履歴追加
            rollDisplaySeq = [realAnswer]//答えだけ追加
            giveHaptics(impactType: "medium", ifActivate: configStore.isHapticsOn)
            isButtonPressed = false
        }
    }
    
    //タイマーに使用される関数
    func startTimer(configStore: SettingsStore) {
        isTimerRunning = true
        rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / rollSpeed, repeats: true) { timer in
            if self.rollListCounter + 1 >= configStore.rollingCountLimit {
                self.rollListCounter += 1
                configStore.giveRandomBgNumber()
                    //iOS 17 ではボタンの文字までアニメーションされる
                    //iOS 15,16ではそもそも発生しない
                self.stopTimer()
                self.historySeq?.append(self.realAnswer)//"?"//現時点でのrealAnswer
                giveHaptics(impactType: "medium", ifActivate: configStore.isHapticsOn)
                self.isButtonPressed = false
                return
            }
            else{
                giveHaptics(impactType: "soft", ifActivate: configStore.isHapticsOn)
                
                let t: Double = Double(self.rollListCounter) / Double(configStore.rollingCountLimit)//カウントの進捗
                self.rollSpeed = interpolateQuadratic(t: t, minValue: self.rollMinSpeed * Double(configStore.rollingSpeed + 3), maxValue: self.rollMaxSpeed * Double(configStore.rollingSpeed)) //速度計算
                // print("Now rolling aty \(rollSpeed), t is \(t)")
                self.updateTimerSpeed(configStore: configStore)
                self.rollListCounter += 1
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false
        rollTimer?.invalidate()//タイマーを止める。
        rollTimer = nil // 大丈夫か？止まらない説
    }

    func updateTimerSpeed(configStore: SettingsStore) {
        if isTimerRunning {
            stopTimer()
            startTimer(configStore: configStore)
        }
    }
    
    func logging(realAnswer: Int) {
        print("///////////////DEBUG SECTION")
        print("Randomly picked remain: \(remainderSeq)")
        print("displaySeq: \(rollDisplaySeq as Any)")//ロール中は押せない
        print("HistorySequence is \(historySeq as Any)")
        print("current draw is \(realAnswer) and No.\(drawCount)")
        print("total is \(drawLimit)")
        print("///////////////END OF DEBUG SECTION")
    }
}

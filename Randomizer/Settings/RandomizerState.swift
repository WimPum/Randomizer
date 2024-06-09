//
//  RandomizerState.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/22.
//

import SwiftUI

// 横画面対応
// 参考：https://useyourloaf.com/blog/swiftui-supporting-external-screens/

final class RandomizerState: ObservableObject{
    // main
    @AppStorage("minValue") var minBoxValueLock: Int = 1 // min->maxの順
    @AppStorage("maxValue") var maxBoxValueLock: Int = 50//Start Overを押すまでここにkeep
    @Published var drawCount: Int = 0       //今何回目か
    @Published var drawLimit: Int = 0       //何回まで引けるか
    @Published var realAnswer: Int = 0      //本当の答え
    
    // history&Shuffler
    @Published var historySeq: [Int]? = []      //履歴 ない時は0じゃなくてEmpty
    private var remainderSeq: [Int] = [0]    //弾いていって残った数字 ロール用
    @Published var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//名前をセーブするなら変更
    @Published var rollListCounter: Int = 1     //ロールのリスト上を移動
    @Published var isTimerRunning: Bool = false
    @Published var isButtonPressed: Bool = false//同時押しを無効にする
    var rollTimer: Timer?
    var rollSpeed: Double = 25       //実際のスピードをコントロール 25はrollMaxSpeed
    let rollMinSpeed: Double = 0.4//始めは早く段々遅く　の設定 デフォルトは4倍にして使います。
    let rollMaxSpeed: Double = 6
    
    // fileImporter
    @Published var openedFileName = ""          //ファイル名表示用
    @Published var isFileSelected: Bool = false
    @Published var csvNameStore = [[String]]()  //名前を格納する
    
    static let shared = RandomizerState() // 参考
    
    func randomNumberPicker(mode: Int, configStore: SettingsStore) async {//アクションを一つにまとめた
        //mode 1はNext, mode 2はリセット
        await MainActor.run{
            isButtonPressed = true // おさせるものか
            drawLimit = maxBoxValueLock - minBoxValueLock + 1
            if mode == 1{ // mode 1はnext
                drawCount += 1 // draw next number
            }
            else if mode == 2{
                drawCount = 1
            }
            remainderSeq = [Int]()
            rollSpeed = interpolateQuadratic(t: 0, minValue: rollMinSpeed * Double(configStore.rollingSpeed + 3), maxValue: rollMaxSpeed * Double(configStore.rollingSpeed)) //速度計算 初期状態
            rollListCounter = 1
        }
        
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
            print("Updating rollDisplaySeq with: \(String(describing: rollDisplaySeq))")
            withAnimation{
                if openedFileName != ""{
                    isFileSelected = true
                }else{
                    isFileSelected = false
                }
            }
            startTimer(configStore: configStore)//ロール開始, これで履歴にも追加
        }else{//1番最後と、ロールを無効にした場合こっちになります
            await MainActor.run{
                configStore.giveRandomBgNumber()
                historySeq?.append(realAnswer)//履歴追加
                rollDisplaySeq = [realAnswer]//答えだけ追加
                giveHaptics(impactType: "medium", ifActivate: configStore.isHapticsOn)
                isButtonPressed = false
            }
        }
    }
    
    //タイマーに使用される関数
    // startTimerからupdateを呼び、stopしてまたstartTimerを呼ぶというのは廃止されます
    func startTimer(configStore: SettingsStore) {
        Task { @MainActor in
            isTimerRunning = true
            rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / rollSpeed, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task{
                    await self.timerCountHandler(configStore: configStore)
                }
            }
        }
    }

    func timerCountHandler(configStore: SettingsStore) async {
        await MainActor.run{
            print("\(rollListCounter), \(configStore.rollingCountLimit)")
            if self.rollListCounter == configStore.rollingCountLimit {
                // rollListCounterが無茶苦茶な増え方をしている
                // あとスピードもおかしい
                //self.rollListCounter += 1
                configStore.giveRandomBgNumber()
                self.stopTimer()
                self.historySeq?.append(self.realAnswer)//"?"//現時点でのrealAnswer
                giveHaptics(impactType: "medium", ifActivate: configStore.isHapticsOn)
                if configStore.isAutoDrawOn != true{
                    self.isButtonPressed = false // AutoDrawモードでないならそのまま終了
                }
            }
            else{
                giveHaptics(impactType: "soft", ifActivate: configStore.isHapticsOn)
                let t: Double = Double(self.rollListCounter) / Double(configStore.rollingCountLimit)//カウントの進捗
                self.rollSpeed = interpolateQuadratic(t: t, minValue: self.rollMinSpeed * Double(configStore.rollingSpeed + 3), maxValue: self.rollMaxSpeed * Double(configStore.rollingSpeed)) //速度計算
                // print("Now rolling aty \(rollSpeed), t is \(t)")
                self.rollListCounter += 1
                self.updateTimerSpeed(configStore: configStore)
            }
        }
    }
    
    func stopTimer() {
        self.rollTimer?.invalidate()//タイマーを止める。
        self.rollTimer = nil
        self.isTimerRunning = false
    }

    func updateTimerSpeed(configStore: SettingsStore) {
        guard isTimerRunning else { return } // 動いてなかったらupdateしなーい！
        if self.isTimerRunning {
            self.rollTimer?.invalidate()
            self.rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / self.rollSpeed, repeats: true) { [weak self] _ in
                guard let self = self else { return } // ?
                Task{
                    await self.timerCountHandler(configStore: configStore)
                }
            }
        }
    }
    
    func autoDrawMode(mode: Int, configStore: SettingsStore) async {
        if configStore.isAutoDrawOn == true{
            print("No.\(drawCount), Limmit is \(drawLimit)")
            await self.randomNumberPicker(mode: mode, configStore: configStore) // 1回目実行 リセットか続行かはmodeで指定される
            while drawLimit > drawCount{
                try? await Task.sleep(nanoseconds: UInt64(configStore.AutoDrawInterval * 1_000_000_000)) // うわああああ
                await self.randomNumberPicker(mode: 1, configStore: configStore) // 関数終わるまで待ってくれる
            }
            isButtonPressed = false // 最後に実行
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

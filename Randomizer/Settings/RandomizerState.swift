//
//  RandomizerState.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/22.
//

import SwiftUI
import CoreData

// 横画面対応
// 参考：https://useyourloaf.com/blog/swiftui-supporting-external-screens/

final class RandomizerState: ObservableObject{
    // main
    @AppStorage("minValue") var minBoxValueLock: Int = 1 // min->maxの順
    @AppStorage("maxValue") var maxBoxValueLock: Int = 50//Start Overを押すまでここにkeep
    @Published var drawCount: Int = 0       //今何回目か
    @Published var drawLimit: Int = 0       //何回まで引けるか
    @Published var realAnswer: Int = 0      //本当の答え
    
    private var viewContext: NSManagedObjectContext { // これ何してるん
        return DataController.shared.viewContext
    }
    
    // history&Shuffler
    @Published var historySeq: [Int]? = []      //履歴 ない時は0じゃなくてEmpty　これをCoreDataにする
    private var remainderSeq: [Int] = [0]    //弾いていって残った数字 ロール用
    @Published var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//起動直後はこの0が表示されている
    @Published var rollListCounter: Int = 1     //ロールのリスト上を移動
    @Published var isTimerRunning: Bool = false
    @Published var isButtonPressed: Bool = false//同時押しを無効にするDirtyHack
    var rollTimer: Timer?
    var rollSpeed: Double = 25       //実際のスピードをコントロール 25はrollMaxSpeed
    let rollMinSpeed: Double = 0.4//始めは早く段々遅く　の設定 デフォルトは4倍にして使います。
    let rollMaxSpeed: Double = 6
    
    // fileImporter
    @Published var openedFileName = ""          //ファイル名表示用
    @Published var isFileSelected: Bool = false
    @Published var csvNameStore = [[String]]()  //名前を格納する
    
    static let shared = RandomizerState() // 参考
    

    init() {
        //DispatchQueue.global(qos: .background).async { // 治らん
            self.loadHistory()
        //}
    }
    
    func randomNumberPicker(mode: Int, configStore: SettingsStore){//アクションを一つにまとめた mode 1はNext, mode 2はリセット
        drawLimit = maxBoxValueLock - minBoxValueLock + 1
        
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
        if configStore.isRollingOn && remaining > 1{
            let ifRemainedMore = remaining > configStore.rollingCountLimit // ロール用に選ぶ数字の量を決定 少ない時は残りの数 多ければrollingCountLimitの数選ぶ
            let limit = ifRemainedMore ? configStore.rollingCountLimit : remaining
            var historySeqforRoll = Set<Int>()     //履歴SET!!!!!
            var pickedNumber: Int//上のhistorySeqforRollとともに下のforループでのみ使用
            for _ in (1...limit){ // trueなら前
                if ifRemainedMore{
                    remainderSeq.append(give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq))//ここ変えます
                }else{
                    repeat{
                        pickedNumber = give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq)
                    }while historySeqforRoll.contains(pickedNumber) // ??
                    historySeqforRoll.insert(pickedNumber)
                    remainderSeq.append(pickedNumber)
                }
            }
            rollDisplaySeq = giveRandomSeq(contents: remainderSeq, length: configStore.rollingCountLimit, realAnswer: realAnswer)
            logging(realAnswer: realAnswer) // ログ　releaseでは消す
            startTimer(configStore: configStore)//ロール開始, これで履歴にも追加
        }else{//1番最後と、ロールを無効にした場合こっちになります
            configStore.giveRandomBgNumber()
            historySeq?.append(realAnswer) //履歴追加
            saveHistory(value: realAnswer) //履歴ほぞん
            rollDisplaySeq = [realAnswer]//答えだけ追加
            giveHaptics(impactType: "medium", ifActivate: configStore.isHapticsOn)
            isButtonPressed = false
        }
    }
    
    //タイマーに使用される関数
    // startTimerからupdateを呼び、stopしてまたstartTimerを呼ぶというのは廃止されます
    func startTimer(configStore: SettingsStore) {
        isTimerRunning = true
        rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / rollSpeed, repeats: true) { timer in
            self.timerCountHandler(configStore: configStore)
        }
    }

    func timerCountHandler(configStore: SettingsStore){
        if self.rollListCounter + 1 >= configStore.rollingCountLimit {
            self.stopTimer()
            self.rollListCounter += 1
            configStore.giveRandomBgNumber()
            self.historySeq?.append(self.realAnswer)//"?"//現時点でのrealAnswer
            saveHistory(value: realAnswer) // こっちも保存
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
    
    func stopTimer() {
        self.isTimerRunning = false
        self.rollTimer?.invalidate()//タイマーを止める。
        self.rollTimer = nil
    }

    func updateTimerSpeed(configStore: SettingsStore) {
        if self.isTimerRunning == true {
            self.rollTimer?.invalidate()
            self.rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / self.rollSpeed, repeats: true) { timer in
                self.timerCountHandler(configStore: configStore)
            }
        }
    }

    // 保存された履歴読み込み
    func loadHistory(){
        let fetchRequest: NSFetchRequest<HistoryDataSeq> = HistoryDataSeq.fetchRequest()
        do {
            let items = try viewContext.fetch(fetchRequest)
            if items.isEmpty {
                print("Nyow items fuwund")
                historySeq = []
            } else {
                historySeq = items.map { Int($0.value) }
            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // 履歴保存
    private func saveHistory(value: Int) {
        let new = HistoryDataSeq(context: viewContext)
        new.value = Int64(value)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // 使わない
    private func deleteOneHistory(item: HistoryDataSeq){
        viewContext.delete(item)
        do{
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // 履歴削除 外からも消します
    func clearHistory(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HistoryDataSeq.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
            historySeq = []
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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

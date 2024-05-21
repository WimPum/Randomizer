//本コード

import SwiftUI
import Foundation //Random
import UniformTypeIdentifiers //fileImporter

struct ContentView: View {
    //main
    @State private var minBoxValue: String = "1"
    @State private var maxBoxValue: String = "50"
    @AppStorage("minValue") private var minBoxValueLock: Int = 1 // min->maxの順
    @AppStorage("maxValue") private var maxBoxValueLock: Int = 50//Start Overを押すまでここにkeep
    @State private var drawCount: Int = 0       //今何回目か
    @State private var drawLimit: Int = 0       //何回まで引けるか
    @State private var realAnswer: Int = 0      //本当の答え
    
    //history&Shuffler
    @State private var historySeq: [Int]? = []     //履歴 ない時は0じゃなくてEmpty
    @State private var remainderSeq: [Int] = [0]    //弾いていって残った数字 ロール用
    @State private var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//名前をセーブするなら変更
    @State private var rollListCounter: Int = 1     //ロールのリスト上を移動
    @State private var isTimerRunning: Bool = false
    @State private var isButtonPressed: Bool = false//同時押しを無効にするDirtyHack
    @State private var rollTimer: Timer?
    @State private var rollSpeed: Double = 25       //実際のスピードをコントロール 25はrollMaxSpeed
    private let rollMinSpeed: Double = 0.4//始めは早く段々遅く　の設定 デフォルトは4倍にして使います。
    private let rollMaxSpeed: Double = 6

    //fileImporter
    @State private var openedFileName = ""//ファイル名表示用
    @State private var openedFileLocation = URL(string: "file://")!//defalut値確認
    @State private var isOpeningFile = false                                            //ファイルダイアログを開く変数
    @State private var isFileSelected: Bool = false//isFileLoadedは起動時にファイルを読み込もうとしていた時の遺産
    @State private var csvNameStore = [[String]]()                              //名前を格納する
    @State private var showMessage: String = ""
    @State private var showMessageOpacity: Double = 0.0 //0.0と0.6の間を行き来します
    
    //1st view(main) variables
    @State private var showCSVButtonAndName: Bool = true // キーボード入力する時に1番上と名前表示する部分を隠す
    @FocusState private var isInputMinFocused: Bool//キーボードOn/Off
    @FocusState private var isInputMaxFocused: Bool//キーボードOn/Off
    @State private var showingAlert = false     //アラートは全部で2つ
    @State private var showingAlert2 = false    //数値を入力/StartOver押す指示
    private let inputMaxLength: Int = 10                      //最大桁数
    
    //設定画面用
    @ObservedObject var configStore = SettingsBridge()//設定をここに置いていく
    
    //外部ディスプレイ用
    @EnvironmentObject var externalStore: ExternalBridge
    
    //misc
    @State private var viewSelection = 1    //ページを切り替える用
    @State private var isSettingsView: Bool = false//設定画面を開く用

    var body: some View {
        ZStack { //グラデとコンテンツを重ねるからZStack
            LinearGradient(gradient: Gradient(colors: returnColorCombo(index: configStore.gradientPicker)),
                           startPoint: .top, endPoint: .bottom) // testing only()
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: returnColorCombo(index: configStore.gradientPicker))
            TabView(selection: $viewSelection){
                VStack(){//１ページ目
                    Spacer().frame(height: 5)
                    if showCSVButtonAndName == true{ //キーボード出す時は隠してます
                        HStack(){
                            Button(action: {self.isOpeningFile.toggle()}){
                                Text("open csv").padding(13)
                            }
                            Spacer()//左端に表示する
                            Button(action: {self.isSettingsView.toggle()}){
                                Image(systemName: "gearshape.fill").padding(.trailing, 12.0)
                            }
                        }
                        .fontSemiBold(size: 24)//フォントとあるがSF Symbolsだから
                        .disabled(isButtonPressed)
                    }
                    Spacer()
                    VStack(){                                                               //上半分
                        Text("No.\(drawCount)")
                            .fontMedium(size: 32)
                            .frame(height: 40)
                        Button(action: {
                            if isButtonPressed == false{
                                isButtonPressed = true
                                print("big number pressed")
                                buttonNext()
                            }
                        }){
                            Text(verbatim: "\(rollDisplaySeq![rollListCounter-1])")
                                .fontSemiBoldRound(size: 160, rolling: isTimerRunning)
                                .frame(width: UIScreen.current?.bounds.width, height: 170)
                                .minimumScaleFactor(0.2)
                        }.disabled(isButtonPressed)
                            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in//振ったら
                                if isButtonPressed == false{
                                    isButtonPressed = true
                                    print("device shaken!")
                                    buttonNext()
                                }
                            }
                        if showCSVButtonAndName == true{ //キーボード出す時は隠してます
                            Text(isFileSelected ? csvNameStore[0][rollDisplaySeq![rollListCounter-1]-1]: showMessage)//ファイルあれば
                                .fontSemiBold(size: 26)
                                .multilineTextAlignment(.center)
                                .opacity(showMessageOpacity)
                                .frame(height: 60)
                                .padding(.horizontal, 10)
                                .minimumScaleFactor(0.2)
                        }
                        
                    }
                    Spacer()//何とか
                    VStack(){                                                               //下半分
                        if isFileSelected == false {
                            Spacer(minLength: 10)
                            HStack(){
                                Spacer()
                                VStack{//ここstructとかで省略できないか？
                                    Text("Min")
                                        .fontMedium(size: 24)
                                    limitedTextField(value: $minBoxValue, placeHolder: "Min", maxLength: inputMaxLength)
                                        .onTapGesture {
                                            print("TextField Min tapped")
                                            isInputMinFocused = true
                                            withAnimation {
                                                showCSVButtonAndName = false
                                            }
                                        }
                                        .background(Color.clear)
                                        .setUnderline()
                                        .frame(width: 120)
                                        .focused($isInputMinFocused)
                                        .disabled(isButtonPressed)
                                }
                                Spacer()
                                VStack{
                                    Text("Max")
                                        .fontMedium(size: 24)
                                    limitedTextField(value: $maxBoxValue, placeHolder: "Max", maxLength: inputMaxLength)
                                        .onTapGesture {
                                            print("TextField Max tapped")
                                            isInputMaxFocused = true
                                            withAnimation {
                                                showCSVButtonAndName = false
                                            }
                                        }
                                        .background(Color.clear)
                                        .setUnderline()
                                        .frame(width: 120)
                                        .focused($isInputMaxFocused)
                                        .disabled(isButtonPressed)
                                }
                                Spacer()
                            }
                        }
                        else{
                            HStack(){
                                Text(self.openedFileName)// select csv file
                                    .fontMedium(size: 20)
                            }
                            Button(action: {
                                print("button csvClear! pressed")
                                fileReset()
                            }){
                                Text("clear names")
                                    .fontSemiBold(size: 18)
                                    .padding()
                                    .frame(width:140, height: 36)
                                    .glassMaterial(cornerRadius: 24)
                            }.disabled(isButtonPressed)
                        }
                    }.toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button(action: {
                                print("keyboard min! pressed")
                                isInputMinFocused = true
                            }){
                                Text("Min")
                            }
                            Button(action: {
                                print("keyboard max! pressed")
                                isInputMaxFocused = true
                            }){
                                Text("Max")
                            }
                            Spacer()
                            Button(action: {
                                print("keyboard done! pressed")
                                buttonKeyDone()
                            }){
                                Text("Done").bold()
                            }
                        }
                    }
                    .frame(height: 90)
                        //.border(.green)
                    Spacer()
                    HStack(){ // lower buttons.
                        Spacer()
                        Button(action: {
                            if isButtonPressed == false{
                                isButtonPressed = true
                                print("next button pressed")
                                buttonNext()
                            }
                        }){
                            Text("Next draw")
                                .glassButton()
                        }.disabled(isButtonPressed)
                        .alert("All drawn", isPresented: $showingAlert) {
                            // アクションボタンリスト
                        } message: {
                            Text("press Start over to reset")
                        }
                        Spacer()
                        Button(action: {
                            if isButtonPressed == false{
                                isButtonPressed = true
                                print("reset button pressed")
                                buttonReset()
                            }
                        }) {
                            Text("Start over")
                                .glassButton()
                        }.disabled(isButtonPressed)
                        .alert("Error", isPresented: $showingAlert2) {
                            // アクションボタンリスト
                        } message: {
                            Text("put bigger number on right box")
                        }
                        Spacer()
                    }
                    Spacer(minLength: 20)
                }
                .tabItem {
                  Text("Main") }
                .tag(1)

                VStack(){
                    Spacer(minLength: 5)
                    //Spacer().frame(height: 20)//これは知らなかった
                    Text("History")//リストを表示
                        .fontSemiBold(size: 20)
                        .padding()//should be here
                    if let screenWidth = UIScreen.current?.bounds.width, let historySeq = historySeq{//historySeqに値入ってたら
                        if historySeq.count > 0{
                            List {
                                ForEach(0..<historySeq.count, id: \.self){ index in
                                    HStack(){
                                        Text("No.\(index+1)")
                                            .fontLight(size: 25)
                                        Spacer()
                                        Text("\(historySeq[index])")
                                            .fontSemiBold(size: 40)
                                            .frame(width: screenWidth - 140,
                                                   height: 40,
                                                   alignment: .trailing)
                                            //.border(.red)
                                            .minimumScaleFactor(0.2)
                                    }.listRowBackground(Color.clear)//リストの項目の背景を無効化
                                }
                            }
                            .scrollCBIfPossible()//リストの背景を無効化
                            .listStyle(.plain)
                            .frame(width: screenWidth,
                                   //height: (UIScreen.current?.bounds.height)!-120,//CRASHED
                                   alignment: .center)
                            //.border(.red, width: 3)
                        }else{
                            Color.clear // 何もない時
                                .frame(width: screenWidth,
                                       //height: (UIScreen.current?.bounds.height)!-120,//CRASHED
                                       alignment: .center)
                        }
                    }
                    Spacer(minLength: 20)/*.frame(height: 10)*/
                }
                .tabItem {
                  Text("History") }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: viewSelection, perform: { _ in // 入力中にページが切り替わっても隠れた物は元に戻る
                if viewSelection == 2{ // 1以外ないけど
                    showCSVButtonAndName = true
                    isInputMinFocused = false
                    isInputMaxFocused = false
                }
            })
            .ignoresSafeArea(edges: .top)
        }
        .onAppear{//起動時に実行となる　このContentViewしかないから
            initReset()
        }
        .sheet(isPresented: self.$isSettingsView){
            SettingsView(isPresentedLocal: self.$isSettingsView)
        }//設定画面
        .fileImporter( isPresented: $isOpeningFile, allowedContentTypes: [UTType.commaSeparatedText], allowsMultipleSelection: false
        ){ result in
            if case .success = result {
                do{
                    let fileURL: URL = try result.get().first!
                    //self.fileName = fileURL.first?.lastPathComponent ?? "file not available"
                    self.openedFileLocation = fileURL//これでFullパス
                    self.openedFileName = openedFileLocation.lastPathComponent //名前だけ
                    print(openedFileLocation)
                    if openedFileLocation.startAccessingSecurityScopedResource() {
                        print("loading files")
                        if let csvNames = loadCSV(fileURL: openedFileLocation) {//loadCSVでロードできたら
                            isButtonPressed = true //ボタンを押せないようにする
                            csvNameStore = csvNames
                            print(csvNameStore)
                            isFileSelected = true
                            buttonReset()
                        }else{
                            isFileSelected = false
                            print("no files")
                            openedFileName = ""//リセット
                            csvNameStore = [[String]]()//空
                            showMessage = setMessageErrorLoad(language: firstLang())//この時だけこれ
                            withAnimation{
                                showMessageOpacity = 0.6
                            }
                        }
                    }
                }
                catch{//このcatchとelse機能してない
                    print("error reading file \(error.localizedDescription)")
                }
            }
            else{
                print("File Import Failed")
            }
        }
    }
    
    func fileReset() {
        print("cleared files")
        openedFileName = ""//リセット
        withAnimation{
            showMessageOpacity = 0.0
        }
        showMessage = setMessageReset(language: firstLang())//変更するけど見えない
        isFileSelected = false
        csvNameStore = [[String]]()//空　isFileSelected の後じゃないと落ちる
    }
    
    func initReset() {//起動時に実行 No.0/表示: 0
        isButtonPressed = false // 操作できない状態にしない
        minBoxValue = String(minBoxValueLock)//保存から復元
        maxBoxValue = String(maxBoxValueLock)
        drawLimit = maxBoxValueLock - minBoxValueLock + 1
        showMessage = setMessageReset(language: firstLang())
        configStore.gradientPicker = giveRandomBackground(conf: configStore.configBgColor, current: configStore.gradientPicker)//背景初期化
        externalStore.externalGradient = configStore.gradientPicker
        print("HistorySequence \(historySeq as Any)\ntotal would be No.\(drawLimit)")
//        for i in 1...99990{
//            historySeq!.append(i)
//            print(i)
//        }//履歴に数字をたくさん追加してパフォーマンス計測 O(N) は重い。。。
    }
    
    
    func buttonReset() {
        showCSVButtonAndName = true
        if isFileSelected == true{ //ファイルが選ばれたら自動入力
            minBoxValue = "1"
            maxBoxValue = String(csvNameStore[0].count)
            showMessageOpacity = 0.6
        }else{
            withAnimation{//まず非表示？
                showMessageOpacity = 0.0
            }
            showMessage = setMessageReset(language: firstLang())//違ったら戻す
        }
        //Reset固有
        historySeq = []//リセットだから?????????????
        if (minBoxValue == "") { // 入力値が空だったら現在の値で復元
            minBoxValue = String(minBoxValueLock)
        }
        if (maxBoxValue == "") {
            maxBoxValue = String(maxBoxValueLock)
        }
        if Int(minBoxValue)! >= Int(maxBoxValue)!{ // チェック
            self.showingAlert2.toggle()
            isButtonPressed = false
            return
        }
        minBoxValueLock = Int(minBoxValue)!
        maxBoxValueLock = Int(maxBoxValue)!
        print("mmBoxVal: \(minBoxValue), \(maxBoxValue)")
        
        randomNumberPicker(mode: 2)//まとめた
    }
    
    func buttonNext() {
        showCSVButtonAndName = true
        if drawCount >= drawLimit{ // チェック
            self.showingAlert.toggle()
            isButtonPressed = false
        }
        else{
            if isFileSelected == false{ //ファイルが選ばれてなかったら
                if maxBoxValue == String(maxBoxValueLock) && minBoxValue == String(minBoxValueLock){
                    withAnimation{//まず非表示？
                        showMessageOpacity = 0.0
                    }
                }
                showMessage = setMessageReset(language: firstLang())//違ったら戻す
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // Nextを押すと変更されたことを通知できなかった
                    if maxBoxValue != String(maxBoxValueLock) || minBoxValue != String(minBoxValueLock){
                        showMessage = setMessageReset(language: firstLang())//絶対にStartOverと表示
                        withAnimation{
                            showMessageOpacity = 0.6
                        }
                    }else{
                        withAnimation{
                            showMessageOpacity = 0.0
                        }
                    }
                }
            }
            randomNumberPicker(mode: 1)//まとめました
        }
    }
    
//    func autoGenMode() {
//        buttonNext()
//    }
    
    func buttonKeyDone(){
        showMessageOpacity = 0.0 // 名前欄の透明度リセットします
        showCSVButtonAndName = true
        isInputMaxFocused = false
        isInputMinFocused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if maxBoxValue != String(maxBoxValueLock) || minBoxValue != String(minBoxValueLock){
                showMessage = setMessageReset(language: firstLang())//絶対にStartOverと表示
                withAnimation{
                    showMessageOpacity = 0.6
                }
            }else{
                withAnimation{
                    showMessageOpacity = 0.0
                }
            }
        }

    }
    
    func logging(realAnswer: Int) {
        print("///////////////DEBUG SECTION")
        print("roll count limit: \(configStore.rollingCountLimit)")
        print("Randomly picked remain: \(remainderSeq)")
        print("displaySeq: \(rollDisplaySeq as Any)")//ロール中は押せない
        print("displaySeqLength: \(configStore.rollingCountLimit)")
        print("displaySeqSpeedo: \(configStore.rollingSpeed)")
        print("HistorySequence is \(historySeq as Any)")
        print("current draw is \(realAnswer) and No.\(drawCount)")
        print("total is \(drawLimit)")
        print("///////////////END OF DEBUG SECTION")
    }
    
    func randomNumberPicker(mode: Int){//アクションを一つにまとめた mode 1はNext, mode 2はリセット
        isInputMinFocused = false
        isInputMaxFocused = false
        drawLimit = maxBoxValueLock - minBoxValueLock + 1 // ここで異常を起こしている可能性あり?
        
        if mode == 1{ // mode 1はnext
            drawCount += 1 // draw next number
        }
        else if mode == 2{
            drawCount = 1
        }
        remainderSeq = [Int]()
        
        //rollSpeed = 25 // 特に理由はなし speedはこれに係数をかけている
        rollSpeed = interpolateQuadratic(t: 0, minValue: rollMinSpeed * Double(configStore.rollingSpeed + 3), maxValue: rollMaxSpeed * Double(configStore.rollingSpeed)) //速度計算 0?????
        
        rollListCounter = 1
        externalStore.externalRollCount = 1
        
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
            externalStore.externalRollSeq = rollDisplaySeq
            startTimer()//ロール開始, これで履歴にも追加
        }else{//1番最後と、ロールを無効にした場合こっちになります
            configStore.gradientPicker = giveRandomBackground(conf: configStore.configBgColor, current: configStore.gradientPicker)//最後に背景色変える
            externalStore.externalGradient = configStore.gradientPicker
            historySeq?.append(realAnswer)//履歴追加
            rollDisplaySeq = [realAnswer]//答えだけ追加
            externalStore.externalRollSeq = rollDisplaySeq // もっといい実装あるでしょう (もう一つenvironmentObj作るとか)
            giveHaptics(impactType: "medium", ifActivate: configStore.isHapticsOn)
            isButtonPressed = false
        }
    }
    
    //タイマーに使用される関数
    func startTimer() {
        isTimerRunning = true
        externalStore.isExternalRolling = isTimerRunning
        rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / rollSpeed, repeats: true) { timer in
            if rollListCounter + 1 >= configStore.rollingCountLimit {
                rollListCounter += 1
                externalStore.externalRollCount = rollListCounter
                configStore.gradientPicker = giveRandomBackground(conf: configStore.configBgColor, current: configStore.gradientPicker)//アニメーションしたい
                externalStore.externalGradient = configStore.gradientPicker
                    //iOS 17 ではボタンの文字までアニメーションされる
                    //iOS 15,16ではそもそも発生しない
                stopTimer()
                historySeq?.append(realAnswer)//"?"//現時点でのrealAnswer
                giveHaptics(impactType: "medium", ifActivate: configStore.isHapticsOn)
                isButtonPressed = false
                return
            }
            else{
                giveHaptics(impactType: "soft", ifActivate: configStore.isHapticsOn)
                
                let t: Double = Double(rollListCounter) / Double(configStore.rollingCountLimit)//カウントの進捗
                rollSpeed = interpolateQuadratic(t: t, minValue: rollMinSpeed * Double(configStore.rollingSpeed + 3), maxValue: rollMaxSpeed * Double(configStore.rollingSpeed)) //速度計算
                // print("Now rolling aty \(rollSpeed), t is \(t)")
                updateTimerSpeed()
                rollListCounter += 1
                externalStore.externalRollCount = rollListCounter
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false
        externalStore.isExternalRolling = isTimerRunning
        rollTimer?.invalidate()//タイマーを止める。
        rollTimer = nil // 大丈夫か？止まらない説
    }

    func updateTimerSpeed() {
        if isTimerRunning {
            stopTimer()
            startTimer()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ExternalBridge.shared)
}

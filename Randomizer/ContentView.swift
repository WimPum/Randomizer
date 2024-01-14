//本コード

import SwiftUI
import Foundation //Random
import Combine //TextField limitter
import UniformTypeIdentifiers //fileImporter
import class UIKit.UIImpactFeedbackGenerator//UIKitインポートしちゃった

struct ContentView: View {
    //main
    @AppStorage("minValue") private var minBoxValue: Int = 1
    @AppStorage("maxValue") private var maxBoxValue: Int = 50
    @State private var minBoxValueLock: Int = 1
    @State private var maxBoxValueLock: Int = 50//Start Overを押すまでここにkeep
    @State private var drawCount: Int = 0       //今何回目か
    @State private var drawLimit: Int = 0       //何回まで引けるか
    @State private var realAnswer: Int = 0      //本当の答え
    
    //history&Shuffler
    @State private var historySeq: [Int]? = []     //履歴 ない時は0じゃなくてEmpty
    @State private var remainderSeq: [Int] = [0]    //弾いていって残った数字 ロール用
    @State private var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//名前をセーブするなら変更
    @State private var rollListCounter: Int = 1     //ロールのリスト上を移動
    @State private var rollSpeed: Double = 25       //実際のスピードをコントロール 25はrollMaxSpeed
    @State private var rollCountLimit: Int = 25     //数字は25個だけど最後の数字が答え
    @State private var isTimerRunning: Bool = false
    @State private var isButtonPressed: Bool = false//同時押しを無効にするDirtyHack
    @State private var rollTimer: Timer?
    let rollMinSpeed: Double = 1.3//始めは早く段々遅く　の設定
    let rollMaxSpeed: Double = 25

    //fileImporter
    @State var openedFileName = ""//ファイル名表示用
    @AppStorage("fileLocation") var openedFileLocation = URL(string: "file://")!//defalut値確認
    @State var isOpeningFile = false                                            //ファイルダイアログを開く変数
    //@AppStorage("fileSelected") private var isFileSelected: Bool = false//ファイルあるかどうか　活用
    @State private var isFileSelected: Bool = false//isFileLoadedは起動時にファイルを読み込もうとしていた時の遺産
    @State private var csvNameStore = [[String]]()                              //名前を格納する
    @State private var showMessage: String = "press Start Over to apply changes"
    @State private var showMessageOpacity: Double = 0.0 //0.0と0.6の間を行き来します
    
    //1st view(main) variables
    @State private var showCSVButton: Bool = true
    @FocusState private var isInputMinFocused: Bool//キーボードOn/Off
    @FocusState private var isInputMaxFocused: Bool//キーボードOn/Off
    @State private var showingAlert = false     //アラートは全部で2つ
    @State private var showingAlert2 = false    //数値を入力/StartOver押す指示
    let inputMaxLength = 10                      //最大桁数
    let feedbackSoftGenerator = UIImpactFeedbackGenerator(style: .soft)//Haptic Feedback
    let feedbackHardGenerator = UIImpactFeedbackGenerator(style: .medium)//Haptic Feedback
    
    //設定画面用
//    @State var dummyConfig1: Bool = false//ダミー
//    @State var dummyConfig2: Bool = false//ダミー
//    @State var dummyConfig3: Bool = false//ダミー
    @ObservedObject var configStore = SettingsBridge()//設定をここに置いていく

    //misc
    @State var viewSelection = 3    //ページを切り替える用
    @State var gradientColor = 1    //背景の色設定用　・・まだ機能なし
    @State var isSettingsView: Bool = false//設定画面を開くよう

    var body: some View {
        ZStack { //グラデとコンテンツを重ねるからZStack
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            TabView(selection: $viewSelection){
                VStack(){//１ページ目
                    Spacer().frame(height: 5)
                    if showCSVButton == true{
                        HStack{
                            Button(action: {self.isOpeningFile.toggle()}){
                                Text("open csv")
                                    .fontSemiBold(size: 24)
                                    .padding(13)
                            }.disabled(isButtonPressed)
                            Spacer()//左端に表示する
                            Button(action: {self.isSettingsView.toggle()}){
                                //Text("Settings") //アイコンの方がいいかな？
                                Image(systemName: "gearshape.fill")
                                    //.foregroundColor(.white)
                                    .fontSemiBold(size: 24)
                                    .padding(.trailing, 12.0)
                            }//.disabled(isButtonPressed)
                        }//.border(.black)
                    }
                    Spacer() //
                    //Spacer().frame(height: 5)
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
                                //.border(.red)
                        }.disabled(isButtonPressed)
                            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in//振ったら
                                if isButtonPressed == false{
                                    isButtonPressed = true
                                    print("device shaken!")
                                    buttonNext()
                                }
                            }
                        Text(isFileSelected ? csvNameStore[0][rollDisplaySeq![rollListCounter-1]-1]: showMessage)//ファイルあれば
                            .fontSemiBold(size: 26)
                            .multilineTextAlignment(.center)
                            .opacity(showMessageOpacity)
                            //.padding()
                            .frame(height: 60)
                            .minimumScaleFactor(0.2)
                    }//.frame(height: 200)
                    //.border(.yellow)
                    Spacer() //バカみたい
                    VStack(){                                                               //下半分
                        if isFileSelected == false {
                            Spacer(minLength: 10)
                            HStack{
                                Spacer(minLength: 60)
                                VStack{//ここstructとかで省略できないか？
                                    Text("Min")
                                        .fontMedium(size: 24)
                                    TextField("Min", value: $minBoxValue, formatter: NumberFormatter())
                                        .onTapGesture {
                                            print("TextField Min tapped")
                                            isInputMinFocused = true
                                            withAnimation {
                                                showCSVButton = false
                                            }
                                        }
                                        .textFieldStyle(.roundedBorder)
                                        .focused($isInputMinFocused)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(minBoxValue)) { _ in//文字数制限.
                                            if String(minBoxValue).count > inputMaxLength {
                                                minBoxValue = Int(String(minBoxValue).prefix(inputMaxLength))!
                                            }
                                        }.disabled(isButtonPressed)
                                }
                                Spacer(minLength: 70)
                                VStack{
                                    Text("Max")
                                        .fontMedium(size: 24)
                                    TextField("Max", value: $maxBoxValue, formatter: NumberFormatter())
                                        .onTapGesture {
                                            print("TextField Max tapped")
                                            isInputMaxFocused = true
                                            withAnimation {
                                                showCSVButton = false
                                            }
                                        }
                                        .textFieldStyle(.roundedBorder)
                                        .focused($isInputMaxFocused)
                                        .keyboardType(.numberPad) // 追加
                                        .onReceive(Just(maxBoxValue)) { _ in
                                            if String(maxBoxValue).count > inputMaxLength {
                                                maxBoxValue = Int(String(maxBoxValue).prefix(inputMaxLength))!
                                            }
                                        }.disabled(isButtonPressed)
                                }
                                Spacer(minLength: 60)
                            }
                        }
                        else{
                            HStack(){//
                                Text(self.openedFileName)// select csv file
                                    .fontMedium(size: 20)
                                //.padding()
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
                                .fontSemiBold(size: 22)
                                .padding()
                                .frame(width:135, height: 55)
                                .glassMaterial(cornerRadius: 12)
                        }.disabled(isButtonPressed)
                        .alert("All drawn", isPresented: $showingAlert) {
                            // アクションボタンリスト
                        } message: {
                            Text("Press Start Over to Reset")
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
                                .fontSemiBold(size: 22)
                                .padding()
                                .frame(width:135, height: 55)
                                .glassMaterial(cornerRadius: 12)
                        }.disabled(isButtonPressed)
                        .alert("Error", isPresented: $showingAlert2) {
                            // アクションボタンリスト
                        } message: {
                            Text("put bigger number on right box")
                        }
                        Spacer()
                    }
                    Spacer(minLength: 20)
                } //Main Interface Here
                .tabItem {
                  Text("Main") }
                .tag(1)
                
                
                VStack(){
                    Spacer(minLength: 5)
                    //Spacer().frame(height: 20)//this is genius!!
                    Text("History")//リストを表示！
                        .fontSemiBold(size: 20)
                        .padding()//should be here
                    if let screenWidth = UIScreen.current?.bounds.width, let historySeq = historySeq{
                        //if let historySeq = historySeq {//値入ってたら
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
                            //Spacer()
                            Color.clear
                                .frame(width: UIScreen.current?.bounds.width,
                                       //height: (UIScreen.current?.bounds.height)!-120,//CRASHED
                                       alignment: .center)
                        }
                    }
                    Spacer(minLength: 20)/*.frame(height: 10)*/
                }
                .tabItem {
                  Text("History") }
                .tag(2)
            
//                
//                .tabItem {
//                  Text("Setting") }
//                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            //.padding()
            .ignoresSafeArea(edges: .top)
        }
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
                            showMessage = "Error loading files. \nConsider loading from local storage."//この時だけこれ
                            withAnimation{
                                showMessageOpacity = 0.6
                            }
                            //isFileSelected = false
                            
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
        .sheet(isPresented: self.$isSettingsView){
            SettingsView(isPresentedLocal: self.$isSettingsView, configStore: self.configStore)
        }//設定画面
        .onAppear{//起動時に実行となる　このContentViewしかないから
            initReset()
        }
    }
    
    
    func fileReset() {
        print("cleared files")
        openedFileName = ""//リセット
        withAnimation{
            showMessageOpacity = 0.0
        }
        showMessage = "press Start Over to apply changes"//変更するけど見えない
        isFileSelected = false
        csvNameStore = [[String]]()//空　isFileSelected の後じゃないと落ちる
        //仕様の構想
        //ファイルが見つからなければ無視する
    }
    
    func initReset() {//起動時に実行 No.0/表示: 0
        maxBoxValueLock = maxBoxValue//保存
        minBoxValueLock = minBoxValue
        drawLimit = maxBoxValue - minBoxValue + 1
        print("HistorySequence \(historySeq as Any)")
        print("total would be No.\(drawLimit)")
//        for i in 1...99990{
//            historySeq!.append(i)
//            print(i)
//        }//履歴に数字をたくさん追加してパフォーマンス計測
        
//        if isFileSelected == true{//AppStorage保存もしないので無効
//            print(openedFileLocation)
//            if openedFileLocation.startAccessingSecurityScopedResource() {//ロード不可
//                print("loading files")
//                csvNameStore = loadCSV(fileURL: openedFileLocation)!
//                print(csvNameStore)
//            }
//        }
    }
    
    func buttonReset() {
        if minBoxValue >= maxBoxValue{
            self.showingAlert2.toggle()
            isButtonPressed = false
        }
        else{
            if isFileSelected == true{ //ファイルが選ばれたら自動入力
                maxBoxValue = csvNameStore[0].count
                minBoxValue = 1
                showMessageOpacity = 0.6
            }else{
                withAnimation{//まず非表示？
                    showMessageOpacity = 0.0
                }
                showMessage = "press Start Over to apply changes"//違ったら戻す
            }
            //Reset固有
            historySeq = []//リセットだから
            rollCountLimit = 25//上でリセット
            drawCount = 1//やり直しだから
            maxBoxValueLock = maxBoxValue//保存
            minBoxValueLock = minBoxValue
            print("mmBoxVal: \(maxBoxValue), \(minBoxValue)")
            drawLimit = maxBoxValue - minBoxValue + 1
            
            randomNumberPicker()//まとめた
            
            //Nextと共通
        }
    }
    
    func buttonNext() {
        if drawCount >= drawLimit{
            self.showingAlert.toggle()
            isButtonPressed = false
        }
        else{
            if isFileSelected == false{ //ファイルが選ばれてなかったら
                if maxBoxValue == maxBoxValueLock && minBoxValue == minBoxValueLock{
                    withAnimation{//まず非表示？
                        showMessageOpacity = 0.0
                    }
                }
                showMessage = "press Start Over to apply changes"//違ったら戻す
            }
            drawCount += 1 // draw next number
            
            randomNumberPicker()//まとめました
        }
    }
    
    func buttonKeyDone(){
        isInputMaxFocused = false
        isInputMinFocused = false
        showCSVButton = true
        if maxBoxValue != maxBoxValueLock || minBoxValue != minBoxValueLock{
            showMessage = "press Start Over to apply changes"//絶対にStartOverと表示
            withAnimation{
                showMessageOpacity = 0.6
            }
        }else{
            withAnimation{
                showMessageOpacity = 0.0
            }
        }
    }
    
    func logging(realAnswer: Int) {
        print("roll count limit: \(rollCountLimit)")
        print("Randomly picked remain: \(remainderSeq)")
        print("displaySeq: \(rollDisplaySeq as Any)")//ロール中は押せない
        print("HistorySequence is \(historySeq as Any)")
        print("current draw is \(realAnswer) and No.\(drawCount)")
        print("total is \(drawLimit)")
    }
    
    func randomNumberPicker(){//アクションを一つにまとめるだけで、他では使わない
        isInputMaxFocused = false
        isInputMinFocused = false
        showCSVButton = true
        remainderSeq = [Int]()
        rollSpeed = 25
        rollListCounter = 1
        
        let remaining = drawLimit - drawCount + 1
        print("\(remaining) numbers remaining")
        let switchRemainPick = remaining > rollCountLimit
        var historySeqforRoll = [Int]()     //履歴
        var pickedNumber: Int//上のhistorySeqforRollとともに下のforループでのみ使用
        
        for _ in (1...Int(switchRemainPick ? rollCountLimit : remaining)){
            if switchRemainPick{
                remainderSeq.append(give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq))//ここ変えます
            }else{
                repeat{
                    pickedNumber = give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq)
                }while(historySeqforRoll.contains(pickedNumber))
                historySeqforRoll.append(pickedNumber)
                remainderSeq.append(pickedNumber)
            }
        }
        realAnswer = give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq)
        rollDisplaySeq = giveRandomSeq(contents: remainderSeq, length: rollCountLimit, realAnswer: realAnswer)
        //remaining <= 1 ? rollCountLimit = 1 : () //ロールアニメーションはこれで無効にできる?
        logging(realAnswer: realAnswer)
        print(remaining)
        if remaining > 1 {
            startTimer()//ロール開始, これで履歴にも追加
        }else{//1番最後
            isButtonPressed = false
        }
    }
    
    //タイマーに使用される関数
    func startTimer() {
        //if isAlreadyTimerRunning == true{ return }
        isTimerRunning = true
        rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / rollSpeed, repeats: true) { timer in
            //print("rollCounter was \(rollListCounter)")
            feedbackSoftGenerator.impactOccurred()//触覚
            rollListCounter += 1
            
            //print("rollCounter is \(rollListCounter)")
            if rollListCounter >= rollCountLimit {
                feedbackHardGenerator.impactOccurred()//触覚
                stopTimer()
                //withAnimation(){//iOS 15, 16でアニメーション起きない
                    historySeq?.append(realAnswer)//"?"//現時点でのrealAnswer
                //}
                isButtonPressed = false
            }
            let t: Double = Double(rollListCounter) / Double(rollCountLimit)//カウントの進捗
            rollSpeed = interpolateQuadratic(t: t, minValue: rollMinSpeed, maxValue: rollMaxSpeed)
            updateTimerSpeed()
        }
    }

    func stopTimer() {
        isTimerRunning = false
        rollTimer?.invalidate()//タイマーを止める。
        rollTimer = nil
    }

    func updateTimerSpeed() {
        if isTimerRunning {
            stopTimer()
            startTimer()
        }
    }

    func interpolateQuadratic(t: Double, minValue: Double, maxValue: Double) -> Double {
        let clampedT = max(0, min(1, t))//0から1の範囲で制限
        return (1 - clampedT) * maxValue + clampedT * minValue
    }
}

final class SettingsBridge: ObservableObject{
//    @Published var dummyConf1: Bool = false//ダミー
//    @Published var dummyConf2: Bool = false//ダミー
//    @Published var dummyConf3: Bool = false//ダミー
    
    @AppStorage("dummyConf1") var dummyConf1: Bool = false//ダミー
    @AppStorage("dummyConf2") var dummyConf2: Bool = false//ダミー
    @AppStorage("dummyConf3") var dummyConf3: Bool = false//ダミー
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

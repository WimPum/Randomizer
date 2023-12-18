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
    @State private var minBoxValueLock: Int = 0
    @State private var maxBoxValueLock: Int = 0 //Start Overを押すまでここにkeep
    @State private var drawCount: Int = 0       //今何回目か
    @State private var drawLimit: Int = 0       //何回まで引けるか
    
    //history&Shuffler
    @State private var historySeq: [Int]? = nil //履歴
    @State private var remainderSeq: [Int] = [0]    //弾いていって残った数字 ロール用
    @State private var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//名前をセーブするなら変更
    //@State private var isButtonEnabled: Bool = true
    @State private var rollListCounter: Int = 1     //リスト上を移動
    @State private var isTimerRunning: Bool = false
    @State private var isButtonPressed: Bool = false//同時押しを無効にするDirtyHack
    @State private var rollTimer: Timer?
    @State private var rollSpeed: Double = 25       //実際のスピードをコントロール
    @State private var rollCountLimit: Int = 25     //数字は25個だけど最後の数字が答え
    let rollMinSpeed: Double = 2.5
    let rollMaxSpeed: Double = 25

    //fileImporter
    @State var openedFileName = ""
    @AppStorage("fileLocation") var openedFileLocation = URL(string: "file://")!//defalut値確認
    @State var isOpeningFile = false                                            //ファイルダイアログを開く変数
    //@AppStorage("fileSelected") private var isFileSelected: Bool = false//ファイルあるかどうか　活用
    @State private var isFileSelected: Bool = false
    @State private var isFileLoaded: Bool = false//ファイルが読めたらToggle!
    @State private var csvNameStore = [[String]]()                              //名前を格納する
    @State private var showMessage: String = "press Start Over to apply changes"
    @State private var showMessageOpacity: Double = 0.0 //0.0と0.6の間を行き来します
    
    //misc
    @FocusState private var isInputMinFocused: Bool//キーボードOn/Off
    @FocusState private var isInputMaxFocused: Bool//キーボードOn/Off
    @State private var showCSVButton: Bool = true
    @State private var showingAlert = false     //アラートは全部で2つ
    @State private var showingAlert2 = false    //数値を入力/StartOver押す指示
    @State var selection = 1                    //ページを切り替える用
    @State private var dummyConfig1: Bool = false//ダミー
    @State private var dummyConfig2: Bool = false//ダミー
    @State private var dummyConfig3: Bool = false//ダミー
    let inputMaxLength = 10                     //最大桁数
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)//Taptic Feedback

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)//グラデとコンテンツを重ねるからZStack
            TabView(selection: $selection){
                VStack(){//１ページ目
                    Spacer().frame(height: 5)
                    if showCSVButton == true{
                        //withAnimation{
                            HStack{
                                Button(action: {self.isOpeningFile.toggle()}){
                                    Text("open csv")
                                        .fontSemiBold(size: 24)
                                    //.opacity()
                                        .padding(13)
                                }.disabled(isButtonPressed)
                                Spacer()//左端に表示する
                            }//.border(.black)
                        //}
                    }
                    //Spacer().frame(height: 5)
                    VStack(){//OutOfRangeにならないようにする
                        Text("No.\(drawCount)")
                            .fontMedium(size: 32)
                            .frame(height: 40)
                        Button(action: {
                            if isButtonPressed == false{
                                isButtonPressed = true
                                buttonNext()
                            }
                        }){
                            Text(verbatim: "\(rollDisplaySeq![rollListCounter-1])")
                                .fontSemiBoldRound(size: 160, rolling: isTimerRunning)
                                .frame(width: UIScreen.current?.bounds.width, height: 170)
                                .minimumScaleFactor(0.2)
                                .border(.red)
                        }.disabled(isButtonPressed)
                            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                                if isButtonPressed == false{
                                    isButtonPressed = true
                                    buttonNext()
                                }
                            }
                        Text(isFileLoaded ? csvNameStore[0][rollDisplaySeq![rollListCounter-1]-1]: showMessage)//ファイルあれば
                            .fontSemiBold(size: 26)
                            .multilineTextAlignment(.center)
                            .opacity(showMessageOpacity)
                            //.padding()
                            .frame(height: 60)
                            .minimumScaleFactor(0.2)
                    }//.frame(height: 200)
                    .border(.yellow)
                    Spacer() //バカみたい
                    VStack(){
                        if isFileSelected == false {
                            Spacer(minLength: 10)
                            HStack{
                                Spacer(minLength: 60)
                                VStack{//ここ同じにしてもいいかな？
                                    Text("Min")
                                        .fontMedium(size: 24)
                                    TextField("Min", value: $minBoxValue, formatter: NumberFormatter())
                                        .onTapGesture {
                                            // Code to execute when TextField gains focus
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
                                            // Code to execute when TextField gains focus
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
                            HStack(){//ここは一時的なものですぐにでも変更したい箇所です。l
                                Text(self.openedFileName)// select csv file
                                    .fontMedium(size: 20)
                                //.padding()
                            }
                            Button(action: {
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
                            Button("Done") {
                                buttonDone()
                            }
                        }
                    }
                    .frame(height: 90)
                        .border(.green)
                    Spacer()
                    HStack(){ // lower buttons.
                        Spacer()
                        Button(action: {
                            if isButtonPressed == false{
                                isButtonPressed = true
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
                    if let historySeq = historySeq{//値入ってたら
                        List {
                            ForEach(0..<historySeq.count, id: \.self){ index in
                                HStack(){
                                    Text("No.\(index+1)")
                                        .fontLight(size: 25)
                                    Spacer()
                                    Text("\(historySeq[index])")
                                        .fontSemiBold(size: 40)
                                        .frame(width: (UIScreen.current?.bounds.width)!-140,
                                               height: 40,
                                               alignment: .trailing)
                                        .border(.red)
                                        .minimumScaleFactor(0.2)
                                }.listRowBackground(Color.clear)//リストの項目の背景を無効化
                            }
                        }
                        .scrollCBIfPossible()//リストの背景を無効化
                        //.background(Color.clear)
                        .listStyle(.plain)
                        .frame(width: UIScreen.current?.bounds.width,
                               //height: (UIScreen.current?.bounds.height)!-120,//CRASHED
                               alignment: .center)
                        //.border(.red, width: 3)
                    }else{
                        Spacer()
                            .frame(width: UIScreen.current?.bounds.width,
                                   //height: (UIScreen.current?.bounds.height)!-120,//CRASHED
                                   alignment: .center)
                    }
                    Spacer(minLength: 20)/*.frame(height: 10)*/
                }//クラッシュの元がここに
                .tabItem {
                  Text("History") }
                .tag(2)
                
                VStack(){
                    HStack{
                        Text("Settings")//リストを表示！
                            .fontSemiBold(size: 40)
                            .padding()
                        Spacer()
                    }
                    List{
                        VStack(){
                            Toggle(isOn: $dummyConfig1){//ff
                                Text("Enable Dots1")
                            }
                            Toggle(isOn: $dummyConfig2){//ff
                                Text("Enable Dots2")
                            }
                        }//.listRowBackground(Color.clear)//どうしたら？？
                    }.scrollCBIfPossible()//リストの背景を無効化
                    Spacer()
                    Text("Randomizer v0.1")//VersionStringを
                }
                .tabItem {
                  Text("Setting") }
                .tag(3)
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
                    self.openedFileName = openedFileLocation.lastPathComponent//名前だけ
                    print(openedFileLocation)
                    if openedFileLocation.startAccessingSecurityScopedResource() {
                        print("loading files")
                        csvNameStore = loadCSV(fileURL: openedFileLocation)!
                        print(csvNameStore)
                        //audioFiles.append(AudioObject(id: UUID().uuidString, url: audioURL))
                        isFileSelected = true
                        isFileLoaded = true
                        buttonReset()
                    }
                }
                catch{
                    print("error reading file \(error.localizedDescription)")
                }
            }
            else{
                print("File Import Failed")
            }
        }
        .onAppear{//リセットとほぼ同じことをするはず 関数
            initReset()
        }
    }
    
    
    func fileReset(){
        print("button 00 pressed")
        isFileLoaded = false
        print("cleared files")
        openedFileName = ""//リセット
        csvNameStore = [[String]]()
        //fileURLは初期化されないが使われないようになる。
        isFileSelected = false
        //仕様の構想
        //ファイルが見つからなければ無視する
    }
    
    func initReset(){//起動時に実行
        maxBoxValueLock = maxBoxValue//保存
        minBoxValueLock = minBoxValue
        drawLimit = maxBoxValue - minBoxValue + 1
        //bigDispNumber = give1RndNumber(min: minBoxValue, max: maxBoxValue, historyList: &historySeq)
        print("HistorySequence \(historySeq as Any)")
        //print("current draw is \(bigDispNumber) and No.\(drawCount)")
        print("total would be No.\(drawLimit)")
        if isFileSelected == true{
            print(openedFileLocation)
            if openedFileLocation.startAccessingSecurityScopedResource() {//読めない
                print("loading files")
                csvNameStore = loadCSV(fileURL: openedFileLocation)!
                print(csvNameStore)
                isFileLoaded = true
                //audioFiles.append(AudioObject(id: UUID().uuidString, url: audioURL))
            }
        }
    }
    
    func buttonReset(){
        print("button 2 (RESEt) pressed")
        if minBoxValue >= maxBoxValue{
            self.showingAlert2.toggle()
            print("isItReset \(isButtonPressed)")
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
            }
            isInputMaxFocused = false
            isInputMinFocused = false
            showCSVButton = true
            //isButtonPressed = false
            rollCountLimit = 25//上でリセット
            rollListCounter = 1//リセット
            rollSpeed = 25//リセット
            drawCount = 1//やり直しだから
            maxBoxValueLock = maxBoxValue//保存
            minBoxValueLock = minBoxValue
            print("mmBoxVal: \(maxBoxValue), \(minBoxValue)")
            drawLimit = maxBoxValue - minBoxValue + 1
            let remaining = drawLimit - drawCount + 1
            historySeq = nil//リセットだから
            remainderSeq = [Int]()//リセット
            let switchRemainPick = remaining > rollCountLimit
            var historySeqforRoll = [Int]()     //履歴
            var pickedNumber: Int//上のhistorySeqforRollとともに下のforループでのみ使用

            for _ in (1...Int(switchRemainPick ? rollCountLimit : remaining)){//ここもどうやって全部取り出すん？
                if switchRemainPick{
                    remainderSeq.append(give1RndNumberNoSave(min: minBoxValue, max: maxBoxValue, historyList: historySeq))//ここ変えます
                }else{
                    repeat{
                        pickedNumber = give1RndNumberNoSave(min: minBoxValue, max: maxBoxValue, historyList: historySeq)
                    }while(historySeqforRoll.contains(pickedNumber))
                    historySeqforRoll.append(pickedNumber)
                    remainderSeq.append(pickedNumber)
                }
            }
            let realAnswer = give1RndNumber(min: minBoxValue, max: maxBoxValue, historyList: &historySeq)
            //remainderSeq = //realAnswerを含むすべての数からランダムに選ぶ必要がある。
            rollDisplaySeq = giveRandomSeq(contents: remainderSeq, length: rollCountLimit, realAnswer: realAnswer)//どうしよう
            print("roll count limit: \(rollCountLimit)")
            print("HistorySequence is \(historySeq as Any)")
            print("current draw is \(realAnswer) and No.\(drawCount)")
            print("total is \(drawLimit)")
            print("displaySeq:\(rollDisplaySeq as Any)")
            print("Randomly picked remain:\(remainderSeq)")
            //randomSeqStore = randomSeq //
            if remaining > 1 {
                startTimer()//ロール開始
            }
            //isButtonPressed = false
        }
    }
    
    func buttonNext(){
        print("button 1 (NEXt) pressed")
        //historySeq = nil
        if drawCount >= drawLimit{
            self.showingAlert.toggle()
            print("isItNext \(isButtonPressed)")
            isButtonPressed = false
        }
        else{
            //isButtonPressed = false
            withAnimation{//非表示
                showMessageOpacity = 0.0
            }
            isInputMaxFocused = false
            isInputMinFocused = false
            showCSVButton = true
            remainderSeq = [Int]()
            rollSpeed = 25
            rollListCounter = 1
            drawCount += 1 // draw next number
            let remaining = drawLimit - drawCount + 1
            print("\(remaining) numbers remaining")
            let switchRemainPick = remaining > rollCountLimit
            var historySeqforRoll = [Int]()     //履歴
            var pickedNumber: Int//上のhistorySeqforRollとともに下のforループでのみ使用
            for _ in (1...Int(switchRemainPick ? rollCountLimit : remaining)){//ここもどうやって全部取り出すん？
                if switchRemainPick{
                    remainderSeq.append(give1RndNumberNoSave(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq))//ここ変えます
                }else{
                    repeat{
                        pickedNumber = give1RndNumberNoSave(min: minBoxValueLock, max: maxBoxValueLock, historyList: historySeq)
                    }while(historySeqforRoll.contains(pickedNumber))
                    historySeqforRoll.append(pickedNumber)
                    remainderSeq.append(pickedNumber)
                }
            }
            let realAnswer = give1RndNumber(min: minBoxValueLock, max: maxBoxValueLock, historyList: &historySeq)
            rollDisplaySeq = giveRandomSeq(contents: remainderSeq, length: rollCountLimit, realAnswer: realAnswer)//どうしよう
            //remaining <= 1 ? rollCountLimit = 1 : () //ロールアニメーションはこれで無効にできる?
            print("Randomly picked remain:\(remainderSeq)")
            print("displaySeq:\(rollDisplaySeq as Any)")//ロール中は押せない
            print("HistorySequence is \(historySeq as Any)")
            print("current draw is \(realAnswer) and No.\(drawCount)")
            print("total is \(drawLimit)")
            print("displaySeq:\(rollDisplaySeq as Any)")
            print("Randomly picked remain:\(remainderSeq)")
            if remaining > 1 {
                startTimer()//ロール開始
            }
            //isButtonPressed = false
        }
    }
    
    func buttonDone(){
        isInputMaxFocused = false
        isInputMinFocused = false
        showCSVButton = true
        if maxBoxValue != maxBoxValueLock || minBoxValue != minBoxValueLock{
            withAnimation{
                showMessageOpacity = 0.6
            }
        }else{
            withAnimation{
                showMessageOpacity = 0.0
            }
        }
    }
    
    func startTimer() {
        //if isAlreadyTimerRunning == true{ return }
        isTimerRunning = true
        rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / rollSpeed, repeats: true) { timer in
            //print("rollCounter was \(rollListCounter)")
            rollListCounter += 1
            feedbackGenerator.impactOccurred()//触覚
            //print("rollCounter is \(rollListCounter)")
            if rollListCounter >= rollCountLimit {
                stopTimer()
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

extension View {
    func scrollCBIfPossible() -> some View {
        if #available(iOS 16.0, *) {//iOS16以降なら
            return self.scrollContentBackground(.hidden)
            //return self
        } else {
            UITableView.appearance().backgroundColor = UIColor(.clear)
            return self
        }
    }
    func fontLight(size: Int) -> some View {
        self
            .font(.system(size: CGFloat(size), weight: .light, design: .default))
            .foregroundStyle(.white)
    }
    func fontMedium(size: Int) -> some View {
        self
            .font(.system(size: CGFloat(size), weight: .medium, design: .default))
            .foregroundColor(.white)
    }
    func fontSemiBold(size: Int) -> some View {
        self
            .font(.system(size: CGFloat(size), weight: .semibold, design: .default))
            .foregroundColor(.white)
    }
    func fontSemiBoldRound(size: Int, rolling: Bool) -> some View {
        if rolling == true{
            return self
                .font(.system(size: CGFloat(size), weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .opacity(0.4)
        }else{
            return self
                .font(.system(size: CGFloat(size), weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .opacity(1)
            }
    }
    func glassMaterial(cornerRadius: Int) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                .foregroundStyle(.ultraThinMaterial)
                .shadow(color: .init(white: 0.4, opacity: 0.6), radius: 5, x: 0, y: 0)
        )
    }
}

extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
    }
}

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name("DeviceDidShakeNotification")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

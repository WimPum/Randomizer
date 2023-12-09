//本コード

import SwiftUI
import Foundation //Random
import Combine //TextField limitter
import UniformTypeIdentifiers //fileImporter

struct ContentView: View {
    //main
    @AppStorage("minValue") private var minBoxValue: Int = 1
    @AppStorage("maxValue") private var maxBoxValue: Int = 50
    @State private var minBoxValueLock: Int = 0
    @State private var maxBoxValueLock: Int = 0 //Start Overを押すまでここにkeep
    @State private var bigDispNumber: Int = 0   //表示する番号
    @State private var drawCount: Int = 0       //今何回目か
    @State private var drawLimit: Int = 0       //何回まで引けるか
    
    //history&Shuffler
    @State private var historySeq: [Int]? = nil     //履歴
    @State private var remainderSeq: [Int] = [0]    //弾いていって残った数字 ロール用
    @State private var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//名前をセーブするなら変更
    @State private var isButtonEnabled: Bool = true
    @State private var rollListCounter: Int = 1     //リスト上を移動
    @State private var isTimerRunning: Bool = false
    @State private var rollTimer: Timer?
    @State private var rollSpeed: Double = 25       //実際のスピードをコントロール
    @State private var rollCountLimit: Int = 25     //数字は25個だけど最後の数字が答え
    let rollMinSpeed: Double = 2.5
    let rollMaxSpeed: Double = 25

    //fileImporter
    @State var openedFileName = "select .csv file"
    @AppStorage("fileLocation") var openedFileLocation = URL(string: "file://")!//defalut値確認
    @State var isOpeningFile = false                                            //ファイルダイアログを開く変数
    //@AppStorage("fileSelected") private var isFileSelected: Bool = false//ファイルあるかどうか　活用
    @State private var isFileSelected: Bool = false
    @State private var isFileLoaded: Bool = false//ファイルが読めたらToggle!
    @State private var csvNameStore = [[String]]()                              //名前を格納する
    
    //misc
    @FocusState private var isInputFocused: Bool//キーボードOn/Off
    @State private var showingAlert = false     //アラートは全部で2つ
    @State private var showingAlert2 = false    //数値を入力/StartOver押す指示
    let inputMaxLength = 10                     //最大桁数
    @State var selection = 1//ページを切り替える用

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)//グラデとコンテンツを重ねるからZStack
            TabView(selection: $selection){
                VStack(){//１ページ目
                    Spacer().frame(height: 20)
                    HStack{
                        Button(action: {self.isOpeningFile.toggle()}){
                            Text("open csv")
                                .fontSemiBold(size: 22)
                                .padding()
                        }.disabled(!isButtonEnabled)
                        Spacer()//左端に表示する
                    }
                    Spacer(minLength: 10)
                    Text("No.\(drawCount)")
                        .fontMedium(size: 32)
                        .multilineTextAlignment(.center)
                    Text(verbatim: "\(rollDisplaySeq![rollListCounter-1])")//カンマなし
                        .fontSemiBoldRound(size: 155)
                        .frame(width: UIScreen.current?.bounds.width, height: 175)
                        .minimumScaleFactor(0.2)
                    Text(isFileLoaded ? csvNameStore[0][rollDisplaySeq![rollListCounter-1]-1]: " ")//ファイルあれば
                        .fontSemiBold(size: 26)
                        .multilineTextAlignment(.center)
                        .opacity(0.6)
                    
                    Spacer(minLength: 50)
                    //Spacer() //バカみたい
                    HStack(){//ここは一時的なものですぐにでも変更したい箇所です。l
                        Text(self.openedFileName)
                            .fontMedium(size: 20)
                        Button(action: {
                            fileReset()
                        }){
                            Text("clear names")
                                .fontSemiBold(size: 18)
                                .padding()
                                .frame(width:140, height: 36)
                                .glassMaterial(cornerRadius: 24)
                        }.disabled(!isButtonEnabled)
                    }
                    Spacer(minLength: 1)
                    HStack{
                        Spacer(minLength: 60)
                        VStack{//ここ同じにしてもいいかな？
                            Text("Min")
                                .fontMedium(size: 24)
                            TextField("Min", value: $minBoxValue, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .focused($isInputFocused)
                                .keyboardType(.numberPad)
                                .onReceive(Just(minBoxValue)) { _ in//文字数制限.
                                    if String(minBoxValue).count > inputMaxLength {
                                        minBoxValue = Int(String(minBoxValue).prefix(inputMaxLength))!
                                    }
                                }.disabled(!isButtonEnabled)
                        }
                        Spacer(minLength: 70)
                        VStack{
                            Text("Max")
                                .fontMedium(size: 24)
                            TextField("Max", value: $maxBoxValue, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .focused($isInputFocused)
                                .keyboardType(.numberPad) // 追加
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {// Doneボタンを片方に追加
                                            isInputFocused = false
                                        }
                                    }
                                }
                                .onReceive(Just(maxBoxValue)) { _ in
                                    if String(maxBoxValue).count > inputMaxLength {
                                        maxBoxValue = Int(String(maxBoxValue).prefix(inputMaxLength))!
                                    }
                                }.disabled(!isButtonEnabled)
                        }
                        Spacer(minLength: 60)
                    }
                    Spacer(minLength: 48)
                    HStack(spacing: 40){ // lower buttons.
                        Spacer()
                        Button(action: {
                            buttonNext()
                        }){
                            Text("Next draw")
                                .fontSemiBold(size: 22)
                                .padding()
                                .frame(width:135, height: 60)
                                .glassMaterial(cornerRadius: 12)
                        }.disabled(!isButtonEnabled)
                        .alert("All drawn", isPresented: $showingAlert) {
                            // アクションボタンリスト
                        } message: {
                            Text("Press Start Over to Reset")
                        }
                        Button(action: {
                            buttonReset()
                        }) {
                            Text("Start over")
                                .fontSemiBold(size: 22)
                                .padding()
                                .frame(width:135, height: 60)
                                .glassMaterial(cornerRadius: 12)
                        }.disabled(!isButtonEnabled)
                        .alert("Error", isPresented: $showingAlert2) {
                            // アクションボタンリスト
                        } message: {
                            Text("put bigger number on right box")
                        }
                        Spacer()
                    }
                    Spacer(minLength: 65)
                } //Main Interface Here
                .tabItem {
                  Text("Main") }
                .tag(1)
                VStack(){
                    //Spacer()
                    Spacer().frame(height: 20)//this is genius!!
                    Text("History")//リストを表示！
                        .fontSemiBold(size: 20)
                        /*.onAppear{//スワイプしたらキーボード隠す
                            amountIsFocused = false
                        }*/
                    if let historySeq = historySeq{//値入ってたら
                        List {
                            //ForEach(0..<historySeq.count){ index in
                            ForEach(0..<historySeq.count, id: \.self){ index in
                                HStack(){
                                    Text("No.\(index+1)")//
                                        .fontLight(size: 30)
                                    Spacer()
                                    Text("\(historySeq[index])")
                                        .fontSemiBold(size: 40)
                                }.listRowBackground(Color.clear)//リストの項目の背景を無効化
                            }
                        }
                        .scrollCBIfPossible()//リストの背景を無効化
                        //.background(Color.clear)
                        .listStyle(.plain)
                        .frame(width: UIScreen.current?.bounds.width,
                               height: (UIScreen.current?.bounds.height)!-200,
                               alignment: .center)
                        //.border(.red, width: 3)
                    }
                    Spacer()
                }
                .tabItem {
                  Text("History") }
                .tag(2)
                
                Text("Setting Page")//リストを表示！
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
    
    func give1RndNumber(min: Int, max: Int, historyList: inout [Int]?) -> Int {//１個だけ生成
        var randomNum: Int = Int.random(in: min...max)
        print("今の届いたリスト: \(String(describing: historyList))")
        print("min: \(min), max: \(max)")
        if var unwrappedList = historyList{
            while unwrappedList.contains(randomNum) {//historyにある数字がでたらループ
                print("Already picked: \(randomNum)")
                randomNum = Int.random(in: min...max)
            }
            // Append the random number to the list
            unwrappedList.append(randomNum)
            
            // Update the original list with the modified one
            historyList = unwrappedList
        } else {
            // If the list is nil, create a new list with the random number
            historyList = [randomNum]
        }
        return randomNum
    }
    
    func give1RndNumberNoSave(min: Int, max: Int, historyList: [Int]?) -> Int {//履歴保持なし
        guard let historyList = historyList, !historyList.isEmpty else{ //guard文を覚える
            print("direct output")
            return Int.random(in: min...max)
        }
        //var randomNum: Int = Int.random(in: min...max) //ロール用に使うときにはまずhistoryを作る?
        print("今の届いたリストforRoll: \(String(describing: historyList))")
        print("min: \(min), max: \(max)")
        var randomNum: Int
        var attempts = 0
        repeat{
            randomNum = Int.random(in: min...max)
            attempts += 1
            /*if attempts > (max - min + 1){
                // Break the loop if all numbers are in remainedList
                // This prevents potential infinite loop
                assertionFailure("All numbers are in remainedList")
                return -1 // Or handle this case differently based on your requirements
            }*/
        }while historyList.contains(randomNum)//guardのおかげでforceUnwrapもいらない
        print("picked \(randomNum)")
        return randomNum
    }
    
    func giveRandomSeq(contents: [Int]!, length: Int, realAnswer: Int) -> [Int]{//ロールの数列生成
        var assignedValue: Int = 0
        var returnArray: [Int]? = [Int]()
        let listLength: Int = contents.count//リストの長さ
        if listLength > 1{
            for i in 1...length-1{
                assignedValue = contents.randomElement()!//ランダムに1つ抽出
                if i > 1{//1回目以降は
                    while assignedValue == returnArray![i-2]{//0換算で-1, その一個前だから-2
                        assignedValue = contents.randomElement()!
                    }
                }
                returnArray!.append(assignedValue)
            }
        }/*else{
            for _ in 1...2{//amount無視
                assignedValue = contents.randomElement()!
                returnArray!.append(assignedValue)
            }
        }*/
        returnArray!.append(realAnswer)
        return returnArray!
    }
    
    func fileReset(){
        print("button 00 pressed")
        isFileLoaded = false
        print("cleared files")
        openedFileName = "select .csv file"//リセット
        csvNameStore = [[String]]()
        //fileURLは初期化されないが使われないようになる。
        isFileSelected = false
        //仕様の構想
        //ファイルが見つからなければ無視する
        //選んだ時点でMinMaxは消すようにする。
        //リセットしたら再表示する。
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
        }
        else{
            if isFileSelected == true{ //ファイルが選ばれたら自動入力
                maxBoxValue = csvNameStore[0].count
                minBoxValue = 1
            }
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
        }
    }
    
    func buttonNext(){
        print("button 1 (NEXt) pressed")
        //historySeq = nil
        if drawCount >= drawLimit{
            self.showingAlert.toggle()
        }
        else{
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
                    remainderSeq.append(give1RndNumberNoSave(min: minBoxValue, max: maxBoxValue, historyList: historySeq))//ここ変えます
                }else{
                    repeat{
                        pickedNumber = give1RndNumberNoSave(min: minBoxValue, max: maxBoxValue, historyList: historySeq)
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
        }
    }
    
    func startTimer() {
        isTimerRunning = true
        isButtonEnabled = false
        rollTimer = Timer.scheduledTimer(withTimeInterval: 1 / rollSpeed, repeats: true) { timer in
            //print("rollCounter was \(rollListCounter)")
            rollListCounter += 1
            //print("rollCounter is \(rollListCounter)")
            if rollListCounter >= rollCountLimit {
                stopTimer()
                isButtonEnabled = true
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
    func fontSemiBoldRound(size: Int) -> some View {
        self
            .font(.system(size: CGFloat(size), weight: .semibold, design: .rounded))
            .foregroundColor(.white)
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
}

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

func loadCSV(fileURL: URL) -> [[String]]? {
    do {
        // CSVファイルの内容を文字列として読み込む
        var csvString = try String(contentsOf: fileURL, encoding: .utf8)
        
        // キャリッジリターン文字を改行文字に変換
        csvString = csvString.replacingOccurrences(of: "\r", with: "")
        
        // 改行とカンマでCSVを分割し、行と列を取得
        var rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
        var columns = rows[0].components(separatedBy: ",")
        
        // 転置が必要な場合は行と列を入れ替える
        if rows.count < columns.count {
            (rows, columns) = (columns, rows)
        }
        
        // 転置した結果を格納する配列
        var transposedCSV = [[String]]()
        
        // 各列ごとに行を作成して転置
        for columnIndex in 0..<columns.count {
            var transposedRow = [String]()
            for rowIndex in 0..<rows.count {
                let rowData = rows[rowIndex].components(separatedBy: ",")
                
                // IndexOutOfRangeを防ぐために、rowDataの要素数がcolumnIndex未満の場合は空文字列を追加
                if columnIndex < rowData.count {
                    transposedRow.append(rowData[columnIndex])
                } else {
                    transposedRow.append("") // もしくはエラーハンドリングを追加
                }
            }
            transposedCSV.append(transposedRow)
        }
        
        return transposedCSV
    } catch {
        // エラーが発生した場合はnilを返す
        print("Error reading CSV file: \(error)")
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

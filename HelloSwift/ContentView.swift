import SwiftUI
import Foundation //Random
import Combine //TextField limitter
import UniformTypeIdentifiers //fileImporter

struct ContentView: View {
    @AppStorage("minValue") private var minValue: Int = 1
    @AppStorage("maxValue") private var maxValue: Int = 50
    @State private var maxValueLock: Int = 0//Start Overを押すと変更した値を反映するようにしたい
    @State private var minValueLock: Int = 0
    //@State private var minValue: Int = 1//forDebug only
    //@State private var maxValue: Int = 50//forDebug only
    @State private var drawCount = 1 //今何回目か
    @State private var currentLimit: Int = 0
    @State private var dispNumber: Int = 0//今表示する番号。
    @State private var historySeq: [Int]? = nil //保存できるようにするかも　今はしない
    let maxNumberLen = 10 //最大桁数
    //fileImporter
    @State var fileName = "select .csv file"
    @AppStorage("fileLocation") var fileLocation = URL(string: "file://")!//defalut値おかしいけどDont care
    @State var openingFile = false//開くときのダイアログ用
    @State private var fileSelected = false//ファイル選ばれたかどうか
    @State private var csvNames = [[String]]()//名前を保存しないので起動時にロードしなおします。
    @State private var dispName: String = "J.Appleseed"
    
    @FocusState private var amountIsFocused: Bool
    @State private var showingAlert = false //アラートは全部で2つ
    @State private var showingAlert2 = false//数値を入力/StartOver押す指示

    func genRndNumber(min_val: Int, max_val: Int, list: inout [Int]?) -> Int {//本体
        var randomNum: Int = Int.random(in: min_val...max_val)
        if list != nil{
            repeat {
                randomNum = Int.random(in: min_val...max_val)
            } while list!.contains(randomNum) //多分
            list!.append(randomNum)
        }
        return randomNum
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)//このグラデと背景を重ねるからZStack
            TabView {
                VStack(){//１ページ目
                    Spacer(minLength: 1)
                    HStack{
                        Button(action: {self.openingFile.toggle()}){
                            Text("open csv")
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()//左端に表示するため
                    }
                    Spacer(minLength: 15) //こいつ。。。
                    Text("No.\(drawCount)")
                        .font(.system(size: 32, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text(verbatim: "\(dispNumber)")//カンマなし　５０の時変になる
                        .font(.system(size: 142, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text(dispName)
                        .font(.system(size: 26, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(0.6)
                    
                    Spacer(minLength: 68)
                    //Spacer() //バカみたい
                    HStack(){//ここは一時的なものですぐにでも変更したい箇所です。l
                        Text(self.fileName)
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .foregroundColor(.white)
                        Button(action: {
                            print("button 00 pressed")
                            print("cleared files")
                            fileName = "select .csv file"
                            csvNames = [[String]]()
                            //fileURLは初期化されないが使われないようになる。
                            fileSelected = false
                            //仕様の構想
                            //ファイルが見つからなければ無視する
                            //選んだ時点でMinMaxは消すようにする。
                            //リセットしたら再表示する。
                        }){
                            Text("clear names")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width:140, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                                )
                        }
                    }
                    Spacer(minLength: 1)
                    HStack{
                        Spacer(minLength: 60)
                        VStack{
                            Text("Min")
                                .font(.system(size: 24, weight: .medium, design: .default))
                                .foregroundColor(.white)
                            TextField("Min", value: $minValue, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .focused($amountIsFocused)
                                .keyboardType(.numberPad)
                                .onReceive(Just(minValue)) { _ in//文字数制限.
                                    if String(minValue).count > maxNumberLen {
                                        minValue = Int(String(minValue).prefix(maxNumberLen))!
                                    }
                                }
                        }
                        Spacer(minLength: 70)
                        VStack{
                            Text("Max")
                                .font(.system(size: 24, weight: .medium, design: .default))
                                .foregroundColor(.white)
                            TextField("Max", value: $maxValue, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .focused($amountIsFocused)
                                .keyboardType(.numberPad) // 追加
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {// Doneボタンを片方に追加
                                            amountIsFocused = false
                                        }
                                    }
                                }
                                .onReceive(Just(maxValue)) { _ in
                                    if String(maxValue).count > maxNumberLen {
                                        maxValue = Int(String(maxValue).prefix(maxNumberLen))!
                                    }
                                }
                        }
                        Spacer(minLength: 60)
                    }
                    Spacer(minLength: 48)
                    HStack(spacing: 40){ // lower buttons.
                        Spacer()
                        Button(action: {
                            print("button 1 pressed")
                            print("current draw is \(dispNumber) and No.\(drawCount)")
                            //historySeq = nil
                            if drawCount >= currentLimit{
                                self.showingAlert.toggle()
                            }
                            else{
                                dispNumber = genRndNumber(min_val: minValue, max_val: maxValue, list: &historySeq)
                                drawCount += 1 // draw next number
                                if fileSelected == true{
                                    dispName = String(csvNames[0][dispNumber - 1])
                                }else{
                                    dispName = "J.Appleseed"
                                }
                            }
                        }){
                            Text("Next draw")
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width:135, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        // ぼかし効果 // .ultraThinMaterialはiOS15から対応
                                        .foregroundStyle(.ultraThinMaterial)
                                        // ドロップシャドウで立体感を表現
                                        .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                                )
                        }
                        .alert("All drawn", isPresented: $showingAlert) {
                            // アクションボタンリスト
                        } message: {
                            Text("Press Start Over to Reset")
                        }//ここが今わかっていない
                        
                        Button(action: {
                            print("button 2 pressed")
                            if minValue > maxValue{
                                self.showingAlert2.toggle()
                            }
                            else{
                                if fileSelected == true{
                                    maxValue = csvNames[0].count
                                    minValue = 1
                                }
                                maxValueLock = maxValue
                                minValueLock = minValue
                                print("\(maxValueLock), \(minValueLock)")//なんも入ってないー(madakinishinai)
                                currentLimit = maxValue - minValue + 1
                                historySeq = nil
                                dispNumber = genRndNumber(min_val: minValue, max_val: maxValue, list: &historySeq)
                                drawCount = 1
                                if fileSelected == true{
                                    dispName = String(csvNames[0][dispNumber - 1])
                                }else{
                                    dispName = "J.Appleseed"
                                }
                                print(historySeq as Any)
                                print("current draw is \(dispNumber) and No.\(drawCount)")
                                print("total would be No.\(currentLimit)")
                                //randomSeqStore = randomSeq //
                            }
                        }) {
                            Text("Start over")
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width:135, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(color: .init(white: 0.4, opacity: 0.6), radius: 5, x: 0, y: 0)
                                )
                        }
                        .alert("Error", isPresented: $showingAlert2) {
                            // アクションボタンリスト
                        } message: {
                            Text("put bigger number on right box")
                        }//ここが今わかっていない
                        Spacer()
                    }
                    Spacer(minLength: 65)
                } //Main Interface Here
                .tabItem {
                  Text("Main") }
                .tag(0)
            
                Text("History Page")//リストを表示！
                    .onAppear{//スワイプしたらキーボード隠す
                        amountIsFocused = false
                    }
                .tabItem {
                  Text("History") }
                .tag(1)
                
                Text("Setting Page")//リストを表示！
                .tabItem {
                  Text("Setting") }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            //.padding()
            .ignoresSafeArea(edges: .top)
        }
        .fileImporter( isPresented: $openingFile, allowedContentTypes: [UTType.commaSeparatedText], allowsMultipleSelection: false
        ){ result in
            if case .success = result {
                do{
                    let fileURL: URL = try result.get().first!
                    //self.fileName = fileURL.first?.lastPathComponent ?? "file not available"
                    self.fileLocation = fileURL//これでFullパス
                    self.fileName = fileLocation.lastPathComponent//名前だけ
                    print(fileLocation)
                    if fileLocation.startAccessingSecurityScopedResource() {
                        print("loading files")
                        csvNames = transposeCSV(fileURL: fileLocation)!
                        print(csvNames)
                        //audioFiles.append(AudioObject(id: UUID().uuidString, url: audioURL))
                        fileSelected = true//確実に
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
        .onAppear{
            currentLimit = maxValue - minValue + 1
            dispNumber = genRndNumber(min_val: minValue, max_val: maxValue, list: &historySeq)
            print(historySeq as Any)
            print("current draw is \(dispNumber) and No.\(drawCount)")
            print("total would be No.\(currentLimit)")
            if fileSelected == true{
                dispName = String(csvNames[0][dispNumber - 1])
            }else{
                dispName = "J.Appleseed"
            }
        }
    }
}

func transposeCSV(fileURL: URL) -> [[String]]? {
    do {
        // CSVファイルの内容を文字列として読み込む
        let csvString = try String(contentsOf: fileURL, encoding: .utf8)
        
        // 改行とカンマでCSVを分割し、行と列を取得
        let rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }//letでいいっていうから
        let columns = rows[0].components(separatedBy: ",")
        
        // 転置した結果を格納する配列
        var transposedCSV = [[String]]()
        
        // 各列ごとに行を作成して転置
        for columnIndex in 0..<columns.count {
            var transposedRow = [String]()
            for rowIndex in 0..<rows.count {
                let rowData = rows[rowIndex].components(separatedBy: ",")
                transposedRow.append(rowData[columnIndex])
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

import SwiftUI
import Foundation //Random
import UniformTypeIdentifiers //fileimporter

struct ContentView: View {
    @AppStorage("minValue") private var minValue: Int = 1 //OK
    @AppStorage("maxValue") private var maxValue: Int = 50
    //@State private var minValue: Int = 1 //OK
    //@State private var maxValue: Int = 50
    @State private var drawCount = 1 //今何回目か
    @State private var drawNumber = 20 //これは多分無駄！
    var currentLimit: Int {
        maxValue - minValue + 1
    }
    var randomSeq: [Int]{
        generateRandomNumber(min_val: minValue, max_val: maxValue) // すぐに更新されるの良くない
    }//HOW compute not doing anything???
    //@State private var currentLimit = 0
    @State private var randomSeqStore = [Int]()
    // @State private var csvNames = [] // 名前を読み込んで突っ込む
    // @State private var csvEnabled = false // 読み込んだら有効
    @AppStorage("filePath") var fileName = "no file chosen"
    @State var openFile = false
    @FocusState private var amountIsFocused: Bool
    @State private var showingAlert = false //アラートは全部で2つ必要。数値を入力　と　StartOver..
    @State private var showingAlert2 = false
    
    /*init(){
        randomSeq = randomSeqLoad
        currentLimit = currentLimitLoad //行かれた！！！何も入ってな＝＝＝い！
        print(randomSeqLoad)
        print(currentLimitLoad)
        print(randomSeq)
        print(currentLimit)
    }*/

    /*    init() {
     randomSeq = generateRandomNumber(min: maxValue, max: minValue)
     drawNumber = randomSeq[drawCount - 1] //起動時に毎回リセットして保存されたMaxMinを元に生成してその一個目を表示。
     currentLimit = maxValue - minValue + 1
     print(randomSeq)
     }*/
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            TabView {
                VStack(){//１ページ目
                    HStack{
                        Button(action: {self.openFile.toggle()}){
                            Text("open csv")
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()//左端に表示するため
                    }
                    Spacer(minLength: 10) //こいつ。。。。。。
                    Text("No.\(drawCount)") // ここへんのテキストあとで変えます
                        .font(.system(size: 35, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("\(randomSeq[drawCount])")
                        .font(.system(size: 120, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("J.Appleseed")
                        .font(.system(size: 27, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(0.6)
                    
                    Spacer(minLength: 60)
                    //Spacer() //バカみたい
                    Text(self.fileName)
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .foregroundColor(.white)
                    Spacer(minLength: 20)
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
                        }
                        Spacer(minLength: 60)
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
                        }//またあとでいじるの＝＝＝＝！！
                        Spacer(minLength: 60)
                    }
                    HStack(spacing: 40){ // lower buttons.
                        Spacer()
                        Button(action: {
                            print("button 1 pressed")
                            print("current draw is \(drawNumber) and No.\(drawCount)")
                            print("up to No.\(currentLimit)")
                            if drawCount >= currentLimit{
                                self.showingAlert.toggle()
                            }
                            else{
                                drawCount += 1 // draw next number
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
                        .alert("resetNow", isPresented: $showingAlert) {
                            // アクションボタンリスト
                        } message: {
                            Text("press StartOver")
                        }//ここが今わかっていない
                        
                        Button(action: {
                            print("button 2 pressed")
                            //currentLimit = maxValue - minValue + 1//ここでいかにgetterSetter???
                            drawCount = 1
                            print("currentLimit is NOW \(currentLimit)")// calling
                            print(randomSeq)
                            print("total draws would be \(currentLimit)")
                            //randomSeqStore = randomSeq //
                            
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
                        Spacer()
                    }
                    Spacer(minLength: 70)
                } //Main Interface Here
                .tabItem {
                  Text("Main") }
                .tag(0)
            
                Text("History Page")//リストを表示！
                .tabItem {
                  Text("History") }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle())
            //.padding()
            .ignoresSafeArea(edges: .top)
        }
        .fileImporter( isPresented: $openFile, allowedContentTypes: [UTType.commaSeparatedText], allowsMultipleSelection: false, onCompletion: {
            (Result) in // CSVLoad!
            do{
                let fileURL = try Result.get()
                print(fileURL)
                self.fileName = fileURL.first?.lastPathComponent ?? "file not available"
            }
            catch{
                print("error reading file \(error.localizedDescription)")
            }
        })
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



func generateRandomNumber(min_val: Int, max_val: Int) -> [Int] { //エンジン
    let randomNumbers = Array(min_val...max_val).shuffled() //arrayLiteral: ??
    return randomNumbers
}



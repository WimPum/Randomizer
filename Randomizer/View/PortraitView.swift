//
//  PortraitView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/22.
//

import SwiftUI
import Foundation //Random
import UniformTypeIdentifiers //fileImporter

struct PortraitView: View {
    //main
    @State private var minBoxValue: String = "1"
    @State private var maxBoxValue: String = "50"
    @State private var showCSVButtonAndName: Bool = true // キーボード入力する時に1番上と名前表示する部分を隠す
    @State private var showingAlert = false     //アラートは全部で2つ
    @State private var showingAlert2 = false    //数値を入力/StartOver押す指示
    @FocusState private var isInputMinFocused: Bool//キーボードOn/Off
    @FocusState private var isInputMaxFocused: Bool//キーボードOn/Off
    private let inputMaxLength: Int = 10                      //最大桁数

    //fileImporter
    @State private var openedFileLocation = URL(string: "file://")!//defalut値確認
    @State private var isOpeningFile = false                       //ファイルダイアログを開く変数
    @State private var isShowingCSVTutor = false                    // チュートリアル
    @State private var showMessage: String = ""
    @State private var showMessageOpacity: Double = 0.0 //0.0と0.6の間を行き来します

    //ENVS
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjになった設定
    @EnvironmentObject var randomStore: RandomizerState
    
    //misc
    @State private var viewSelection = 1    //ページを切り替える用
    @State private var isSettingsView: Bool = false//設定画面を開く用

    var body: some View {
        ZStack { //グラデとコンテンツを重ねるからZStack
            TabView(selection: $viewSelection){
                //MARK: 1ページ目
                VStack(){
                    Spacer().frame(height: 5)
                    if showCSVButtonAndName == true{ //キーボード出す時は隠してます
                        HStack(){
                            Button(action: {
                                if configStore.isFirstRunning == true{
                                    self.isShowingCSVTutor.toggle()
                                    configStore.isFirstRunning = false // permanent change :)
                                } else {
                                    self.isOpeningFile.toggle()
                                }
                            }){
                                Text("open csv").padding(13)
                            }.disabled(randomStore.isButtonPressed)
                            Spacer()//左端に表示する
                            Button(action: {self.isSettingsView.toggle()}){
                                Image(systemName: "gearshape.fill").padding(.trailing, 12.0)
                            }
                        }
                        .fontSemiBold(size: 24)//フォントとあるがSF Symbolsだから
                    }
                    Spacer()
                    VStack(){                                                               //上半分
                        Text("No.\(randomStore.drawCount)")
                            .fontMedium(size: 32)
                            .frame(height: 40)
                        Button(action: {
                            print("big number pressed")
                            buttonNext()
                        }){
                            Text(verbatim: "\(randomStore.rollDisplaySeq![randomStore.rollListCounter-1])")
                                .fontSemiBoldRound(size: 160, rolling: randomStore.isTimerRunning)
                                .frame(height: 170)
                                .minimumScaleFactor(0.2)
                        }.disabled(randomStore.isButtonPressed)
                            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in//振ったら
                                if randomStore.isButtonPressed == false{
                                    print("device shaken!")
                                    buttonNext()
                                }
                            }
                        if showCSVButtonAndName == true{ //キーボード出す時は隠してます
                            if randomStore.isFileSelected == true{
                                Text(randomStore.csvNameStore[0][randomStore.rollDisplaySeq![randomStore.rollListCounter-1]-1])//ファイルあれば
                                    .fontMessage(opacity: showMessageOpacity)
                            } else {
                                Text(LocalizedStringKey(showMessage))//ファイルないとき
                                    .fontMessage(opacity: showMessageOpacity)
                            }
                        }
                    }
                    Spacer()//何とか
                    VStack(){                                                               //下半分
                        if randomStore.isFileSelected == false {
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
                                        .disabled(randomStore.isButtonPressed)
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
                                        .disabled(randomStore.isButtonPressed)
                                }
                                Spacer()
                            }
                        }
                        else{
                            HStack(){
                                Text(randomStore.openedFileName)// select csv file
                                    .fontMedium(size: 20)
                            }
                            Button(action: {
                                print("button csvClear! pressed")
                                fileReset(message: "press Start Over to apply changes")
                                withAnimation(){
                                    showMessageOpacity = 0.0
                                }
                            }){
                                Text("clear names")
                                    .fontSemiBold(size: 18)
                                    .padding()
                                    .frame(width:140, height: 36)
                                    .glassMaterial(cornerRadius: 24)
                            }.disabled(randomStore.isButtonPressed)
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
                            print("next button pressed")
                            buttonNext()
                        }){
                            Text("Next draw")
                                .glassButton()
                        }.disabled(randomStore.isButtonPressed)
                        .alert("All drawn", isPresented: $showingAlert) {
                            // アクションボタンリスト
                        } message: {
                            Text("press Start over to reset")
                        }
                        Spacer()
                        Button(action: {
                            print("reset button pressed")
                            buttonReset()
                        }) {
                            Text("Start over")
                                .glassButton()
                        }.disabled(randomStore.isButtonPressed)
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

                //MARK: 2ページ目
                VStack(){
                    Spacer(minLength: 5)
                    Text("History")//リストを表示
                        .fontSemiBold(size: 20)
                        .padding()
                    if let historySeq = randomStore.historySeq{//historySeqに値入ってたら
                        if historySeq.count > 0{
                            List {
                                ForEach(0..<historySeq.count, id: \.self){ index in
                                    HStack(){
                                        Text("No.\(index+1)")
                                            .fontLight(size: 25)
                                        Spacer()
                                        Text("\(historySeq[index])")
                                            .fontSemiBold(size: 40)
                                            .frame(//width: screenWidth - 140, // when will this be a problem??
                                                   height: 40,
                                                   alignment: .trailing)
                                            .minimumScaleFactor(0.2)
                                    }.listRowBackground(Color.clear)//リストの項目の背景を無効化
                                }
                            }
                            .scrollCBIfPossible()//リストの背景を無効化
                            .listStyle(.plain)
                            .frame(alignment: .center)
                        }else{
                            Color.clear // 何もない時
                                .frame(alignment: .center)
                        }
                    }
                    Spacer(minLength: 20)
                }
                .tabItem {
                  Text("History") }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // https://stackoverflow.com/questions/68310455/
            // 入力中にページが切り替わったらopen csvを元に戻す
            .onChange(of: viewSelection, perform: { _ in
                if viewSelection == 2{ // 1以外ないけど
                    showCSVButtonAndName = true
                    isInputMinFocused = false
                    isInputMaxFocused = false
                }
            })
            .ignoresSafeArea(edges: .top)
        }
        .onAppear{//画面切り替わり時に実行となる
            initReset()
        }
        //設定画面
        .sheet(isPresented: self.$isSettingsView){
            SettingsView(isPresentedLocal: self.$isSettingsView)
        }
        //CSVヘルプ
        .sheet(isPresented: self.$isShowingCSVTutor){
            if #available(iOS 16, *){
                HelpView(isPresented: self.$isShowingCSVTutor)
            }else{
                NavigationView{
                    CSVHelp()
                        .navigationTitle("About CSV")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing){
                                Button(action: {
                                    isShowingCSVTutor = false
                                }){
                                    Text("Done")
                                        .bold()
                                        .padding(5)
                                }
                            }
                        }
                }

            }

        }
        .fileImporter( isPresented: $isOpeningFile, allowedContentTypes: [UTType.commaSeparatedText], allowsMultipleSelection: false
        ){ result in
            if case .success = result {
                do{
                    let fileURL: URL = try result.get().first!
                    self.openedFileLocation = fileURL//これでFullパス
                    if openedFileLocation.startAccessingSecurityScopedResource() {
                        print("loading csv from \(openedFileLocation)")
                        if let csvNames = loadCSV(fileURL: openedFileLocation) {//loadCSVでロードできたら（転置済み）
                            // fileLoading
                            print("Importer: \(csvNames)")            // print all names
                            print("Importer: \(csvNames[0].count)")   // 一列目==[0] 一列目しか表示しません
                            if csvNames[0].count > 1{ // SUCCESS
                                randomStore.clearCsvNames() // まずクリア
                                randomStore.openedFileName = openedFileLocation.lastPathComponent //名前だけ
                                randomStore.csvNameStore = csvNames
                                randomStore.saveCsvNames(csvNames: csvNames) //store DOES THIS WORK??
                                randomStore.isFileSelected = true
                                buttonReset()
                            }else{ // TOO SHORT 一つの時もmin==maxでエラー
                                print("ERROR list too SHORT!!")
                                fileReset(message: "Error: List needs to have at least two items.")
                                withAnimation{
                                    showMessageOpacity = 0.6
                                }
                            }
                        }else{
                            print("no files")
                            // Message改行できない😭
                            fileReset(message: "Error loading files. Please load files from local storage.")
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
    
    func fileReset(message: String) {
        print("cleared files")
        randomStore.isFileSelected = false
        randomStore.openedFileName = ""//リセット
        randomStore.csvNameStore = [[String]]()//空　isFileSelected の後じゃないと落ちる
        randomStore.clearCsvNames()
        showMessage = message//変更するけど見えない
    }
    
    func initReset() {//起動時に実行 No.0/表示: 0 実行中にこんなんやったらまずすぎ
        minBoxValue = String(randomStore.minBoxValueLock)//保存から復元
        maxBoxValue = String(randomStore.maxBoxValueLock)

        if randomStore.isFileSelected == false{
            showMessage = "press Start Over to apply changes"
        } else {
            showMessageOpacity = 0.6
        }
        print("HistorySequence \(randomStore.historySeq as Any)\ntotal would be No.\(randomStore.drawLimit)")
//        randomStore.historySeq! = Array(1...99978)//履歴に数字をたくさん追加してパフォーマンス計測
////        // O(N) は重い。。。今ではだいぶ軽くなった
//        randomStore.drawCount = 99978
    }
    
    func buttonReset() {
        guard !randomStore.isButtonPressed else { return } // isButtonPressed == trueなら帰る
        showCSVButtonAndName = true
        randomStore.isButtonPressed = true // 同時押しブロッカー
        
        //Reset固有
        randomStore.clearHistory()
        // ここはrndのpublishedな方を参照
        if (minBoxValue == "") { // 入力値が空だったら現在の値で復元
            minBoxValue = String(randomStore.minBoxValueLock)
        }
        if (maxBoxValue == "") {
            maxBoxValue = String(randomStore.maxBoxValueLock)
        }
        if Int(minBoxValue)! >= Int(maxBoxValue)!{ // チェック
            self.showingAlert2.toggle()
            randomStore.isButtonPressed = false
            return
        }
        if randomStore.isFileSelected == true{ //ファイルが選ばれたら自動入力
            minBoxValue = "1"
            maxBoxValue = String(randomStore.csvNameStore[0].count)
            showMessageOpacity = 0.6
        }else{
            withAnimation{//まず非表示？
                showMessageOpacity = 0.0
            }
            showMessage = "press Start Over to apply changes" //違ったら戻す
        }
        // ここをminMaxSave
        randomStore.minBoxValueLock = Int(minBoxValue)!
        randomStore.maxBoxValueLock = Int(maxBoxValue)!
        print("mmBoxVal: \(minBoxValue), \(maxBoxValue)")
        
        isInputMinFocused = false
        isInputMaxFocused = false
        randomStore.randomNumberPicker(mode: 2, configStore: configStore)//まとめた
    }
    
    func buttonNext() {
        guard !randomStore.isButtonPressed else { return } // isButtonPressed == trueなら帰る
        randomStore.isButtonPressed = true // 同時押しブロッカー
        
        showCSVButtonAndName = true
        if randomStore.drawCount >= randomStore.drawLimit{ // チェック
            self.showingAlert.toggle()
            randomStore.isButtonPressed = false
        }
        else{
            if randomStore.isFileSelected == false{ //ファイルが選ばれてなかったら
                if maxBoxValue == String(randomStore.maxBoxValueLock) && minBoxValue == String(randomStore.minBoxValueLock){
                    withAnimation{//まず非表示？
                        showMessageOpacity = 0.0
                    }
                }
                showMessage = "press Start Over to apply changes" //違ったら戻す
                
                // Nextを押すと変更されたことを通知できなかった
                if maxBoxValue != String(randomStore.maxBoxValueLock) || minBoxValue != String(randomStore.minBoxValueLock){
                    showMessage = "press Start Over to apply changes" //絶対にStartOverと表示
                    withAnimation{
                        showMessageOpacity = 0.6
                    }
                }else{
                    withAnimation{
                        showMessageOpacity = 0.0
                    }
                }
            }
            isInputMinFocused = false
            isInputMaxFocused = false
            randomStore.randomNumberPicker(mode: 1, configStore: configStore)//まとめました
        }
    }
    
    func buttonKeyDone(){
        showMessageOpacity = 0.0 // 名前欄の透明度リセットします
        showCSVButtonAndName = true
        isInputMaxFocused = false
        isInputMinFocused = false
        if maxBoxValue != String(randomStore.maxBoxValueLock) || minBoxValue != String(randomStore.minBoxValueLock){
            showMessage = "press Start Over to apply changes" //絶対にStartOverと表示
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

#Preview {
    PortraitView()
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
        .environmentObject(RandomizerState.shared)
}

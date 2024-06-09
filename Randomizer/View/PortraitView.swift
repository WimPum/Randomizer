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

    //fileImporter
    @State private var openedFileLocation = URL(string: "file://")!//defalut値確認
    @State private var isOpeningFile = false                       //ファイルダイアログを開く変数
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
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjになった設定
    
    //外部ディスプレイと共用します 本当に共有が必要な変数のみ入っている
    @EnvironmentObject var randomStore: RandomizerState
    
    //misc
    @State private var viewSelection = 1    //ページを切り替える用
    @State private var isSettingsView: Bool = false//設定画面を開く用

    var body: some View {
        ZStack { //グラデとコンテンツを重ねるからZStack
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
                        .disabled(randomStore.isButtonPressed)
                    }
                    Spacer()
                    VStack(){                                                               //上半分
                        Text(configStore.isAutoDrawOn ? "No.\(randomStore.drawCount) (Auto)" : "No.\(randomStore.drawCount)")
                            .fontMedium(size: 32)
                            .frame(height: 40)
                        Button(action: {
                            if randomStore.isButtonPressed == false{
                                randomStore.isButtonPressed = true
                                print("big number pressed")
                                buttonNext()
                            }
                        }){
                            Text(verbatim: "\(randomStore.rollDisplaySeq![randomStore.rollListCounter-1])")
                                .fontSemiBoldRound(size: 160, rolling: randomStore.isTimerRunning)
                                .frame(height: 170)
                                .minimumScaleFactor(0.2)
                        }.disabled(randomStore.isButtonPressed)
                            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in//振ったら
                                if randomStore.isButtonPressed == false{
                                    randomStore.isButtonPressed = true
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
                                fileReset()
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
                            if randomStore.isButtonPressed == false{
                                randomStore.isButtonPressed = true
                                print("next button pressed")
                                buttonNext()
                            }
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
                            if randomStore.isButtonPressed == false{
                                randomStore.isButtonPressed = true
                                print("reset button pressed")
                                buttonReset()
                            }
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
            .onChange(of: viewSelection, perform: { _ in // 入力中にページが切り替わっても隠れた物は元に戻る
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
                    randomStore.openedFileName = openedFileLocation.lastPathComponent //名前だけ
                    print(openedFileLocation)
                    if fileURL.startAccessingSecurityScopedResource() {
                        print("loading files")
                        if let csvNames = loadCSV(fileURL: openedFileLocation) {//loadCSVでロードできたら
                            defer {
                                fileURL.stopAccessingSecurityScopedResource()
                            }
                            randomStore.isButtonPressed = true //ボタンを押せないようにする
                            randomStore.csvNameStore = csvNames
                            print("Success \(randomStore.csvNameStore)")
                            randomStore.isFileSelected = true
                            buttonReset()
                        }else{
                            randomStore.isFileSelected = false
                            print("no files")
                            randomStore.openedFileName = ""//リセット
                            randomStore.csvNameStore = [[String]]()//空
                            showMessage = "Error loading files. Please load files from local storage." // 改行できない😭
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
        randomStore.openedFileName = ""//リセット
        withAnimation(.linear(duration: 0.5)){
            randomStore.isFileSelected = false
            showMessageOpacity = 0.0
        }
        showMessage = "press Start Over to apply changes"//変更するけど見えない
        randomStore.csvNameStore = [[String]]()//空　isFileSelected の後じゃないと落ちる
    }
    
    func initReset() {//起動時に実行 No.0/表示: 0
        randomStore.isButtonPressed = false // 操作できない状態にしない
        minBoxValue = String(randomStore.minBoxValueLock)//保存から復元
        maxBoxValue = String(randomStore.maxBoxValueLock)
        randomStore.drawLimit = randomStore.maxBoxValueLock - randomStore.minBoxValueLock + 1
        if randomStore.isFileSelected == false{
            showMessage = "press Start Over to apply changes"
        } else {
            showMessageOpacity = 0.6
        }
        print("HistorySequence \(randomStore.historySeq as Any)\ntotal would be No.\(randomStore.drawLimit)")
//        randomStore.historySeq! = Array(1...9999999920)//履歴に数字をたくさん追加してパフォーマンス計測 O(N) は重い。。。
//        randomStore.drawCount = 9999999921
    }
    
    func buttonReset() {
        showCSVButtonAndName = true
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
        //Reset固有
        randomStore.historySeq = []//リセットだから?????????????
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
        randomStore.minBoxValueLock = Int(minBoxValue)!
        randomStore.maxBoxValueLock = Int(maxBoxValue)!
        print("mmBoxVal: \(minBoxValue), \(maxBoxValue)")
        
        isInputMinFocused = false
        isInputMaxFocused = false
        Task{
            if configStore.isAutoDrawOn == true{ // AutoDrawMode on
                await randomStore.autoDrawMode(mode: 2, configStore: configStore)
            } else { // off
                await randomStore.randomNumberPicker(mode: 2, configStore: configStore)//まとめました
            }
        }
    }
    
    func buttonNext() {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // Nextを押すと変更されたことを通知できなかった
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
            isInputMinFocused = false
            isInputMaxFocused = false
            Task{
                if configStore.isAutoDrawOn == true{ // AutoDrawMode on
                    await randomStore.autoDrawMode(mode: 1, configStore: configStore)
                } else { // off
                    await randomStore.randomNumberPicker(mode: 1, configStore: configStore)//まとめました
                }
            }
        }
    }
    
    func buttonKeyDone(){
        showMessageOpacity = 0.0 // 名前欄の透明度リセットします
        showCSVButtonAndName = true
        isInputMaxFocused = false
        isInputMinFocused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
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
}

#Preview {
    PortraitView()
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
        .environmentObject(RandomizerState.shared)
}

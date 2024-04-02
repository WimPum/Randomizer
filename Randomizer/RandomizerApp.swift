//
//  HelloSwiftApp.swift
//  HelloSwift
//
//  Created by 虎澤謙 on 2023/11/17.
//

import SwiftUI
import UIKit

@main
struct RandomizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func give1RndNumber(min: Int, max: Int, historyList: [Int]?) -> Int {//履歴保持なし
    guard let historyList = historyList, !historyList.isEmpty else{ //guard文を覚える
        //print("give1rnd direct output")
        return Int.random(in: min...max)
    }
    //var randomNum: Int = Int.random(in: min...max) //ロール用に使うときにはまずhistoryを作る?
    //print("今の届いたリストforRoll: \(String(describing: historyList))")//ログが多いと遅くなる
    //print("min: \(min), max: \(max)")
    var randomNum: Int
    var attempts = 0
    repeat{
        randomNum = Int.random(in: min...max)
        attempts += 1
//        if attempts > (max - min + 1){
//            // Break the loop if all numbers are in remainedList
//            // This prevents potential infinite loop
//            assertionFailure("All numbers are in remainedList")
//            return -1 // Or handle this case differently based on your requirements
//        }
    }while historyList.contains(randomNum)//guardのおかげでforceUnwrapもいらない
    //print("picked \(randomNum)")
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
        returnArray!.append(realAnswer)
    }
    return returnArray!
}

func interpolateQuadratic(t: Double, minValue: Double, maxValue: Double) -> Double { // 二次関数
    let clampedT = max(0, min(1, t))//0から1の範囲で制限
    return (1 - clampedT) * maxValue + clampedT * minValue
}

func firstLang() -> String {
    let prefLang = Locale.preferredLanguages.first
    return prefLang!
}

func setMessageReset(language: String) -> String {
    if language.hasPrefix("ja"){
        return "やり直しを押して変更を適用"
    }
    else {
        return "press Start Over to apply changes"
    }
}

func setMessageErrorLoad(language: String) -> String {
    if language.hasPrefix("ja"){
        return "ファイルを読み込めませんでした。\n「このiPhone内」から選択してください。"
    }
    else {
        return "Error loading files. \nPlease load files from local storage."
    }
}

func giveHaptics(impactType: String, ifActivate: Bool){
    if ifActivate == false{
        return
    }
    else if impactType == "soft"{
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()//Haptic Feedback
        //AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {} // AudioToolbox
    }
    else if impactType == "medium"{
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()//Haptic Feedback
    }
}

func loadCSV(fileURL: URL) -> [[String]]? { // AI written code
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

func giveRandomBackground(conf: Int, current: Int) -> Int{
    if 0...5 ~= conf{//confが0以上3以下なら　つまりconfをそのままgradPickerに
        return conf//currentを直接編集しない
    }else{
        var randomNumber: Int
        repeat{
            randomNumber = Int.random(in: 0...5)//0...3は自分で色と対応させる
        }while current == randomNumber
        return randomNumber
    }
}

func returnColorCombo(index: Int) -> [Color] {
    let colorList: [[Color]] = [
        [Color.blue, Color.purple], // Default
        [Color.blue, Color.red], // Twilight
        [Color.red, Color.green], // Mountain
        [Color.green, Color.blue], // Ocean
        [Color.mint, Color.indigo], // Sky
        [Color.black, Color.green] // 実験体
    ]
    return colorList[index]
}

extension View {
    //iOSバージョンで分岐 リスト背景透明化
    func scrollCBIfPossible() -> some View {
        if #available(iOS 16.0, *) {//iOS16以降ならこっちでリスト透明化
            return self.scrollContentBackground(.hidden)
        } else {
            UITableView.appearance().backgroundColor = UIColor(.clear)
            return self
        }
    }
    
    //色とか スタイル
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
            return self // ロール中は半透明
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
    func setUnderline() -> some View { // TextFieldに使います
        self
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(.white)
    }
    func glassButton() -> some View {
        self
            .fontSemiBold(size: 22)
            .padding()
            .frame(width:135, height: 55)
            .glassMaterial(cornerRadius: 12)
    }
}

extension Color { // from https://blog.ottijp.com/2023/12/17/swift-hex-color/
  /// create new object with hex string
  init?(hex: String, opacity: Double = 1.0) {
    // delete "#" prefix
    let hexNorm = hex.hasPrefix("#") ? String(hex.dropFirst(1)) : hex

    // scan each byte of RGB respectively
    let scanner = Scanner(string: hexNorm)
    var color: UInt64 = 0
    if scanner.scanHexInt64(&color) {
      let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
      let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
      let blue = CGFloat(color & 0x0000FF) / 255.0
      self.init(red: red, green: green, blue: blue, opacity: opacity)
    } else {
      // invalid format
      return nil
    }
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

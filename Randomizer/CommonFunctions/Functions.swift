//
//  MainFunctions.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import SwiftUI
import UIKit

// 最大最小と履歴をもとに数字を選ぶ
func give1RndNumber(min: Int, max: Int, historyList: [Int]?) -> Int {
    guard let historyList = historyList, !historyList.isEmpty else{
        return Int.random(in: min...max)
    }
    var randomNum: Int
    repeat{
        randomNum = Int.random(in: min...max)
    }while historyList.contains(randomNum)//guardのおかげでforceUnwrapもいらない
    return randomNum
}

// ロールエフェクト用の数列生成 returnArrayの最後にrealAnswerを追加する
// contentsはまだ選んでいない数(remainderSeq)
func giveRandomSeq(contents: [Int]!, length: Int, realAnswer: Int) -> [Int]{
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

// 二次関数 最大値から最小値までを移動する
func interpolateQuadratic(t: Double, minValue: Double, maxValue: Double) -> Double {
    let clampedT = max(0, min(1, t))//0から1の範囲で制限
    return (1 - clampedT) * maxValue + clampedT * minValue
}

// 今の設定言語を調べる
func firstLang() -> String {
    let prefLang = Locale.preferredLanguages.first
    return prefLang!
}

// 最大最小の設定変更されたら表示するメッセージ
// 日本語かそれ以外かで分けている
func setMessageReset(language: String) -> String {
    if language.hasPrefix("ja"){
        return "やり直しを押して変更を適用"
    }
    else {
        return "press Start Over to apply changes"
    }
}

// 外部のCSVファイルを読み込むとき、
// OneDriveやGoogle Driveからは読み取れないからこのエラーを表示させる
func setMessageErrorLoad(language: String) -> String {
    if language.hasPrefix("ja"){
        return "ファイルを読み込めませんでした。\n「このiPhone内」から選択してください。"
    }
    else {
        return "Error loading files. \nPlease load files from local storage."
    }
}

// 触覚を発生させます
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

// CSVを読み込んで二次元配列に代入する 縦に長いリストにしてください
func loadCSV(fileURL: URL) -> [[String]]? { // AI written code
    do {
        // CSVファイルの内容を文字列として読み込む
        var csvString = try String(contentsOf: fileURL, encoding: .utf8)
        
        // キャリッジリターン文字を改行文字に変換
        csvString = csvString.replacingOccurrences(of: "\r", with: "")
        
        // 改行とカンマでCSVを分割し、行と列を取得
        var rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }
        var columns = rows[0].components(separatedBy: ",")
        
        // 横に長い時は転置する
        // 縦に1つとか何も書かれていない時は多分落ちる
        if rows.count < columns.count {
            (rows, columns) = (columns, rows)
        }
        
        // 転置した結果を格納する配列
        var transposedCSV = [[String]]()
        
        // 各列ごとに行を作成
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
    if 0...15 ~= conf{//confが0以上3以下なら　つまりconfをそのままgradPickerに
        return conf//currentを直接編集しない
    }else{
        var randomNumber: Int
        repeat{
            randomNumber = Int.random(in: 0...15)//0...3は自分で色と対応させる
        }while current == randomNumber
        return randomNumber
    }
}

// グラデーションの定義
// 別ファイルにしたい(Settings系にするとか)
func returnColorCombo(index: Int) -> [Color] {
    let colorList: [[Color]] = [
        [Color.blue, Color.purple],                     // Default
        [Color(hex: "5d77b9")!, Color(hex: "fadb92")!], // dawn
        [Color(hex: "4161b8")!, Color(hex: "e56f5e")!], // Twilight
        [Color.red, Color.yellow],                      // Fire
        [Color(hex: "eb426f")!, Color(hex: "4ce7d2")!], // miracle
        [Color(hex: "41c78e")!, Color(hex: "c670f7")!], // Dream
        [Color(hex: "ccdf83")!, Color(hex: "2cde83")!], // summer
        [Color(hex: "dedfe3")!, Color(hex: "4a8a8b")!], // winter
        [Color(hex: "0645fc")!, Color(hex: "d2fafe")!], // Sky
        [Color(hex: "60e5ca")!, Color(hex: "374ebf")!], // Ocean
        [Color(hex: "f59067")!, Color(hex: "63d115")!], // Mountain
        [Color(hex: "70efda")!, Color(hex: "0d6967")!], // mint
        [Color.purple, Color.indigo],                   // grape
        [Color(hex: "de3c87")!, Color(hex: "fbe7ee")!], // strawberry
        [Color(hex: "2f9311")!, Color(hex: "e0f2e0")!], // green tea
        [Color(hex: "e5bd62")!, Color(hex: "4b3457")!]  // champagne
    ]
    return colorList[index]
}

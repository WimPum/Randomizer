//
//  MainFunctions.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import UIKit

// 最大最小と履歴をもとに数字を選ぶ
// Setで高速化なるか？
func give1RndNumber(min: Int, max: Int, historyList: [Int]?) -> Int {
    guard let historySet = historyList.map(Set.init), !historySet.isEmpty else{
        return Int.random(in: min...max)
    }
    var randomNum: Int
    repeat{
        randomNum = Int.random(in: min...max)
    }while historySet.contains(randomNum)//guardのおかげでforceUnwrapもいらない
    return randomNum
}

// ロールエフェクト用の数列生成 returnArrayの最後にrealAnswerを追加する
// contentsはまだ選んでいない数(remainderSeq)
func giveRandomSeq(contents: [Int]!, length: Int, realAnswer: Int) -> [Int]{
    var returnArray = [Int]()
    let listLength = contents.count//リストの長さ
    if listLength > 1{
        for _ in 0..<length-1{
            var assignedValue = contents.randomElement()!//ランダムに1つ抽出
            repeat{//1回目以降は
                assignedValue = contents.randomElement()!   
            } while returnArray.last == assignedValue
            returnArray.append(assignedValue)
        }
        returnArray.append(realAnswer)
    }
    return returnArray // 長さは答え含めlengthと一致するはず
}

// 二次関数 最大値から最小値までを移動する
func interpolateQuadratic(t: Double, minValue: Double, maxValue: Double) -> Double {
    let clampedT = max(0, min(1, t))//0から1の範囲で制限
    return (1 - clampedT) * maxValue + clampedT * minValue
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


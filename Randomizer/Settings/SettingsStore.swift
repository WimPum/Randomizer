//
//  SettingsStore.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/21.
//

import SwiftUI

final class SettingsStore: ObservableObject{
    @AppStorage("isHapticsOn") var isHapticsOn: Bool = true
    @AppStorage("isRollingOn") var isRollingOn: Bool = true
    @AppStorage("allowLandscapeNames") var allowLandscapeNames: Bool = true
    @AppStorage("rollingCountLimit") var rollingCountLimit: Int = 20  //数字は25個だけど最後の数字が答え
    @AppStorage("rollingSpeed") var rollingSpeed: Int = 4  //1から7まで
    @AppStorage("backgroundPicker") var backgroundPicker: Int = 0    //今の背景の色設定用　設定画面ではいじれません
    @AppStorage("configBgNumber") var configBgNumber: Int = 16 // hardcodingを避けたかったが仕方なし　シャッフルがデフォ
    @AppStorage("isFirstRunning") var isFirstRunning: Bool = true // 初回起動ですかt/f
    
    @Published var randomColorCombo: [Color] = [Color.blue, Color.purple]
    // 色リスト
    let colorList: [ColorCombo] = [ // AAAAAARRRGGGG!!!! idはstringになります
        ColorCombo(name: "Default",
                   color: [Color.blue, Color.purple]),
        ColorCombo(name: "Dawn",
                   color: [Color(hex: "5d77b9")!, Color(hex: "fadb92")!]),
        ColorCombo(name: "Twilight",
                   color: [Color(hex: "4161b8")!, Color(hex: "e56f5e")!]),
        ColorCombo(name: "Fire",
                   color: [Color.red, Color.yellow]),
        ColorCombo(name: "Miracle",
                   color: [Color(hex: "eb426f")!, Color(hex: "4ce7d2")!]),
        ColorCombo(name: "Dream",
                   color: [Color(hex: "41c78e")!, Color(hex: "c670f7")!]),
        ColorCombo(name: "Summer",
                   color: [Color(hex: "ccdf83")!, Color(hex: "2cde83")!]),
        ColorCombo(name: "Winter",
                   color: [Color(hex: "dedfe3")!, Color(hex: "4a8a8b")!]),
        ColorCombo(name: "Sky",
                   color: [Color(hex: "0645fc")!, Color(hex: "d2fafe")!]),
        ColorCombo(name: "Ocean",
                   color: [Color(hex: "60e5ca")!, Color(hex: "374ebf")!]),
        ColorCombo(name: "Mountain",
                   color: [Color(hex: "f59067")!, Color(hex: "63d115")!]),
        ColorCombo(name: "Mint",
                   color: [Color(hex: "70efda")!, Color(hex: "0d6967")!]),
        ColorCombo(name: "Grape",
                   color: [Color.purple, Color.indigo]),
        ColorCombo(name: "Strawberry",
                   color: [Color(hex: "de3c87")!, Color(hex: "fbe7ee")!]),
        ColorCombo(name: "Green Tea",
                   color: [Color(hex: "2f9311")!, Color(hex: "e0f2e0")!]),
        ColorCombo(name: "Champagne",
                   color: [Color(hex: "fcefc9")!, Color(hex: "cea453")!]),
        ColorCombo(name: "Shuffle", color: []),
        ColorCombo(name: "Random", color: [])
    ]
    
    func giveRandomBgNumber(){ // 呼ばれた時 configBgをもとに背景を選ぶ
        if 0...colorList.count-3 ~= configBgNumber{ // 色を選んだ時
            backgroundPicker = configBgNumber
        }else if configBgNumber == colorList.count-2{  // シャッフル
            var randomBgNumber: Int
            repeat{
                randomBgNumber = Int.random(in: 0...colorList.count-3)//0...3は自分で色と対応させる
            }while backgroundPicker == randomBgNumber // 同じ背景だった時にやり直し
            backgroundPicker = randomBgNumber
        }else{ // ランダム
            randomColorCombo = giveRandomBackground()
            backgroundPicker = configBgNumber
        }
    }
    
    func giveRandomBackground() -> [Color]{
        return [
            Color(hue: Double.random(in: 0...1), saturation: Double.random(in: 0...1),
                  brightness: Double.random(in: 0.5...0.9)),
            Color(hue: Double.random(in: 0...1), saturation: Double.random(in: 0...1),
                  brightness: Double.random(in: 0.7...0.95))
        ]
    }
    
    func giveBackground() -> [Color]{ // 今の背景セットを返す
        if configBgNumber != colorList.count-1{
            return colorList[backgroundPicker].color!
        } else {
            return randomColorCombo
        }
    }
    
    func resetSettings() {
        isHapticsOn = true
        isRollingOn = true
        rollingCountLimit = 20
        rollingSpeed = 4
        allowLandscapeNames = true
        configBgNumber = colorList.count-2
        giveRandomBgNumber()
        isFirstRunning = true
    }
}

struct ColorCombo{
    var name: String
    var color: [Color]?
}

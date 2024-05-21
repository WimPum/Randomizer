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
    @AppStorage("rollingCountLimit") var rollingCountLimit: Int = 20  //数字は25個だけど最後の数字が答え
    @AppStorage("rollingSpeed") var rollingSpeed: Int = 4  //1から7まで
    
    // この二つなんとかしたい
    @AppStorage("currentGradient") var gradientPicker: Int = 0    //今の背景の色設定用　設定画面ではいじれません
    @AppStorage("configBackgroundColor") var configBgColor = 0 //0はデフォルト、この番号が大きかったらランダムで色を
    
    @AppStorage("backgroundName") var backgroundName: String = "Default" // 日本語化でDefaultを認識できなくなったら💀
    
    // 色リスト 翻訳できるだろうか
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
                   color: [Color(hex: "e5bd62")!, Color(hex: "4b3457")!]),
        ColorCombo(name: "Shuffle", color: [])
    ]
    func giveRandomBackground(conf: Int, current: Int) -> Int{
        if 0...colorList.count-1 ~= conf{//confが0以上3以下なら　つまりconfをそのままgradPickerに
            return conf//currentを直接編集しない
        }else{
            var randomNumber: Int
            repeat{
                randomNumber = Int.random(in: 0...colorList.count-1)//0...3は自分で色と対応させる
            }while current == randomNumber
            return randomNumber
        }
    }
}

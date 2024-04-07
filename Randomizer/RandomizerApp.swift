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
    @StateObject var store = ExternalBridge.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

final class SettingsBridge: ObservableObject{
    @AppStorage("Haptics") var isHapticsOn: Bool = true
    @AppStorage("rollingAnimation") var isRollingOn: Bool = true
    @AppStorage("rollingAmount") var rollingCountLimit: Int = 20//数字は25個だけど最後の数字が答え
    @AppStorage("rollingSpeed") var rollingSpeed: Int = 4//1から7まで
    @AppStorage("currentGradient") var gradientPicker: Int = 0    //今の背景の色設定用　設定画面ではいじれません
    @AppStorage("configBackgroundColor") var configBgColor = 0 //0はデフォルト、この番号が大きかったらランダムで色を
}

// 外部ディスプレイ対応
// 参考：https://useyourloaf.com/blog/swiftui-supporting-external-screens/

final class ExternalBridge: ObservableObject{ // ContentViewで使える？
    @Published var externalRollSeq: [Int]? = [0]
    @Published var externalRollCount: Int = 1
    @Published var isExternalRolling: Bool = false
    @Published var externalGradient: Int = 0
    static let shared = ExternalBridge()
}



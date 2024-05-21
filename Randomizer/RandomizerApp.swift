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
    @StateObject var store = ExternalBridge.shared // 外部画面用
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

// EnvironmentObjectとするclassをここで宣言する??

// 外部ディスプレイ対応
// 参考：https://useyourloaf.com/blog/swiftui-supporting-external-screens/

final class ExternalBridge: ObservableObject{ // ContentViewで使える？
    @Published var externalRollSeq: [Int]? = [0]
    @Published var externalRollCount: Int = 1
    @Published var isExternalRolling: Bool = false
    @Published var externalGradient: Int = 0
    static let shared = ExternalBridge()
}



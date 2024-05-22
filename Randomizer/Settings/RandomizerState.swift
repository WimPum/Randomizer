//
//  RandomizerState.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/22.
//

import Foundation

// 外部ディスプレイ対応
// 参考：https://useyourloaf.com/blog/swiftui-supporting-external-screens/

final class RandomizerState: ObservableObject{
    @Published var rollDisplaySeq: [Int]? = [0] //ロール表示用に使う数字//名前をセーブするなら変更
    @Published var rollListCounter: Int = 1     //ロールのリスト上を移動
    @Published var isTimerRunning: Bool = false
    static let shared = RandomizerState()
}

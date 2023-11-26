//
//  HelloSwiftApp.swift
//  HelloSwift
//
//  Created by 虎澤謙 on 2023/11/17.
//

import SwiftUI

@main
struct HelloSwiftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func generateRandomNumber(min_val: Int, max_val: Int) -> [Int] { //エンジン
    let randomNumbers = Array(min_val...max_val).shuffled() //arrayLiteral: ??
    return randomNumbers
}

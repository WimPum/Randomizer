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
    @StateObject var store = RandomizerState.shared // 横画面用
    @StateObject var config = SettingsStore()
    @StateObject var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(config) // inject it! https://stackoverflow.com/questions/72505839/
                .environmentObject(store)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}

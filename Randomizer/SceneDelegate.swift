//
//  SceneDelegate.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = scene as? UIWindowScene else {
        return
    }
    let content = LandscapeView().environmentObject(SettingsStore())
                        .environmentObject(RandomizerState.shared)   // Where does store come from?
    window = UIWindow(windowScene: scene)
    window?.rootViewController = UIHostingController(rootView: content)
    window?.isHidden = false
    }
}

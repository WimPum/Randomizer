//
//  Extensions.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import SwiftUI

extension View {
    
    //iOSバージョンで分岐 リスト背景透明化
    func scrollCBIfPossible() -> some View {
        if #available(iOS 16.0, *) {//iOS16以降ならこっちでリスト透明化
            return self.scrollContentBackground(.hidden)
        } else {
            UITableView.appearance().backgroundColor = UIColor(.clear)
            return self
        }
    }
    
    //色とかフォント スタイル
    func fontLight(size: Int) -> some View {
        self
            .font(.system(size: CGFloat(size), weight: .light, design: .default))
            .foregroundStyle(.white)
    }
    func fontMedium(size: Int) -> some View {
        self
            .font(.system(size: CGFloat(size), weight: .medium, design: .default))
            .foregroundColor(.white)
    }
    func fontSemiBold(size: Int) -> some View {
        self
            .font(.system(size: CGFloat(size), weight: .semibold, design: .default))
            .foregroundColor(.white)
    }
    
    // ロール中に半透明(ロール中です！！という効果) 選んだ番号の表示用
    func fontSemiBoldRound(size: Int, rolling: Bool) -> some View {
        if rolling == true{
            return self
                .font(.system(size: CGFloat(size), weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .opacity(0.4)
        }else{
            return self
                .font(.system(size: CGFloat(size), weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .opacity(1)
            }
    }
    
    func fontMessage(opacity: CGFloat) -> some View{
        self
            .fontSemiBold(size: 26)
            .multilineTextAlignment(.center)
            .opacity(opacity)
            .frame(height: 60)
            .padding(.horizontal, 20)
            .minimumScaleFactor(0.2)
    }
    
    func glassMaterial(cornerRadius: Int) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                .foregroundStyle(.ultraThinMaterial)
                .shadow(color: .init(white: 0.4, opacity: 0.6), radius: 5, x: 0, y: 0)
        )
    }
    func glassButton() -> some View {
        self
            .fontSemiBold(size: 22)
            .padding()
            .frame(width:135, height: 55)
            .glassMaterial(cornerRadius: 12)
    }
    
    // TextFieldにした線を引くのに使います
    func setUnderline() -> some View {
        self
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(.white)
    }
}

// HEX(#FFFFFF)から色を指定する Stringで指定
extension Color { // from https://blog.ottijp.com/2023/12/17/swift-hex-color/
    /// create new object with hex string
    init?(hex: String, opacity: Double = 1.0) {
    // delete "#" prefix
        let hexNorm = hex.hasPrefix("#") ? String(hex.dropFirst(1)) : hex

        // scan each byte of RGB respectively
        let scanner = Scanner(string: hexNorm)
        var color: UInt64 = 0
        if scanner.scanHexInt64(&color) {
            let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(color & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        } else {
            // invalid format
            return nil
        }
    }
}

extension UIWindow {
    
    // 画面サイズの取得
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
    
    // シェイクを検知
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
    }
}

extension UIScreen {
    
    // 例: UIScreen.current?.bounds.widthで画面幅を取得できます
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

extension NSNotification.Name {
    
    // シェイクの時の通知の名前
    public static let deviceDidShakeNotification = NSNotification.Name("DeviceDidShakeNotification")
}

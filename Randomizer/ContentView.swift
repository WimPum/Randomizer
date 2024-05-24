//本コード

import SwiftUI

struct ContentView: View {
    
    // 設定画面用
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjになった設定
    
    // 横画面と共用します ほぼ全ての変数が入っている
    @EnvironmentObject var randomStore: RandomizerState

    // 横画面検出(横にしたら縦の大きさ(Vertical)はみんな .compact)
    @Environment(\.verticalSizeClass) private var vSizeClass
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: configStore.giveBackground()),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: configStore.giveBackground()) // Will this even work??
            if vSizeClass == .regular { // なんで動かないの？？
                PortraitView()
            } else {
                LandscapeView()
            }
        }
        .onAppear{//起動時に実行となる　このContentViewしかないから
            configStore.giveRandomBgNumber()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
        .environmentObject(RandomizerState.shared)
}

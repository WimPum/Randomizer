//本コード

import SwiftUI

struct ContentView: View {
    
    //設定画面用
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjになった設定
    
    //外部ディスプレイと共用します 本当に共有が必要な変数のみ入っている
    @EnvironmentObject var randomStore: RandomizerState

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        HStack{
            if horizontalSizeClass == .compact { // なんで動かないの？？
                LandscapeView()
            } else {
                PortraitView()
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

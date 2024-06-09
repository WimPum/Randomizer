//
//  SettingsView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2023/12/23.
//

import SwiftUI

struct SettingsView: View { // will be called from ContentView
    @EnvironmentObject var configStore: SettingsStore // 設定 アクセスできるはず
    @Binding var isPresentedLocal: Bool
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form{
                    SettingsList()
                    Section(header: Text("info")){
                        NavigationLink(destination: AboutView()){
                            Text("About")
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {
                            isPresentedLocal = false
                        }){//どうしよう？
                            Text("Done")
                                .bold()
                                .padding(5)
                        }
                    }
                }
            }
        }
        else {
            NavigationView{//iOS 15用
                Form{
                    SettingsList()
                    Section(header: Text("info")){
                        NavigationLink(destination: AboutView()){
                            Text("About")
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {
                            isPresentedLocal = false
                        }){//どうしよう？
                            Text("Done")
                                .bold()
                                .padding(5)
                        }
                    }
                }
            }
        }
    }
}

struct SettingsList: View{
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjectだから引数なしでいいよね。。。？
    @EnvironmentObject var externalStore: RandomizerState // ContentViewにEnvironmentで設定したからできること
    
    var body: some View {
        Section(header: Text("general")){
            Toggle(isOn: $configStore.allowLandscapeNames){ // 横画面で名前を表示
                Text("Show names when landscape mode")
            }
            Toggle(isOn: $configStore.isHapticsOn){
                Text("Haptics for rolling")
            }
            Toggle(isOn: $configStore.isRollingOn.animation()){
                Text("Rolling animation")
            }
            if configStore.isRollingOn{
                VStack{
                    HStack{ // StepperがmacOSでは使えないので変更
                        Text("Animation speed: \(configStore.rollingSpeed)")
                        Spacer()
                    }
                    IntSlider(value: $configStore.rollingSpeed, in: 1...7, step: 1)
                        .onChange(of: configStore.rollingSpeed){ _ in
                            giveHaptics(impactType: "soft", ifActivate: configStore.isHapticsOn)
                        }
                }
                VStack{
                    HStack{ // StepperがmacOSでは使えないので変更
                        Text("Animation count: \(configStore.rollingCountLimit)")
                        Spacer()
                    }
                    IntSlider(value: $configStore.rollingCountLimit, in: 2...100, step: 1)
                }
            }
            Picker("Background color", selection: $configStore.configBgNumber){ // selectionにはid(string)が含まれる。
                ForEach(0..<configStore.colorList.count, id: \.self) { index in
                    Text(LocalizedStringKey(configStore.colorList[index].name))
                }
            }
            .onChange(of: configStore.configBgNumber) { _ in
                withAnimation(){
                    configStore.giveRandomBgNumber()
                }
            }
            Button("Reset setting", action:{
                configStore.resetSettings()
            })
        }
        Section(header: Text("AutoDrawMode")){
            Toggle(isOn: $configStore.isAutoDrawOn.animation()){
                Text("Enable AutoDrawMode")
            }
            if configStore.isAutoDrawOn == true{
                HStack{
                    Text("Interval: \(configStore.AutoDrawInterval)")
                    Spacer()
                }
                IntSlider(value: $configStore.AutoDrawInterval, in: 2...10, step: 1)
            }
        }
    }
}

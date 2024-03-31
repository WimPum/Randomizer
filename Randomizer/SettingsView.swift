//
//  SettingsView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2023/12/23.
//

import SwiftUI

struct SettingsView: View { // will be called from ContentView
    @Binding var isPresentedLocal: Bool
    @ObservedObject var configStore: SettingsBridge     //設定を連れてくる
//    @State private var selectedColorCombo: Int
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form{
                    SettingsList(configStore: configStore)
                    Section(header: Text("info")){
                        LabeledContent("App Version", value: appVersion)
                        LabeledContent("iOS Version", value: UIDevice.current.systemVersion)
                        Link("View code on GitHub", destination: URL(string: "https://github.com/WimPum/Randomizer")!)
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
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
            // AccentColorを変更するようにする
        } 
        else {
            NavigationView{//iOS 15用
                Form{
                    SettingsList(configStore: configStore)
                    Section(header: Text("info")){
                        HStack{
                            Text("App Version")
                            Spacer()
                            Text(appVersion).opacity(0.45)
                        }
                        HStack{
                            Text("iOS Version")
                            Spacer()
                            Text(UIDevice.current.systemVersion).opacity(0.45)
                        }
                        Link("View code on GitHub", destination: URL(string: "https://github.com/WimPum/Randomizer")!)
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
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
    @ObservedObject var configStore: SettingsBridge // SettingsViewを呼び出すときの引数をこちらに代入
    var body: some View {
        Section(header: Text("general")){
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
            Picker("Background color", selection: $configStore.configBgColor){
                Text("Default").tag(0)
                Text("Twilight").tag(1)
                Text("Mountain").tag(2)
                Text("Ocean").tag(3)
                Text("Sky").tag(4)//dummy
                Text("Exp1").tag(5)//dummy2
                Text("Random").tag(6)
            }.onChange(of: configStore.configBgColor) { _ in
                withAnimation(){
                    configStore.gradientPicker = giveRandomBackground(conf: configStore.configBgColor, current: configStore.gradientPicker)
                }
            }
            Button("Reset setting", action:{
                configStore.isHapticsOn = true
                configStore.isRollingOn = true
                configStore.rollingCountLimit = 20
                configStore.rollingSpeed = 4
                configStore.configBgColor = 0
                configStore.gradientPicker = giveRandomBackground(conf: configStore.configBgColor, current: configStore.gradientPicker)
            })
        }
    }
}


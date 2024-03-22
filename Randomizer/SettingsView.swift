//
//  SettingsView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2023/12/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresentedLocal: Bool
    @ObservedObject var configStore: SettingsBridge     //設定を連れてくる
//    @State private var selectedColorCombo: Int
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form{
                    Section(header: Text("general")){
                        //Text("About")//リンクになります //丸いボタンで色が表示されていて押されたらpopoverを表示
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
                                        if configStore.isHapticsOn {//触覚が有効なら
                                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()//触覚 lightだと手が痛い
                                        }
                                    }
                            }
                        
                            VStack{
                                HStack{ // StepperがmacOSでは使えないので変更
                                    Text("Animation count: \(configStore.rollingCountLimit)")
                                    Spacer()
                                }
                                IntSlider(value: $configStore.rollingCountLimit, in: 2...100, step: 1)
//                                    .onChange(of: configStore.rollingCountLimit){ _ in // これはひどい
//                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    }
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
                    Section(header: Text("info")){
                        LabeledContent("App Version", value: appVersion)
                        LabeledContent("iOS Version", value: UIDevice.current.systemVersion)
                        Link("View code on GitHub", destination: URL(string: "https://github.com/WimPum/Randomizer")!)
                    }
                    //}//.listRowBackground(Color.clear)//どうしたら？？
                }//.scrollCBIfPossible()//リストの背景を無効化
                //.listRowBackground(Color.clear)
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
            //.tint(.pink)//まとめて変えたい
            // AccentColorを変更するようにする
            .onAppear{
                UINavigationBar.appearance().prefersLargeTitles = true//実機でいうことを聞かない部分
            }
        } 
        else {
            NavigationView{//iOS 15用
                Form{
                    Section(header: Text("general")){
                        //Text("About")//リンクになります //丸いボタンで色が表示されていて押されたらpopoverを表示
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
                                        if configStore.isHapticsOn {//触覚が有効なら
                                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()//触覚 lightだと手が痛い
                                        }
                                    }
                            }
                        
                            VStack{
                                HStack{ // StepperがmacOSでは使えないので変更
                                    Text("Animation count: \(configStore.rollingCountLimit)")
                                    Spacer()
                                }
                                IntSlider(value: $configStore.rollingCountLimit, in: 2...100, step: 1)
//                                    .onChange(of: configStore.rollingCountLimit){ _ in // これはひどい
//                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    }
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
                    //}//.listRowBackground(Color.clear)//どうしたら？？
                }//.scrollCBIfPossible()//リストの背景を無効化
                //.listRowBackground(Color.clear)
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
            //.tint(.pink)
            .onAppear{
                UINavigationBar.appearance().prefersLargeTitles = true
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}




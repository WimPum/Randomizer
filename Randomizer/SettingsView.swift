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
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
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
                            Stepper(value: $configStore.rollingSpeed, in: 1...7){//M1 Macでは使えない
                                Text("Animation speed: \(configStore.rollingSpeed)")
                            }
//                            TextField("count", value: $configStore.rollingCountLimit, formatter: NumberFormatter()){//M1 Macでは使えない
//                                //Text("Animation number count: \(configStore.rollingCountLimit)")
//                            }
                            Stepper(value: $configStore.rollingCountLimit, in: 2...100){//M1 Macでは使えない
                                Text("Animation count: \(configStore.rollingCountLimit)")
                            }
                        }
                        //Picker
                        Button("Reset setting", action:{
                            configStore.isHapticsOn = true
                            configStore.isRollingOn = true
                            configStore.rollingCountLimit = 25
                            configStore.rollingSpeed = 3
                        })
                    }
                    Section(header: Text("info"), footer: Text("End of section")){
                        LabeledContent("App Version", value: appVersion)
                        LabeledContent("iOS Version", value: UIDevice.current.systemVersion)
                        Link("Source code", destination: URL(string: "https://github.com/WimPum/Randomizer")!)
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
//                Spacer()
//                Text("Randomizer v\(appVersion) by Ulyssa")
//                Text("running on \(UIDevice.current.name), \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
//                    .padding(5)
                
            }.onAppear{
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
                            Stepper(value: $configStore.rollingSpeed, in: 1...7){//M1 Macでは使えない
                                Text("Animation speed: \(configStore.rollingSpeed)")
                            }
//                            TextField("count", value: $configStore.rollingCountLimit, formatter: NumberFormatter()){//M1 Macでは使えない
//                                //Text("Animation number count: \(configStore.rollingCountLimit)")
//                            }
                            Stepper(value: $configStore.rollingCountLimit, in: 2...100){//M1 Macでは使えない
                                Text("Animation count: \(configStore.rollingCountLimit)")
                            }
                        }
                        //Picker
                        Button("Reset setting", action:{
                            configStore.isHapticsOn = true
                            configStore.isRollingOn = true
                            configStore.rollingCountLimit = 25
                            configStore.rollingSpeed = 3
                        })
                    }
                    Section(header: Text("info"), footer: Text("End of section")){
                        HStack{
                            Text("App Version")
                            Spacer()
                            Text(appVersion)
                        }
                        HStack{
                            Text("iOS Version")
                            Spacer()
                            Text(UIDevice.current.systemVersion)
                        }
                        Link("Source code", destination: URL(string: "https://github.com/WimPum/Randomizer")!)
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
//                Spacer()
//                Text("Randomizer v\(appVersion) by Ulyssa")
//                Text("running on \(UIDevice.current.name), \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
//                    .padding(5)
            }.onAppear{
                UINavigationBar.appearance().prefersLargeTitles = true
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}




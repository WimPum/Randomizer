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
                    Toggle(isOn: $configStore.dummyConf1){//ffこのような変数どうする？？
                        Text("Enable Dots1")
                    }
                    Toggle(isOn: $configStore.dummyConf2){
                        Text("Enable Dots2")
                    }
                    Toggle(isOn: $configStore.dummyConf3){
                        Text("Enable Dots3")
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
                Spacer()
                Text("Randomizer v\(appVersion) by Ulyssa")
                Text("running on \(UIDevice.current.name), \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                    .padding(5)
                
            }.onAppear{
                UINavigationBar.appearance().prefersLargeTitles = true
            }
        } else {
            NavigationView{//iOS 15用
                ZStack(){
                    //Color("SettingsBackgroundColors")
                    Form{
                        Toggle(isOn: $configStore.dummyConf1){
                            Text("Enable Dots1")
                        }
                        Toggle(isOn: $configStore.dummyConf2){
                            Text("Enable Dots2")
                        }
                        Toggle(isOn: $configStore.dummyConf3){
                            Text("Enable Dots3")
                        }
                    }   .navigationTitle(Text("Settings"))//タイトルでないですが？
                        .navigationBarTitleDisplayMode(.large)
                        .navigationViewStyle(.stack)
                    //.scrollCBIfPossible()//リストの背景を無効化
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
                    Spacer()
                    Text("Randomizer v\(appVersion)")
                    Text("running on \(UIDevice.current.name), \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
                        .padding(5)
                }
            }.onAppear{
                UINavigationBar.appearance().prefersLargeTitles = true
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}




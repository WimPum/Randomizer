//
//  HelpView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/07/07.
//

import SwiftUI

struct HelpView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                CSVHelp()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing){
                            Button(action: {
                                isPresented = false
                            }){
                                Text("Done")
                                    .bold()
                                    .padding(5)
                            }
                        }
                    }
            }.navigationTitle("About CSV")
            .navigationBarTitleDisplayMode(.inline)

        }else{
            NavigationView{
                CSVHelp()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing){
                            Button(action: {
                                isPresented = false
                            }){
                                Text("Done")
                                    .bold()
                                    .padding(5)
                            }
                        }
                    }
            }.navigationTitle("About CSV")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CSVHelp: View {
    var body: some View{
        TabView(){
            VStack{
                Image(.namesCrop)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 10)
                VStack{ // TEXTS
                    Text("About CSV")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(Font.title2.weight(.bold))
                        .padding(.horizontal, 40)
                        .padding(.bottom, 7)
                    Text("You can load a csv file that contains a list of names and drawn names will be shown under the number.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 40)
                    Spacer()
                }
                .frame(height:175)
                //.border(.yellow)
                Spacer(minLength: 35)
            }.tabItem {
                Text("Main") }
            .tag(1)
            VStack{
                Image(.excele)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 10)
                VStack{
                    Text("Creating CSV files")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(Font.title2.weight(.bold))
                        .padding(.horizontal, 40)
                        .padding(.bottom, 7)
                    Text("You can create CSV files in Excel or Numbers. Lists can be vertical or horizontal. Only the first column of the longer dimension will be used for display.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 40)
                    Spacer()
                }
                .frame(height:180)
                //.border(.yellow)
                Spacer(minLength: 35)
            }.tabItem {
                Text("Next") }
            .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

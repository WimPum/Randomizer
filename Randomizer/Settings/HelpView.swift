//
//  HelpView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/07/07.
//

import SwiftUI

import SwiftUI

struct HelpView: View {
//    @Binding var isPresented: Bool
    
    var body: some View {
        TabView(){
            VStack {
                Image(systemName: "iphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 500)
                Text("Tell us what you think")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.title2.weight(.bold))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 7)
                Text("Use the Feedback Assistant app to report any issues you experience with iOS 18 beta.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 40)
                Spacer()
            }.tabItem {
                Text("Main") }
            .tag(1)
            VStack {
                Image(systemName: "ipad")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 500)
                Text("Switch between apps")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.title2.weight(.bold))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 7)
                Text("To get back to an app you recently used, swipe up and pause, then tap an app to open it.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 40)
                Spacer()
            }.tabItem {
                Text("Next") }
            .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    print("velkommen")
                    //isPresented = false
                }){//どうしよう？
                    Text("Done")
                        .bold()
                        .padding(5)
                }
            }
        }
        //.background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    HelpView()
}

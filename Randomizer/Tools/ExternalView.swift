//
//  ExternalView.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import SwiftUI

struct ExternalView: View {
    @EnvironmentObject var externalStore: ExternalBridge
    var body: some View {
        ZStack(){
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .top, endPoint: .bottom)//このcolorsだけ変えればいいはず
                .edgesIgnoringSafeArea(.all)
            VStack(){
                Text("No.\(externalStore.externalDraw)")
                    .fontMedium(size: 128)
                    //.frame(height: 160)
                Text(verbatim: String(externalStore.externalNumber)).fontSemiBoldRound(size: 640, rolling: false) // rollingも変えられるようにする
                    .frame(height: 540)
                    .minimumScaleFactor(0.2)
            }
        }
    }
}

#Preview {
    ExternalView()
}

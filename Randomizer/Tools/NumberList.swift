//
//  NumberList.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/03/27.
//

import SwiftUI

struct NumberList: View {
    @Binding var historySeq: [Int]?
    let screenWidth: CGFloat
    var index: Int
    
    var body: some View {
        HStack(){
            Text("No.\(index+1)")
                .fontLight(size: 25)
            Spacer()
            Text("\(historySeq![index])")
                .fontSemiBold(size: 40)
                .frame(width: screenWidth - 140,
                       height: 40,
                       alignment: .trailing)
                //.border(.red)
                .minimumScaleFactor(0.2)
        }.listRowBackground(Color.clear)//リストの項目の背景を無効化
    }
}


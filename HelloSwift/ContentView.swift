import SwiftUI
import Foundation

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            TabView {
                VStack(){
                    Spacer()
                    
                    Text("No.2") // ここへんのテキストあとで変えます
                        .font(.system(size: 35, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("52")
                        .font(.system(size: 120, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("J.Appleseed")
                        .font(.system(size: 25, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(0.6)
                    
                    Spacer()
                    
                    /*VStack{
                        TextField("Max:", , formatter: NumberFormatter())
                        TextField("Min:", , formatter: NumberFormatter())
                    }*/
                    
                    HStack(spacing: 35){ // lower buttons.
                        Button(action: {
                            // Button 1 action
                            print("button 1 pressed")
                        }) {
                            Text("Next draw")
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        // ぼかし効果
                            // .ultraThinMaterialはiOS15から対応
                                        .foregroundStyle(.ultraThinMaterial)
                                        // ドロップシャドウで立体感を表現
                                        .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 5, x: 0, y: 0)
                                )

                        }
                        
                        Button(action: {
                            // Button 2 action
                            print("button 2 pressed")
                            let result = generateRandomNumber(min: 1, max: 10) //いイェーーーーーーーいい！！
                            print(result)
                        }) {
                            Text("Start over")
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(color: .init(white: 0.4, opacity: 0.6), radius: 5, x: 0, y: 0)
                                )
                        }
                        
                    }
                    Spacer()
                    Spacer()
                } //Main Interface Here
                .tabItem {
                  Text("Main") }
                .tag(0)
              Text("History Page")
                .tabItem {
                  Text("History") }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle())
            

            .padding()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



func generateRandomNumber(min: Int, max: Int) -> [Int] {
    let randomNumbers = Array(min...max).shuffled()
    return randomNumbers
}



import SwiftUI
import GameController

struct ContentView: View {
    
    let virtualController = createVirtualController([GCInputLeftThumbstick, GCInputButtonA, GCInputButtonB, GCInputButtonOptions])
    @State var showing = true
    let car = Car()
    
    var body: some View {
        ZStack {
            
            if showing {
                Text("Hello, world!")
                    .padding()
            }
            
            GeometryReader { geometry in
              VStack(alignment: .center) {
                Spacer()

                if geometry.size.width < 500 {
                  Text("GCVirtualController requires more horizontal space")
                  .onAppear {
                      showing = false
                  }.onDisappear {
                      showing = true
                  }
                }

                Spacer()
              }
            }
            
            
        }
        .onDisappear(perform: {
            virtualController.disconnect()
          })
      .onAppear(perform: {
        virtualController.connect()

        if let pad = virtualController.controller?.extendedGamepad?.leftThumbstick {
          pad.valueChangedHandler = { (dpad, xValue, yValue) in
            print(dpad, xValue, yValue)
          }
        }

        if let pad = virtualController.controller?.extendedGamepad?.buttonA {
            pad.valueChangedHandler = { (dpad, xValue, yValue) in
                self.car.power(direction: .forward)
            }
        }
          
      if let pad = virtualController.controller?.extendedGamepad?.buttonB {
          pad.valueChangedHandler = { (dpad, xValue, yValue) in
              self.car.power(direction: .backwards)
          }
      }
        
      })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

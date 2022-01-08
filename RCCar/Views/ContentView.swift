import SwiftUI
import GameController

struct ContentView: View {
    
    let virtualController = createVirtualController([GCInputLeftThumbstick, GCInputButtonOptions])
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
        .onDisappear(perform: self.onDissapear)
        .onAppear(perform: self.onAppear)
    }
    
    
    private func onAppear() {
        virtualController.connect()

        guard let leftThumbstick = virtualController.controller?.extendedGamepad?.leftThumbstick else {
          return
      }

        leftThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
            if xValue == 0 && yValue == 0 {
                try! self.car.send(message: Car.TLVMessage(steerPower: 0, motorPower: 0))
                return
            }
            let xValue = xValue + 1
            let yValue = yValue + 1
            let stickSteer = Int32(floor(xValue >= 2 ? 2*255 : xValue * 255.0))
            let stickMotor = Int32(floor(yValue >= 2 ? 2*255 : yValue * 255.0))
//            print("pwmSteer:\(stickSteer), pwmMotor:\(stickMotor)")

            try! self.car.send(message: Car.TLVMessage(steerPower: UInt32(stickSteer), motorPower: UInt32(stickMotor)))
        }
            
            
//            return
//
//            var powerSteer = Int(floor(x >= 0.5 ? 255 : x * 255.0))
//            if powerSteer < 0 {
//                powerSteer = abs(powerSteer)
//            }
//            var powerDrive = Int(floor(y >= 1.0 ? 255 : y * 255.0))
//            if powerDrive < 0 {
//                powerDrive = abs(powerDrive)
//            }
//
//            var power = powerDrive
//            if powerSteer > power {
//                power = powerSteer
//            }
//
//            var steerPower = power
//            steerPower = Int(Double(steerPower) * 1.5)
//            if steerPower > 255 {
//                steerPower = 255
//            }
//
//            print("powerSteer:\(powerSteer)")
//            print("powerDrive:\(powerDrive)")
//            print("power:\(power)")
//            print("x:\(x), y:\(y)")
//
//            let goingForward = y > 0
//            let goingLeft = x < 0
//
//            if steerPower > 100 {
//                if goingLeft {
//                    print("left")
//                    try! self.car.send(command: .left(power: UInt32(steerPower) ))
//                } else {
//                    print("right")
//                    try! self.car.send(command: .right(power: UInt32(steerPower) ))
//                }
//            }
//            if goingForward {
//                try! self.car.send(command: .forward(power: UInt32(powerDrive) ))
//            } else {
//                try! self.car.send(command: .backwards(power: UInt32(powerDrive) ))
//            }
//        }
        
    }
    
    private func onDissapear() {
        virtualController.disconnect()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

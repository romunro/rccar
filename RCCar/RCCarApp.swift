import SwiftUI
import AVFAudio

@main
struct RCCarApp: App {
    
    private let rotationChangePublisher = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
    
    init() {
        print("The integer from C++ is \(getIntFromCPP())")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(rotationChangePublisher) { (value) in
                    if !UIDevice.current.orientation.isLandscape {
                        changeOrientation(to: .landscapeRight)
                    }
                }
        }
    }
    
    func changeOrientation(to orientation: UIInterfaceOrientation) {
        // tell the app to change the orientation
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}

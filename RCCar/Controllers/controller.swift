import Foundation
import GameController

let createVirtualController = { (elements: Set<String>) -> GCVirtualController in

  // Earlier I used `fullScreenCover` for games in MenuScreen,
  // but GCVirtualController was BELOW it.
  // So keep GCVirtualController in View, not Overlay/Modal/Sheet containers
  // https://developer.apple.com/forums/thread/682138

  let virtualConfiguration = GCVirtualController.Configuration()
  virtualConfiguration.elements = elements

  let virtualController = GCVirtualController(configuration: virtualConfiguration)
    
  return virtualController
}

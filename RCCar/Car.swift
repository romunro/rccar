import Foundation
import CoreBluetooth

struct CBUUIDs{
    static let kBLEService_UUID = CBUUID(string: "FFF0")
    
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
}

class Car: NSObject {
    struct Connection {
        let peripheral: CBPeripheral
        let txCharacteristic: CBCharacteristic
        
        func send(data: Data) {
            peripheral.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            print(">"+String(data: data, encoding: .utf8)!)
        }
    }
    
    //Temp reference to peripheral while we establish connection.
    private var tempPeripheral: CBPeripheral?
    var centralManager: CBCentralManager!
    var activeConnection: Connection?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func disconnect() {
        guard let activeConnection = self.activeConnection else {
            return
        }
        centralManager?.cancelPeripheralConnection(activeConnection.peripheral)
    }
    
    func turn() {
        self.send(data: "turn".data(using: .utf8)!)
    }
    
    enum Direction: String {
        case forward
        case backwards
    }
    
    func power(direction: Direction) {
        self.send(data: direction.rawValue.data(using: .utf8)!)
    }
}

extension Car: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .poweredOff:
              print("Is Powered Off.")
          case .poweredOn:
              print("Is Powered On.")
              startScanning()
          case .unsupported:
              print("Is Unsupported.")
          case .unauthorized:
          print("Is Unauthorized.")
          case .unknown:
              print("Unknown")
          case .resetting:
              print("Resetting")
          @unknown default:
            print("Error")
        }
    }
    
    func startScanning() -> Void {
      // Start Scanning
      centralManager?.scanForPeripherals(withServices: [CBUUIDs.kBLEService_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found \(peripheral.name)")
        tempPeripheral = peripheral
        peripheral.delegate = self
        centralManager?.connect(peripheral, options: nil)
        centralManager?.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name)")
        peripheral.discoverServices(nil)
    }
}


extension Car: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        guard characteristics.count == 1, let characteristic = characteristics.first else {
            print("Something went wrong. Expected one characteristic.")
            return
        }
        
        peripheral.setNotifyValue(true, for: characteristic)
        peripheral.readValue(for: characteristic)
        self.activeConnection = Connection(peripheral: peripheral, txCharacteristic: characteristic)
        print("Established connection with peripheral \(peripheral.name) and tx characteristic \(characteristic.uuid)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        guard let data = characteristic.value, let stringValue = String(data: data, encoding: .utf8) else {
            return
        }
        print("< \(data): \(stringValue)")
    }
    
    func send(data: Data) {
        self.activeConnection?.send(data: data)
    }
}

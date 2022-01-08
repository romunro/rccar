import Foundation
import CoreBluetooth
import TLVCoding

struct CBUUIDs{
    static let kBLEService_UUID = CBUUID(string: "FFF0")
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
}

class Car: NSObject {
    
    struct TLVMessage: Codable {
        let steerPower: UInt32
        let motorPower: UInt32
        
        func encode() throws -> Data {
            var encoder = TLVEncoder()
            encoder.numericFormatting = .littleEndian
            var data = try encoder.encode(self)
            data.append(contentsOf: "\n".data(using: .utf8)!)
            return data
        }
    }
    
    struct Connection {
        let peripheral: CBPeripheral
        let txCharacteristic: CBCharacteristic
        
        func send(data: Data) {
            if data.count == 0 {
                return
            }
            peripheral.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            print(">" + data.map{ String(format:"%02x ", $0) }.joined())
            
//            let checksum = CRC32.checksum(data: data)
//            guard let checkSumPayload = "^\(checksum)\n".data(using: .utf8) else {
//                return
//            }
//            let maxSize = peripheral.maximumWriteValueLength(for: CBCharacteristicWriteType.withoutResponse)
//            let chunks = data.chunks(ofCount: maxSize)
//            peripheral.writeValue(checkSumPayload, for: txCharacteristic, type: CBCharacteristicWriateType.withoutResponse)
//            for chunk in chunks {
//                peripheral.writeValue(chunk, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
//            }
        }
    }
    
    //Temp reference to peripheral while we establish connection.
    private var tempPeripheral: CBPeripheral?
    var centralManager: CBCentralManager!
    var activeConnection: Connection?
    var lastSentDate: Int64? = nil
    var messageDebouncer = Debouncer(delay: .milliseconds(100))
    
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
    
    func onConnected() {
        
    }
}

extension Car: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .poweredOff:
              print("BLE is Powered Off.")
          case .poweredOn:
              print("BLE is Powered On.")
              startScanning()
          case .unsupported:
              print("BLE is Unsupported.")
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
         peripheral.discoverServices(nil)
     }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.activeConnection = nil
        self.startScanning()
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
        self.onConnected()
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
    
    
    
    func send(message: TLVMessage) throws {
        if let lastSentDate = self.lastSentDate {
            let diff = Date().millisecondsSince1970 - lastSentDate
            if diff < 100 {
                messageDebouncer.call {
                    print(message)
                    try? self.activeConnection?.send(data: message.encode())
                }
                return
            }
        }
        
        lastSentDate = Date().millisecondsSince1970
        
        print(message)
        try self.activeConnection?.send(data: message.encode())
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

//import Foundation
//import ReplayKit
//
//class Recorder: NSObject, RPScreenRecorderDelegate {
//    private let pcmBufferPointer = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1024)
//    
//    override init() {
//        let unsafeRawPointer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 0)
//       let audioBuffer = AudioBuffer(mNumberChannels: 1, mDataByteSize: 4, mData: unsafeRawPointer)
//       let audioBufferList = AudioBufferList(mNumberBuffers: 0, mBuffers: audioBuffer)
//       self.pcmBufferPointer.initialize(repeating: audioBufferList, count: 1024)
//        super.init()
//    }
//    
//    func record() {
//        RPScreenRecorder.shared().delegate = self
//        RPScreenRecorder.shared().startCapture { (sampleBuffer, bufferType, err) in
//            
//            let status = CMSampleBufferCopyPCMDataIntoAudioBufferList(sampleBuffer, at: 0, frameCount: 1024, into: self.pcmBufferPointer)
//            
//            if status == 0 {
//                print("Buffer copied to pointer")
//                let dataValue = self.pcmBufferPointer[0].mBuffers.mData!.load(as: Float32.self) //Tried with Int, Int16, Int32, Int64 and Float too
//                print("Data value : \(dataValue)") //prints 0.0
//            }else{
//                print("Buffer allocation failed with status \(status)")
//            }
//            
////            let byteCount = sampleBuffer.numSamples * sampleBuffer.sampleSize(at: 0)
////
////            do {
////                let unsafeRawPointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 0)
////                let pcmBufferPointer = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
////                pcmBufferPointer.initialize(to: AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(byteCount), mData: unsafeRawPointer)))
////
////                try sampleBuffer.copyPCMData(fromRange: 0..<sampleBuffer.numSamples, into: pcmBufferPointer)
////
////                let data = Data(bytes: unsafeRawPointer, count: byteCount)
////                // Do something with the data
////                print(data)
////            } catch {
////                print("Error converting buffer: \(error.localizedDescription)")
////            }
//
//        } completionHandler: { (error) in
//            print("b")
//        }
//
//    }
//}

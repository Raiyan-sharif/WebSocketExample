
import Foundation
import AudioToolbox
import AVFoundation

extension Notification.Name {
    static let audioServiceDidUpdateData = Notification.Name(rawValue: "AudioServiceDidUpdateDataNotification")
}

func AQAudioQueueInputCallback(inUserData: UnsafeMutableRawPointer?,
                               inAQ: AudioQueueRef,
                               inBuffer: AudioQueueBufferRef,
                               inStartTime: UnsafePointer<AudioTimeStamp>,
                               inNumberPacketDescriptions: UInt32,
                               inPacketDescs: UnsafePointer<AudioStreamPacketDescription>?) {
    let audioService = unsafeBitCast(inUserData!, to:MAAudioService.self)
//    audioService.writePackets(inBuffer: inBuffer)
    let datalength = inBuffer.pointee.mAudioDataByteSize
    if datalength > 0{
        let data = Data(bytes: inBuffer.pointee.mAudioData, count: Int(datalength))
        audioService.setAudioData(data: data)
        //audioService.setDecibel()
    }else{
        audioService.recordHasStop()
    }
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    PrintUtility.printLog(tag: "MAAudioService", text: "startingPacketCount: \(audioService.startingPacketCount), maxPacketCount: \(audioService.maxPacketCount)")
    if (audioService.maxPacketCount <= audioService.startingPacketCount) {
        //audioService.stopRecord()
    }
}

func AQAudioQueueOutputCallback(inUserData: UnsafeMutableRawPointer?,
                                inAQ: AudioQueueRef,
                                inBuffer: AudioQueueBufferRef) {
    let audioService = unsafeBitCast(inUserData!, to:MAAudioService.self)
    audioService.readPackets(inBuffer: inBuffer)
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    PrintUtility.printLog(tag: "MAAudioService", text: "startingPacketCount: \(audioService.startingPacketCount), maxPacketCount: \(audioService.maxPacketCount)")
    if (audioService.maxPacketCount <= audioService.startingPacketCount) {
        audioService.startingPacketCount = 0;
    }
}

class MAAudioService {
    private let TAG:String = "MAAudioService"
    var timer:Timer?
    var getData:((_ data:Data)->())?
    var recordDidStop:(()->())?
    var getTimer:((_ value:Int)->())?
    var buffer: UnsafeMutableRawPointer
    var audioQueueObject: AudioQueueRef?
    let numPacketsToRead: UInt32 = 1024
    let numPacketsToWrite: UInt32 = 1024
    var startingPacketCount: UInt32
    var maxPacketCount: UInt32
    let bytesPerPacket: UInt32 = 2
    let seconds: UInt32 = 10
    var isRecordStop = true
    var getPower:((_ val:Float)->())?
    var audioFormat: AudioStreamBasicDescription {
        return AudioStreamBasicDescription(mSampleRate: 48000,
                                           mFormatID: kAudioFormatLinearPCM,
                                           mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),
                                           mBytesPerPacket: 2,
                                           mFramesPerPacket: 1,
                                           mBytesPerFrame: 2,
                                           mChannelsPerFrame: 1,
                                           mBitsPerChannel: 16,
                                           mReserved: 0)
    }
    var data: NSData? {
        didSet {
           // NotificationCenter.default.post(name: .audioServiceDidUpdateData, object: self)
        }
    }

    init(_ obj: Any?) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker,.interruptSpokenAudioAndMixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        startingPacketCount = 0
        maxPacketCount = (48000 * seconds)
        buffer = UnsafeMutableRawPointer(malloc(Int(maxPacketCount * bytesPerPacket)))
    }

    deinit {
        buffer.deallocate()
        PrintUtility.printLog(tag: TAG, text: "deinit")
    }

    func startRecord() {
        PrintUtility.printLog(tag: TAG, text: "startRecord")
        guard audioQueueObject == nil else  { return }
        //free(buffer)
       // data = nil
        isRecordStop = false
        prepareForRecord()
        let err: OSStatus = AudioQueueStart(audioQueueObject!, nil)
        PrintUtility.printLog(tag: TAG, text: "err: \(err)")

        // Enable level meter
        var enabledLevelMeter: UInt32 = 1
        AudioQueueSetProperty(self.audioQueueObject!, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, UInt32(MemoryLayout<UInt32>.size))


        setTimer()

    }

//    func stopRecord() {
//        data = NSData(bytesNoCopy: buffer, length: Int(maxPacketCount * bytesPerPacket))
//        AudioQueueStop(audioQueueObject!, true)
//        AudioQueueDispose(audioQueueObject!, true)
//        audioQueueObject = nil
//    }

    func stopRecord() {
           if let audioQueue = audioQueueObject{
               //data = NSData(bytesNoCopy: buffer, length: Int(maxPacketCount * bytesPerPacket))
               isRecordStop = true
               AudioQueueStop(audioQueue, true)
               AudioQueueDispose(audioQueue, true)
               audioQueueObject = nil

           }
       }

    func play() {
        guard audioQueueObject == nil else  { return }
        prepareForPlay()
        let err: OSStatus = AudioQueueStart(audioQueueObject!, nil)
        PrintUtility.printLog(tag: TAG, text: "err: \(err)")
    }

    func stop() {
        AudioQueueStop(audioQueueObject!, true)
        AudioQueueDispose(audioQueueObject!, true)
        audioQueueObject = nil
    }

    func setData(_ data: NSMutableData) {
        self.data = data.copy() as? NSData
        memcpy(buffer, data.mutableBytes, Int(maxPacketCount * bytesPerPacket))
    }

    private func prepareForRecord() {
        PrintUtility.printLog(tag: TAG, text: "prepareForRecord")
        var audioFormat = self.audioFormat

        AudioQueueNewInput(&audioFormat,
                           AQAudioQueueInputCallback,
                           unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                           CFRunLoopGetCurrent(),
                           CFRunLoopMode.commonModes.rawValue,
                           0,
                           &audioQueueObject)

        startingPacketCount = 0;
        var buffers = Array<AudioQueueBufferRef?>(repeating: nil, count: 3)
        let bufferByteSize: UInt32 = numPacketsToWrite * audioFormat.mBytesPerPacket

        for bufferIndex in 0 ..< buffers.count {
            AudioQueueAllocateBuffer(audioQueueObject!, bufferByteSize, &buffers[bufferIndex])
            AudioQueueEnqueueBuffer(audioQueueObject!, buffers[bufferIndex]!, 0, nil)
        }
    }

    private func prepareForPlay() {
        PrintUtility.printLog(tag: TAG, text: "prepareForPlay")
        var audioFormat = self.audioFormat

        AudioQueueNewOutput(&audioFormat,
                            AQAudioQueueOutputCallback,
                            unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                            CFRunLoopGetCurrent(),
                            CFRunLoopMode.commonModes.rawValue,
                            0,
                            &audioQueueObject)

        startingPacketCount = 0
        var buffers = Array<AudioQueueBufferRef?>(repeating: nil, count: 3)
        let bufferByteSize: UInt32 = numPacketsToRead * audioFormat.mBytesPerPacket

        for bufferIndex in 0 ..< buffers.count {
            AudioQueueAllocateBuffer(audioQueueObject!, bufferByteSize, &buffers[bufferIndex])
            AQAudioQueueOutputCallback(inUserData: unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                                       inAQ: audioQueueObject!,
                                       inBuffer: buffers[bufferIndex]!)
        }
    }

    func readPackets(inBuffer: AudioQueueBufferRef) {
        PrintUtility.printLog(tag: TAG, text: "readPackets")
        var numPackets: UInt32 = maxPacketCount - startingPacketCount
        if numPacketsToRead < numPackets {
            numPackets = numPacketsToRead
        }

        if 0 < numPackets {
            memcpy(inBuffer.pointee.mAudioData,
                   buffer.advanced(by: Int(bytesPerPacket * startingPacketCount)),
                   (Int(bytesPerPacket * numPackets)))
            inBuffer.pointee.mAudioDataByteSize = (bytesPerPacket * numPackets)
            inBuffer.pointee.mPacketDescriptionCount = numPackets
            startingPacketCount += numPackets
        }
        else {
            inBuffer.pointee.mAudioDataByteSize = 0;
            inBuffer.pointee.mPacketDescriptionCount = 0;
        }
    }

    func writePackets(inBuffer: AudioQueueBufferRef) {
        PrintUtility.printLog(tag: TAG, text: "writePackets")
        PrintUtility.printLog(tag: TAG, text: "writePackets mAudioDataByteSize: \(inBuffer.pointee.mAudioDataByteSize), numPackets: \(inBuffer.pointee.mAudioDataByteSize / 2)")
        var numPackets: UInt32 = (inBuffer.pointee.mAudioDataByteSize / bytesPerPacket)
        if ((maxPacketCount - startingPacketCount) < numPackets) {
            numPackets = (maxPacketCount - startingPacketCount)
        }

        if 0 < numPackets {
            memcpy(buffer.advanced(by: Int(bytesPerPacket * startingPacketCount)),
                   inBuffer.pointee.mAudioData,
                   Int(bytesPerPacket * numPackets))
            startingPacketCount += numPackets;
        }
        
    }
    
    func setAudioData(data: Data){
        self.getData?(data)
    }

    func setTimer(){
        var runCount = 0
        timer =  Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            print("Timer fired!")
            runCount += 1
        self.setDecibel()
            if runCount == 30 {
                timer.invalidate()
            }
            self.getTimer?(runCount)
        }
    }

    func setDecibel(){
        var levelMeter = AudioQueueLevelMeterState()
        var propertySize = UInt32(MemoryLayout<AudioQueueLevelMeterState>.size)

        AudioQueueGetProperty(
            self.audioQueueObject!,
            kAudioQueueProperty_CurrentLevelMeterDB,
            &levelMeter,
            &propertySize)

        let absValue = abs(levelMeter.mAveragePower)

        if absValue <= 100{
            var avgPower = absValue/100
            avgPower = (avgPower*10).rounded()/10
            self.getPower?(avgPower)
        }

    }

    func timerInvalidate() {
        timer?.invalidate()
        timer = nil
    }
    func recordHasStop(){
        if isRecordStop{
            isRecordStop = false
            self.recordDidStop?()
        }
    }

}

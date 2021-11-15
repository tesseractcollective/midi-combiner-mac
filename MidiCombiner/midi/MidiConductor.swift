import Foundation
import AudioKit
import CoreMIDI
import Combine

struct PortDescription {
    let UID: String
    let manufacturer: String
    let device: String
}

class MidiConductor: ObservableObject, MIDIListener {
    let virtualOutputUID: Int32 = 2_500_000
    let virtualOutputName: String = "Combined Instrument"
    var virtualOutputInfo: EndpointInfo?
    @Published var midi = MIDI()
    @Published var noteInputDevice: MidiNoteDevice?
    @Published var rhythmInputDevice: MidiRhythmDevice?
    @Published var combinedMessage: MidiMessage?
    @Published var log = [MidiMessage]()
    
    init() {
        midi.createVirtualOutputPorts(count: 1, uniqueIDs: [virtualOutputUID], names: [virtualOutputName])
        midi.openOutput(uid: virtualOutputUID)
        midi.openInput()
        midi.addListener(self)
        
        virtualOutputInfo = midi.virtualOutputInfos[0]
    }
    
    var inputNames: [String] {
        midi.inputNames
    }
    var inputUIDs: [MIDIUniqueID] {
        midi.inputUIDs
    }
    var inputInfos: [EndpointInfo] {
        midi.inputInfos
    }

    private let logSize = 30
    
    func inputPortDescription(forUID: MIDIUniqueID?) -> PortDescription {
        print("inputPortDescription: \(String(describing: forUID))")
        var UIDString = forUID?.description ?? "-"
        var manufacturerString = "-"
        var deviceString = "-"
        if let UID = forUID {
            for index in 0..<inputInfos.count where inputInfos[index].midiUniqueID == UID {
                let info = inputInfos[index]

                UIDString = "\(info.midiUniqueID)"
                manufacturerString = info.manufacturer
                deviceString = info.displayName

                return PortDescription(UID: UIDString,
                                       manufacturer: manufacturerString,
                                       device: deviceString)
            }
        }
        return PortDescription(UID: UIDString,
                               manufacturer: manufacturerString,
                               device: deviceString)
    }
    
    func appendToLog(message: MidiMessage) {
        log.insert(message, at: 0)

        if log.count > logSize {
            log.remove(at: log.count-1)
        }
    }
    
    func resetLog () {
        log.removeAll()
    }
    
    func combine(message: MidiMessage) {
        guard message.portUniqueID == rhythmInputDevice?.portUniqueID else {
            return
        }
        
        guard let noteInputDevice = noteInputDevice else {
            print("no noteInputDevice")
            return
        }
        guard let rhythmInputDevice = rhythmInputDevice else {
            print("no rhythmInputDevice")
            return
        }
        guard let rootNoteNumber = noteInputDevice.rootNoteNumber else {
            print("no rootNoteNumber")
            return
        }
        guard let triggerNoteNumber = rhythmInputDevice.triggerNoteNumber else {
            print("no triggerNoteNumber")
            return
        }
        guard let lastRhythmMessage = rhythmInputDevice.lastMessage else {
            print("no triggerNoteNumber")
            return
        }
        
        if triggerNoteNumber == lastRhythmMessage.noteNumber {
            let message = MidiMessage(
                statusType: lastRhythmMessage.statusType,
                channel: lastRhythmMessage.channel,
                noteNumber: rootNoteNumber,
                velocity: lastRhythmMessage.velocity,
                portUniqueID: virtualOutputUID,
                timeStamp: lastRhythmMessage.timeStamp)
            
            combinedMessage = message
            sendVirtual(message: message)
        }
    }
    
    func handle(message: MidiMessage) {
        if let inputDevice = noteInputDevice, inputDevice.portUniqueID == message.portUniqueID {
            inputDevice.handle(message: message)
        } else if let inputDevice = rhythmInputDevice, inputDevice.portUniqueID == message.portUniqueID {
            inputDevice.handle(message: message)
        }
        appendToLog(message: message)
        combine(message: message)
    }
    
    // MARK: - receive
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID?,
                            timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            let message = MidiMessage(statusType: MIDIStatusType.noteOn,
                                      channel: channel,
                                      noteNumber: noteNumber,
                                      velocity: velocity,
                                      portUniqueID: portID,
                                      timeStamp: timeStamp)
            self.handle(message: message)
        }
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID?,
                             timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            let message = MidiMessage(statusType: MIDIStatusType.noteOff,
                                      channel: channel,
                                      noteNumber: noteNumber,
                                      velocity: velocity,
                                      portUniqueID: portID,
                                      timeStamp: timeStamp)
            self.handle(message: message)
        }
    }
    
    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            let message = MidiMessage(statusType: MIDIStatusType.controllerChange,
                                      channel: channel,
                                      noteNumber: controller,
                                      velocity: value,
                                      portUniqueID: portID,
                                      timeStamp: timeStamp)
            self.handle(message: message)
        }
    }
    
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            let message = MidiMessage(statusType: MIDIStatusType.noteOff,
                                      channel: channel,
                                      noteNumber: noteNumber,
                                      velocity: pressure,
                                      portUniqueID: portID,
                                      timeStamp: timeStamp)
            self.handle(message: message)
        }
    }
    
    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        //
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        //
    }
    
    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID?,
                                   timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            let message = MidiMessage(statusType: MIDIStatusType.noteOff,
                                      channel: channel,
                                      noteNumber: program,
                                      velocity: 0,
                                      portUniqueID: portID,
                                      timeStamp: timeStamp)
            self.handle(message: message)
        }
    }
    
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        //
    }

    func receivedMIDISetupChange() {
        //
    }

    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        //
    }

    func receivedMIDINotification(notification: MIDINotification) {
        //
    }
    
    // MARK: - Send
    func send(message: MidiMessage, portIDs: [MIDIUniqueID]?) {
        print("sendMessage")
        if let portIDs = portIDs {
            print("sendEvent, port: \(portIDs[0].description)")
        }
        switch message.statusType {
        case MIDIStatusType.controllerChange:
            midi.sendControllerMessage(message.noteNumber,
                                       value: message.velocity,
                                       channel: message.channel,
                                       endpointsUIDs: portIDs)
        case MIDIStatusType.programChange:
            midi.sendEvent(MIDIEvent(programChange: message.noteNumber,
                                     channel: message.channel),
                                     endpointsUIDs: portIDs)
        case MIDIStatusType.noteOn:
            midi.sendNoteOnMessage(noteNumber: message.noteNumber,
                                   velocity: message.velocity,
                                   channel: message.channel,
                                   endpointsUIDs: portIDs)
        case MIDIStatusType.noteOff:
            midi.sendNoteOffMessage(noteNumber: message.noteNumber,
                                   velocity: message.velocity,
                                   channel: message.channel,
                                   endpointsUIDs: portIDs)
        default:
            // Do Nothing
            ()
        }
    }
    
    func sendVirtual(message: MidiMessage) {
        guard let virtualOutputInfo = virtualOutputInfo else {
            return
        }
        
        let portIDs = [virtualOutputInfo.midiUniqueID]
        let virtualPortIDs = [virtualOutputInfo.midiEndpointRef]
        print("sendMessage: \(message.description)(\(message.statusType)), port: \(portIDs[0].description)")
        
        switch message.statusType {
        case MIDIStatusType.controllerChange:
            midi.sendControllerMessage(message.noteNumber,
                                       value: message.velocity,
                                       channel: message.channel,
                                       endpointsUIDs: portIDs,
                                       virtualOutputPorts: virtualPortIDs)
        case MIDIStatusType.programChange:
            midi.sendEvent(MIDIEvent(programChange: message.noteNumber,
                                     channel: message.channel),
                                     endpointsUIDs: portIDs,
                                     virtualOutputPorts: virtualPortIDs)
        case MIDIStatusType.noteOn:
            midi.sendNoteOnMessage(noteNumber: message.noteNumber,
                                   velocity: message.velocity,
                                   channel: message.channel,
                                   endpointsUIDs: portIDs,
                                   virtualOutputPorts: virtualPortIDs)
        case MIDIStatusType.noteOff:
            midi.sendNoteOffMessage(noteNumber: message.noteNumber,
                                   velocity: message.velocity,
                                   channel: message.channel,
                                   endpointsUIDs: portIDs,
                                   virtualOutputPorts: virtualPortIDs)
        default:
            // Do Nothing
            ()
        }
    }
}

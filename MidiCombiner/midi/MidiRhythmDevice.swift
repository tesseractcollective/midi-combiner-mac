//
//  MidiRhythmDevice.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/14/21.
//

import Foundation
import AudioKit
import CoreMIDI

class MidiRhythmDevice: ObservableObject, Hashable {
    let portUniqueID: MIDIUniqueID
    var lastMessage: MidiMessage?
    var triggerNoteNumber: MIDINoteNumber? = 36
    var shouldSetTrigger: Bool = false
    var description: String {
        get {
            if let lastMessage = lastMessage, lastMessage.statusType == .noteOn {
                return lastMessage.description + "(\(lastMessage.noteNumber))"
            }
            return ""
        }
    }
    var triggerInfo: MidiMessage? {
        get {
            guard let triggerNoteNumber = triggerNoteNumber else {
                return nil
            }
            return MidiMessage(statusType: .noteOn, channel: 0, noteNumber: triggerNoteNumber, velocity: 0, portUniqueID: nil, timeStamp: nil)
        }
    }
    
    init(portUniqueID: MIDIUniqueID) {
        self.portUniqueID = portUniqueID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(portUniqueID)
    }
    
    static func == (lhs: MidiRhythmDevice, rhs: MidiRhythmDevice) -> Bool {
        return (lhs.portUniqueID == rhs.portUniqueID)
    }
    
    func handle(message: MidiMessage) {
        lastMessage = message
        if (shouldSetTrigger && message.statusType == .noteOn) {
            triggerNoteNumber = message.noteNumber
            shouldSetTrigger = false
        }
    }
}

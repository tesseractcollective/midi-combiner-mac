//
//  MidiRhythmDevice.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/14/21.
//

import Foundation
import AudioKit
import CoreMIDI

class MIDIRhythmDevice: MIDIDevice {
    var lastMessage: MIDIMessage?
    var triggerNoteNumber: MIDINoteNumber = 36 // C2
    var shouldSetTrigger: Bool = false
    var description: String {
        get {
            if let lastMessage = lastMessage, lastMessage.statusType == .noteOn {
                return lastMessage.description + "(\(lastMessage.noteNumber))"
            }
            return ""
        }
    }
    var triggerInfo: MIDIMessage {
        return MIDIMessage(statusType: .noteOn, channel: 0, noteNumber: triggerNoteNumber, velocity: 0, portUniqueID: nil, timeStamp: nil)
    }
    
    func handle(message: MIDIMessage) {
        lastMessage = message
        if (shouldSetTrigger && message.statusType == .noteOn) {
            triggerNoteNumber = message.noteNumber
            shouldSetTrigger = false
        }
    }
}

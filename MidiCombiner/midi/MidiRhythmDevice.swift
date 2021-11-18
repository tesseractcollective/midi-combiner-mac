//
//  MidiRhythmDevice.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/14/21.
//

import Foundation
import AudioKit
import CoreMIDI

class MidiRhythmDevice: MidiDevice {
    var lastMessage: MidiMessage?
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
    var triggerInfo: MidiMessage {
        return MidiMessage(statusType: .noteOn, channel: 0, noteNumber: triggerNoteNumber, velocity: 0, portUniqueID: nil, timeStamp: nil)
    }
    
    func handle(message: MidiMessage) {
        lastMessage = message
        if (shouldSetTrigger && message.statusType == .noteOn) {
            triggerNoteNumber = message.noteNumber
            shouldSetTrigger = false
        }
    }
}

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
        if (shouldSetTrigger) {
            triggerNoteNumber = message.noteNumber
            shouldSetTrigger = false
        }
    }
}

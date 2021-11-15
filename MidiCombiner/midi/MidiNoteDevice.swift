//
//  MidiNoteDevice.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/14/21.
//

import Foundation
import AudioKit
import CoreMIDI

class MidiNoteDevice: ObservableObject, Hashable {
    let portUniqueID: MIDIUniqueID
    var noteOnMessages: [MidiMessage] = []
    var noteOffMessages: [MidiMessage] = []
    var lastMessage: MidiMessage?
    var remember: Bool = false
    var rootNoteNumber: MIDINoteNumber?
    var description: String {
        get { return noteOnMessages.map { $0.noteNameOctave }.joined(separator: " ") }
    }
    
    init(portUniqueID: MIDIUniqueID) {
        self.portUniqueID = portUniqueID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(portUniqueID)
    }
    
    static func == (lhs: MidiNoteDevice, rhs: MidiNoteDevice) -> Bool {
        return (lhs.portUniqueID == rhs.portUniqueID)
    }
    
    func calculateRootNoteNumber() {
        if noteOnMessages.count > 0 {
            var noteNumber = noteOnMessages[0].noteNumber
            for message in noteOnMessages {
                if message.noteNumber < noteNumber {
                    noteNumber = message.noteNumber
                }
            }
            rootNoteNumber = noteNumber
        } else {
            rootNoteNumber = nil
        }
    }
    
    func handle(message: MidiMessage) {
        lastMessage = message
        
        switch(message.statusType) {
        case .noteOn:
            if remember && noteOnMessages.count == noteOffMessages.count {
                noteOnMessages.removeAll()
                noteOffMessages.removeAll()
            }
            noteOnMessages.append(message)
            calculateRootNoteNumber()
        case .noteOff:
            if remember {
                noteOffMessages.append(message)
            } else if let index = noteOnMessages.firstIndex(where: { $0.noteNumber == message.noteNumber }) {
                noteOnMessages.remove(at: index)
            }
            calculateRootNoteNumber()
        default:
            ()
        }
    }
}

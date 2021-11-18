//
//  MidiNoteDevice.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/14/21.
//

import Foundation
import AudioKit
import CoreMIDI

enum NoteMode: Int, CaseIterable, Identifiable {
    case root = 0
    case lowest = 1
    case all = 2
    
    var id: Int { self.rawValue }
}

class MidiNoteDevice: MidiDevice {
    let chordRecognizer = ChordRecognizer()
    var noteOnMessages: [MidiMessage] = []
    var noteOffMessages: [MidiMessage] = []
    var lastMessage: MidiMessage?
    var remember: Bool = false
    var mode: NoteMode = .root
    var rootNoteNumber: MIDINoteNumber?
    var noteNumbers: [uint8] {
        noteOnMessages.map { $0.noteNumber }
    }
    var description: String {
        noteOnMessages.map { $0.noteNameOctave }.joined(separator: " ")
    }
    
    func calculateRootNoteNumber() {
        if noteOnMessages.count > 0 {
            if mode == .root && noteOnMessages.count > 1 {
                let chordGroups = chordRecognizer.notesToChord(midiNoteValues: noteNumbers)
                let chord = chordGroups.first?.chords.first
                rootNoteNumber = chord?.rootNote
            } else {
                var noteNumber = noteOnMessages[0].noteNumber
                for message in noteOnMessages {
                    if message.noteNumber < noteNumber {
                        noteNumber = message.noteNumber
                    }
                }
                rootNoteNumber = noteNumber
            }
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

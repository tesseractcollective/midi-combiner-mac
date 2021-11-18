//
//  MidiMessage.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/1/21.
//

import Foundation
import AudioKit
import CoreMIDI

enum MidiCommand: UInt8 {
    case NOTE_OFF = 0x08
    case NOTE_ON = 0x09
    case POLYPHONIC_AFTERTOUCH = 0x0a
    case CONTROL_CHANGE = 0x0b
    case PROGRAM_CHANGE = 0x0c
    case CHANNEL_AFTERTOUCH = 0x0d
    case PITCH_BEND_CHANGE = 0x0e
    case MIDI_TIME_CODE_QUARTER_FRAME = 0xf1
}

let OCTAVE_SEMI_TONES = 12
let NOTE_NAMES = [
    0: ["C"],
    1: ["C#", "Db"],
    2: ["D"],
    3: ["D#", "Eb"],
    4: ["E"],
    5: ["F"],
    6: ["F#", "Gb"],
    7: ["G"],
    8: ["G#", "Ab"],
    9: ["A"],
    10: ["A#", "Bb"],
    11: ["B"],
]
let NOTE_NUMBERS = [
    "C": 0,
    "C#": 1,
    "Db": 1,
    "D": 2,
    "D#": 3,
    "Eb": 3,
    "E": 4,
    "F": 5,
    "F#": 6,
    "Gb": 6,
    "G": 7,
    "G#": 8,
    "Ab": 8,
    "A": 9,
    "A#": 10,
    "Bb": 10,
    "B": 11,
]

func octaveFor(noteNumber: UInt8) -> UInt8 {
    return UInt8(floor(Float(noteNumber) / Float(OCTAVE_SEMI_TONES)) - 1)
}

func noteNameFor(noteNumber: UInt8) -> String {
    return NOTE_NAMES[Int(noteNumber) % OCTAVE_SEMI_TONES]?[0] ?? ""
}

func noteNameOctaveFor(noteNumber: UInt8) -> String {
    return "\(noteNameFor(noteNumber: noteNumber))\(octaveFor(noteNumber: noteNumber))"
}

struct MidiMessage {
    let statusType: MIDIStatusType
    let channel: MIDIChannel
    let noteNumber: MIDINoteNumber
    let velocity: MIDIVelocity
    let portUniqueID: MIDIUniqueID?
    let timeStamp: MIDITimeStamp?
    var noteName: String {
        get { return noteNameFor(noteNumber: noteNumber) }
    }
    var octave: UInt8 {
        get { return octaveFor(noteNumber: noteNumber) }
    }
    var noteNameOctave: String {
        get { return noteNameOctaveFor(noteNumber: noteNumber) }
    }
    var description: String {
        get {
            switch statusType {
            case MIDIStatusType.noteOn:
                return noteNameOctave
            case MIDIStatusType.noteOff:
                return noteNameOctave
            case MIDIStatusType.controllerChange:
                return noteNumber.description + ": " + MIDIControl(rawValue: noteNumber)!.description
            case MIDIStatusType.programChange:
                return noteNumber.description
            default:
                return "-"
            }
        }
    }
}

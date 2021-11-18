//
//  MidiDevice.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/17/21.
//

import Foundation
import CoreMIDI


class MidiDevice: ObservableObject, Hashable {
    let portUniqueID: MIDIUniqueID
    
    init(portUniqueID: MIDIUniqueID) {
        self.portUniqueID = portUniqueID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(portUniqueID)
    }
    
    static func == (lhs: MidiDevice, rhs: MidiDevice) -> Bool {
        return (lhs.portUniqueID == rhs.portUniqueID)
    }
}

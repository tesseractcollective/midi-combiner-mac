//
//  MidiDevice.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 11/17/21.
//

import Foundation
import CoreMIDI


class MIDIDevice: ObservableObject, Hashable {
    let portUniqueID: MIDIUniqueID
    
    init(portUniqueID: MIDIUniqueID) {
        self.portUniqueID = portUniqueID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(portUniqueID)
    }
    
    static func == (lhs: MIDIDevice, rhs: MIDIDevice) -> Bool {
        return (lhs.portUniqueID == rhs.portUniqueID)
    }
}

//
//  ContentView.swift
//  MidiCombiner
//
//  Created by Joshua Dutton on 10/31/21.
//

import SwiftUI
import AudioKit
import CoreMIDI

struct ContentView: View {
    @StateObject var midiConductor: MidiConductor = MidiConductor()
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Note Source:")
                        .bold()
                        .alignmentGuide(HorizontalAlignment.center) { $0.width / 2 }
                    Picker("Input", selection: $midiConductor.noteInputDevice) {
                        Text("None").tag(MidiNoteDevice(portUniqueID: 0))
                        ForEach(0..<midiConductor.inputUIDs.count, id: \.self) { index in
                            Text("\(midiConductor.inputNames[index])")
                                .tag(MidiNoteDevice(portUniqueID: midiConductor.inputUIDs[index]) as MidiNoteDevice)
                        }
                    }
                    Toggle("Remember Last Played", isOn: $midiConductor.noteInputDevice.remember)
                        .toggleStyle(.switch)
                    Picker("Note Mode", selection: $midiConductor.noteInputDevice.mode) {
                        Text("Root").tag(NoteMode.root)
                        Text("Lowest").tag(NoteMode.lowest)
                        Text("All").tag(NoteMode.all)
                    }.pickerStyle(.segmented)
                    Text(midiConductor.noteInputDevice.description)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rhythm Source:").bold()
                    Picker("Input", selection: $midiConductor.rhythmInputDevice) {
                        Text("None").tag(MidiRhythmDevice(portUniqueID: 0))
                        ForEach(0..<midiConductor.inputUIDs.count, id: \.self) { index in
                            Text("\(midiConductor.inputNames[index])")
                                .tag(MidiRhythmDevice(portUniqueID: midiConductor.inputUIDs[index]) as MidiRhythmDevice)
                        }
                    }
                    Toggle("Learn Trigger", isOn: $midiConductor.rhythmInputDevice.shouldSetTrigger)
                        .toggleStyle(.switch)
                    Text("Trigger Note: \(midiConductor.rhythmInputDevice.triggerInfo.noteNameOctave)")
                    Text(midiConductor.rhythmInputDevice.description)
                }
            }
            Divider()
            let description = midiConductor.combinedMessages.map{ $0.description }.joined(separator: " ")
            Text("Combined Virtual Instrument Out: \(description)")
        }
        .padding().frame(minWidth:500.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 300.0)
    }
}

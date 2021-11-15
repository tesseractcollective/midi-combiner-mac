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
            HStack {
                VStack {
                    Text("Note Source")
                        .bold()
                        .padding()
                    
                    Picker(selection: $midiConductor.noteInputDevice,
                           label: Text("Input")) {
                        
                        Text("None")
                            .tag(nil as MidiDevice?)
                        
                        ForEach(0..<midiConductor.inputUIDs.count, id: \.self) { index in
                            Text("\(midiConductor.inputNames[index])")
                                .tag(MidiDevice(portUniqueID: midiConductor.inputUIDs[index]) as MidiDevice?)
                        }
                    }.padding()
                    
                    Text(midiConductor.noteInputDevice?.description ?? "")
                        .padding()
                }
                
                VStack {
                    Text("Rhythm Source")
                        .bold()
                        .padding()
                    
                    Picker(selection: $midiConductor.rhythmInputDevice,
                           label: Text("Input")) {
                        
                        Text("None")
                            .tag(nil as MidiDevice?)
                        
                        ForEach(0..<midiConductor.inputUIDs.count, id: \.self) { index in
                            Text("\(midiConductor.inputNames[index])")
                                .tag(MidiDevice(portUniqueID: midiConductor.inputUIDs[index]) as MidiDevice?)
                        }
                    }.padding()
                    
                    Text(midiConductor.rhythmInputDevice?.description ?? "")
                        .padding()
                }
            }
            
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

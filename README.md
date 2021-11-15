# midi-combiner-mac

Combines inputs from 2 different MIDI sources: A note source and a rhythm source to create a new virtual MIDI instrument. The note source determines which note the new instrument will play, and the rhythm source determines when the new instrument will send that note.

TODO:

- [ ] Note source option: remember last played note
- [ ] Note source option: segmented selection between "Lowest Note", "Root of Chord", and "All Notes"
- [ ] Rhythm source option: learn trigger note (currently it's hard coded to MIDI note number 36 for testing)

## From https://forum.cockos.com/showpost.php?p=1893701&postcount=11

""" Test """
import beyond.Reaper
import beyond.Screen
# from beyond.Reaper.Settings import *
import sys
from math import *
# import numpy
# from reaper_python import *
# from sws_python import *

@ProgramStart
class Main(Parallel):
    def Start(o):
        with Reaper as r:
            PPQ = 960
            START_TIME = 0
            MIDI_ITEM_LEN = 3600
 
            # File>New Project
            r.RPR_Main_OnCommand(40023, 0)

            r.RPR_PreventUIRefresh(1)
            r.RPR_Undo_BeginBlock()

            r.RPR_InsertTrackAtIndex(0, True)
            r_trk = r.RPR_GetTrack(0, 0)
            r_midi_item = r.RPR_CreateNewMIDIItemInProj(
                r_trk, START_TIME, MIDI_ITEM_LEN, False)
            r_midi_item = r_midi_item[0]
            r_take = r.RPR_GetMediaItemTake(r_midi_item, 0)

            def put_note_PPQ(n_pitch, n_start_PPQ, n_len_PPQ, n_chan, n_vel=127):
                #print(n_pitch)
                """ !!! user should use base 1 parameters (1 - 16)
                """
                n_chan -= 1
                n_end_PPQ = n_start_PPQ + n_len_PPQ
                dummy = r.RPR_MIDI_InsertNote(r_take, False, False,
                                              n_start_PPQ,
                                              n_end_PPQ,
                                              0,
                                              n_pitch,
                                              n_vel, True)
                       
            # ***********************************************
            # Data fill start
            # ***********************************************

            start_time = 0
            delta_time = 0
            note = 0
            lastnote = 0

            for angle in range(0, 400000):
                time = angle * 10
                t = radians(angle)
                sinus = sin(0.01 * t)
                note = 40 + int(abs(sinus * 60))

                if lastnote != note:
                    note_len = time - delta_time
                    lastnote = note
                    delta_time = time
                    put_note_PPQ(note, time, note_len, 1, 127)

            # ***********************************************
            # Output
            # ***********************************************
            r.RPR_MIDI_Sort(r_take)
            r.RPR_Undo_EndBlock("My Action", -1)
            r.RPR_UpdateArrange()
            r.RPR_PreventUIRefresh(-1)

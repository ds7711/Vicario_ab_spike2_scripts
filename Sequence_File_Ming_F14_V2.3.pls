;!!! Variable List used in the sequence file
; WAVEGO A, T: play stimulus in Waveform PlayArea A(1); stimulus in PlayArea A is updated in the main script 
; by PlayWaveCopy("A",stimarr%[:stimlen%][cstim%]) & PlayWaveSpeed("A",sratfac[cstim%]). 
; WAVEGO B, T: stimilar to A except Waveform PlayArea B(2) is used. 
; V101: count the # of stimuli that have been played. 
; V100: # of total stimulus trials (the Number of loops needed; Obtained from SampleSeqVar(100,tstims%); )
; V77: stimulus code marked while Waveform PlayArea 1 is used. 
; V78: stimulus code marked while Waveform PlayArea 2 is used. 
; V77 & V78 are updated in the main script by using SampleSeqVar(77) & SampleSeqVar(78) ... ,
        ; so that Sequence file has the mark the correct stimulus code. 
; V65: flagger for Waveform PlayArea, A==1 & B==2. 
; V1: Flagger for Looping status (When V1=1, it signals a new loop starts; When V1=0, it signals a loop finishes). 
; V10: duration from recording onset ('A' is the trigger signal for starting recording)
; V11: duration from stimulus playing onset to recording offset;
        ; Configuration File has higher priority in determing the duration of recording. 
; V5:  duration from the end of previous loop to the start of next loop; 
        ; main script uses this period to check the status of Sequence file. 
; V4: Flagger for stopping the recording. 

                SET    0.01,3277,0
                VAR    V65=1           ;Start from playing area 65 (Area A)
                            ; V65 probably could be used to 
                VAR    V101=0

0000 L0:        DELAY  s(3e-005)       ;Loopback point, delay for 3e-5 second

0001            BEQ    V65,2,P2        ;If AREA = 2, play waveform area 2 instead of 1

0002 L0start:   ADDI   V101,1
0003            MARK   65              ;Generate digital marker for trial start (hex41="A"=65)
0004            MARK   V77             ;mark stim number (V77 stores the stim number code, V77=SampleSeqVar(77,stimcode%))
0005            DELAY  s(97e-005)      ;change (.00994)-1 to s(97e-005) to space MARK-stim
0006            DELAY  s(100e-005)
                        ;   Play waveform in Area A
0007            WAVEGO A,T             ;Arm waveform
                        ;   Play waveform in Area A
0008            DELAY  V10             ;V10=isi%*100000*2/10 in script
0009 L0run:     MOVI   V1,1            ;V1 := 1
0010 L0stim:    MARK   66              ;Generate digital marker at stim onset (66="B")

0011 R00:       WAVEBR R00,W           ;Ensure waveform ready
0012            WAVEST T               ;Trigger waveform
0013            DELAY  V11             ;V11=isi%*100000*5/10 in script
0014            WAVEST S               ;Stop waveform
0015            DAC    0,0             ;zero dac for next stim
0016            DELAY  s(5000e-005)-22 ;There are 22 time steps in the main loop normally; "JUMP TESTV4 is not executed usually"
0017            DELAY  V5              ;V5=isi%*100000*2/10-5200 in script
0018            MOVI   V65,2
0019            MOVI   V1,0            ;V1 := 0
0020 TESTV4:    BEQ    V4,1,NLOOP      ;test V4, alright to continue
                                           ;V4 is only used when user stops the recording and want to start recording again
0021            JUMP   TESTV4          ;loop til V4 = 1

0022 P2:        ADDI   V101,1
0023            MARK   65              ;Generate digital marker for trial start (hex41="A"=65)
0024            MARK   V78             ;mark stim number (V78 stores the stim number code, V78=SampleSeqVar(78,stimcode%))
0025            DELAY  s(97e-005)      ;change (.00994)-1 to s(97e-005) to space MARK-stim
0026            DELAY  s(100e-005)
                        ;   Play waveform in Area B
0027            WAVEGO B,T             ;Arm waveform
                        ;   Play waveform in Area B
0028            DELAY  V10             ;V10=isi%*100000*2/10 in script
0029 L1run:     MOVI   V1,1            ;V1 := 1
0030 L1stim:    MARK   66              ;Generate digital marker at stim onset (66="B")
0031 R11:       WAVEBR R11,W           ;Ensure waveform ready
0032            WAVEST T               ;Trigger waveform
0033            DELAY  V11             ;V11=isi%*100000*5/10 in script
0034            WAVEST S               ;Stop waveform
0035            DAC    0,0             ;zero dac for next stim
0036            DELAY  s(5000e-005)-22 ;There are 22 time steps in the main loop normally; "JUMP TESTV4 is not executed usually"
0037            DELAY  V5              ;V5=isi%*100000*2/10-5200 in script
0038            MOVI   V65,1
0039            MOVI   V1,0            ;V1 := 0
0040 TESTV41:   BEQ    V4,1,NLOOP      ;test V4, alright to continue
                                           ;V4 is only used when user stops the recording and want to start recording again
0041            JUMP   TESTV41         ;loop til V4 = 1

0042 NLOOP:     DBNZ   V100,L0         ;Repeat required times
                                   ;V100: the Number of loops needed; Obtained from SampleSeqVar(100,tstims%); 
0043            HALT                   ;End of this sequence section
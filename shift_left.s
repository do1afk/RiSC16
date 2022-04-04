##################################################################
#Übergabekonvention:
# -shiftweite (n) in r1
# -zu shiftendes Wort (a) in r2
# -Ergebnis wird in r3 zurück gegeben
#################################################################


#Vorbereitung auf shiftl routine:            
            lw r1, r0, n            #lade n in r1
            lw r2, r0, a            #lade a in r2
#shiftl:
            lw r3, r0, null         #lade 0 in r3
            add r3, r3, r2          #addiere r3 mit r2
            
            bne r1, r0, shift_loop  #ist r1=0?
            halt

shift_loop: add r3, r3, r3          #addiere r3 mit r3
            addi r1, r1, -1         #addiere r1 mit -1
            bne r1, r0, shift_loop  #ist r1 = 0?
            halt
            
            
            
n:          .fill 3
a:          .fill 2
null:       .fill 0

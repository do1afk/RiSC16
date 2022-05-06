######################################################################
#implementierte Unterprogramme:
#       -MUL via add
#       -shift_l
######################################################################

#initialisiere Stack

            lw r7, r0, Stack_adr   #Stack Adresse in r7 laden
            lui r1, 0              #ffff in r1 laden
            addi r1, r1, -1
            sw r1, r7, 0           #stack Beginn markieren
            sw r1, r7, -64         #stack Ende markieren
            lui r1, 0              #r1 aufräumen
            bne r7, r0, Start      #übergehe die .fill
        
Stack_adr:  .fill 32767

              
Start:      lui r1, 0

#call MULV2: r3 = r1 * r2
            addi r1, r1, 4
            addi r2, r2, 4
            
            movi r5, MULv2
            jalr r6, r5
            
            lui r1, 0
            lui r2, 0
          
            
            
            

#call shift_l: r3 = r2 r1 mal geshiftet
            addi r1, r1, 3
            addi r2, r2, 3
            
            movi r5, shift_l
            jalr r6, r5
        
                
            

            
        halt
        
######################################################################
#Unterprogramme:
#MULv2:     MUL via add
#   Verwendung: r3 = r1 * r2
######################################################################

MULv2:      addi r7, r7, -1         #r1 pushen
            sw r1, r7, 0
            addi r7, r7, -1         #r2 pushen
            sw r2, r7, 0

            lui r3, 0              #lade r3 mit 0, sicherheitshalber
            
#wird mit 0 multipliziert?
            bne r1, r0, r1_OK       #ist r1=0?
            bne r7, r0, MUL_finish  #fertig
            
r1_OK:      bne r2, r0, MUL_loop    #ist r2=0?
            bne r7, r0, MUL_finish  #fertig
            
MUL_loop:   add r3, r3, r2          #addiere r3 mit r2
            addi r1, r1, -1         #r1 = r1 - 1
            bne r1, r0, MUL_loop    #ist r1=0?
            
MUL_finish: lw r2, r7, 0            #r2 poppen
            addi r7, r7, 1
            lw r1, r7, 0            #r1 poppen
            addi r7, r7, 1
            
            jalr r5, r6             #zurück zur aufrufenden Instanz

######################################################################
#shift_l: r1 Shiftweite, r2 Wort, r3 Ergebnis
######################################################################

shift_l:    addi r7, r7, -1         #r1 pushen
            sw r1, r7, 0
            addi r7, r7, -1         #r2 pushen
            sw r2, r7, 0

            lui r3, 0              #lade r3 mit 0, sicherheitshalber 

            add r3, r3, r2          #addiere r3 mit r2
            
            bne r1, r0, shift_loop  #ist r1=0?
            bne r7, r0, stl_finish

shift_loop: add r3, r3, r3          #addiere r3 mit r3
            addi r1, r1, -1         #addiere r1 mit -1
            bne r1, r0, shift_loop  #ist r1 = 0?
            
stl_finish: lw r2, r7, 0            #r2 poppen
            addi r7, r7, 1
            lw r1, r7, 0            #r1 poppen
            addi r7, r7, 1
            
            jalr r5, r6             #zurück zur aufrufenden Instanz

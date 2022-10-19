######################################################################
#implementierte Unterprogramme:
#       -MUL via add    (call MULv2)
#       -bitweise MUL   (call MULv3)
#       -shift_l        (call shift_l) 
######################################################################

#initialisiere Stack

            lw r7, r0, Stack_adr   #Stack Adresse in r7 laden, startet bei 7FFF
            lui r1, 0              #ffff in r1 laden
            addi r1, r1, -1
            sw r1, r7, 0           #stack Beginn markieren
            sw r1, r7, -64         #stack Ende markieren
            lui r1, 0              #r1 aufräumen
            bne r7, r0, Start      #übergehe die .fill
        
Stack_adr:  .fill 32767
debug_counter: .fill 0

              
Start:      lui r1, 0



##call MULv2: r3 = r1 * r2
#            addi r1, r1, 4
#            addi r2, r2, 4
#            
#            movi r5, MULv2
#            jalr r6, r5
#            
#            lui r1, 0
#            lui r2, 0
#          


#call MULv3: r3 = r1 * r2
            addi r1, r1, 1
            addi r2, r2, 2
            
#halt #debug
            movi r5, MULv3
            jalr r6, r5
            
           # lui r1, -1
            #lui r2, -1
            
            
##call shift_l: r3 = r2 r1 mal geshiftet
#            addi r1, r1, 3
#            addi r2, r2, 3
#            
#            movi r5, shift_l
#            jalr r6, r5
        
                
            

            
        halt
        
######################################################################
#Unterprogramme:
#MULv2:     MUL via add
#   Verwendung: r3 = r1 * r2
######################################################################

MULv2:      addi r7, r7, -1         #SP pushen
            sw r7, r7, 0
            addi r7, r7, -1         #r1 pushen
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
            lw r7, r7, 0            #SP poppen
            addi r7, r7, 1
            
            jalr r5, r6             #zurück zur aufrufenden Instanz

            
######################################################################
#MULv3:     bitweise MUL
#   Verwendung: r3 = r1 * r2
######################################################################
#addi r7, r7, -1         #SP pushen, rausgenaommen, weils das decrementieren des SP und dann sich selbst pushen Probleme machen könnte
#sw r7, r7, 0

MULv3:      addi r7, r7, -1         #r1 pushen
            sw r1, r7, 0
            addi r7, r7, -1         #r2 pushen
            sw r2, r7, 0
            
#Doppel "-" Erkennung und richtige Register config. (wenn 1x "-" und 1x "+" dann r1 = "-"; r2="+")
            lui r3, 32768           #lade Maske für MSB in r3
            nand r3, r1, r3         #maskiere r1
            nand r3, r3, r3
            
            bne r3, r0, MULv3_inv1   #wenn MSB gesetzt ist branche
            
            lui r3, 32768           #lade Maske für MSB in r3
            nand r3, r2, r3         #maskiere r2
            nand r3, r3, r3
            
            bne r3, r0, MULv3_swap   #wenn MSB gesetzt ist branche
            
            bne r7, r0 MULv3_start  #sonst leg los
            
MULv3_swap: lui r3, 0               #tausche die Inhalte von r1 und r2
            add r3, r3, r1
            lui r1, 0
            add r1, r1, r2
            lui r2, 0
            add r2, r2, r3
           
            
            bne r7, r0 MULv3_start  #leg los
            
MULv3_inv1: lui r3, 32768           #lade Maske für MSB in r3
            nand r3, r2, r3         #maskiere r2
            nand r3, r3, r3
            
            bne r3, r0, MULv3_inv2  #wenn MSB gesetzt ist gehe weiter
            bne r7, r0 MULv3_start  #sonst leg los
            
#ZK umwandlung rückgängig machen
MULv3_inv2: addi r1, r1, -1         #r1 - 1
            addi r2, r2, -1         #r2 - 1
            nand r1, r1, r1         #r1 invertieren
            nand r2, r2, r2         #r2 invertieren
            
            
  #halt #debug

MULv3_start: lui r3, 0               #lade r3 mit 0, sicherheitshalber    
            lui r4, 0               #r4 nullen
            addi r4, r4, 8          #r4 mit bitbreite laden
          
MULv3_loop: addi r4, r4, -1         #r4 dekrementieren

lw r5, r0, debug_counter
addi r5, r5, 1
sw r5, r0, debug_counter
#addi r5, r5, -3
#bne r5, r0, debug_weiter
#halt
#halt #debug            
#Maske generieren:
debug_weiter:            addi r7, r7, -1         #r1 pushen
            sw r1, r7, 0
            addi r7, r7, -1         #r2 pushen
            sw r2, r7, 0
            addi r7, r7, -1         #r3 pushen
            sw r3, r7, 0
           
            lui r1, 0               #r1 nullen
            add r1, r1, r4          #r1 = r4; das ist shiftweite
            
            lui r2, 0           
            addi r2, r2, 1          #r2 mit "1" laden
           
            addi r7, r7, -1         #Rücksprungadresse pushen
            sw r6, r7, 0
            movi r5, shift_l        #call shift_l
            jalr r6, r5             #danach ist Maske in r3
            lw r6, r7, 0            #Rücksprungadresse poppen
            addi r7, r7, 1
             
#Maskieren:
            lw r2, r7, 1            #r2 poppen
            nand r3, r3, r2         #maskierung via nand
            nand r3, r3, r3         #negieren
#halt #debug
#ist r4 tes bit null?
            bne r3, r0, MULv3_go    #if(r3 != 0) goto MULv3_go;
            #register aufräumen!
            lw r3, r7, 0            #r3 poppen
            addi r7, r7, 1
            lw r2, r7, 0            #r2 poppen
            addi r7, r7, 1
            lw r1, r7, 0            #r1 poppen
            addi r7, r7, 1
            
#halt #debug
#Ende erreicht?
MULv3_back: bne r4, r0, MULv3_loop  #wenn nein, fang von vorn an!
#halt #debug 
            bne r7, r0, MULv3_finish #fertig!
            
            
#links schiebe Operation:
MULv3_go:   lui r1, 0
            add r1, r1, r4          #r1 = r4
            lw r2, r7, 2            #r1 poppen

            addi r7, r7, -1         #Rücksprungadresse pushen
            sw r6, r7, 0
            movi r5, shift_l        #call shift_l
            jalr r6, r5             #Ergebnis in r3
            lw r6, r7, 0            #Rücksprungadresse poppen
            addi r7, r7, 1
#halt #debug             
#Addition durchführen:
            lui r1, 0
            add r1, r1, r3          #r1 = r3; geshiftetes Ergebnis sichern
            
            lw r3, r7, 0            #r3 poppen
            addi r7, r7, 1
            
            add r3, r3 ,r1          #addition durchführen

            lw r2, r7, 0            #r2 poppen
            addi r7, r7, 1
            lw r1, r7, 0            #r1 poppen
            addi r7, r7, 1          #SP + 1, weil r1 auch gepusht war => hole r1 doch raus!
 #halt #debug           
            bne r7, r0, MULv3_back  #goto MULv3_back

            
            
            
            
#halt #debug
            
            
MULv3_finish: lw r2, r7, 0            #r2 poppen
            addi r7, r7, 1
            lw r1, r7, 0            #r1 poppen
            addi r7, r7, 1
            #lw r7, r7, 0            #SP poppen
            #addi r7, r7, 1
#lui r6, 0 #debug
#addi r6 r6, 14 #debug
#halt #debug            
            jalr r5, r6             #zurück zur aufrufenden Instanz            
            
######################################################################
#shift_l: r1 Shiftweite, r2 Wort, r3 Ergebnis
######################################################################
#addi r7, r7, -1         #SP pushen, siehe MULv3
            #sw r7, r7, 0
            
            
shift_l:    addi r7, r7, -1         #r1 pushen
            sw r1, r7, 0
            addi r7, r7, -1         #r2 pushen
            sw r2, r7, 0

            lui r3, 0              #lade r3 mit 0, sicherheitshalber 

            add r3, r3, r2          #addiere r3 mit r2
            
            #bne r1, r0, shift_loop  #ist r1=0?
            #bne r7, r0, stl_finish

shift_loop: add r3, r3, r3          #addiere r3 mit r3
            addi r1, r1, -1         #addiere r1 mit -1
            bne r1, r0, shift_loop  #ist r1 = 0?
          
            
stl_finish: lw r2, r7, 0            #r2 poppen
            addi r7, r7, 1
            lw r1, r7, 0            #r1 poppen
            addi r7, r7, 1
            #lw r7, r7, 0            #SP poppen
            #addi r7, r7, 1
            
            jalr r5, r6             #zurück zur aufrufenden Instanz

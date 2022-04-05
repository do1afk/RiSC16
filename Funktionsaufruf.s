##################################################################
#Funktionsaufruf:
#Definiere r5, r6 für Programmaufrufe
#1. hole Adresse von call in r1:
#       movi r5, call 
#2. springe zu Adresse in r1, speichere Rücksprungadresse in r2:
#       jalr r6, r5
#3. spring wieder zurück: (Hier ist die Rücksprungadresse (r5) unwichtig)
#       jalr r5, r6
#################################################################

             lw r1, r0, n           #1 in r1
             lw r2, r0, a           #2 in r2
             
             movi r3, call          #lade adresse von call in r3
             jalr r4, r3            #springe zu call, speichere PC+1 in r4   
             lw r2, r0, b           #3 in r2
             halt
             
             
call:       lw r1, r0, b         #lade 3 in r1
            jalr r7, r4          #springe zurück, speichere PC+ in r7
                                 #die beiden register dürfen nicht gleich sein!
                                 #PC+1 nicht nach r0 schreiben!
            


       
n:          .fill 1                            
a:          .fill 2
b:          .fill 3
null:       .fill 0

        

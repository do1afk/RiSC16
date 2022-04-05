##################################################################
#Test für Stapelspeicher:
# -Definiere SP als r7
# -push:
#           addi r7, r7, 1           #SP erhöhen, damit SP immer auf letztes Ereignis zeigt
#           sw  r1, r7, Stack        #r1 weg pushen, r1 ist dabei variabel
#           
# -pop:
#           lw r3, r7, Stack         #in r3 poppen, r3 ist dabei variabel
#           addi r7, r7, -1           #SP erniedrigen, damit SP immer auf letztes Ereignis zeigt
##################################################################

              lw r1, r0, n           #1 in r1
              lw r2, r1, n           #2 in r2, über Adresse von n+1
              lw r3, r0, b           #3 in r3 laden
#             
##zum ausprobieren, wie weit die Adressen auseinander liegen:
#             movi r6, n
#             movi r7, a
##ausprobieren, wie ich auf den Stack pushen poppen kann:
#             
#             sw r2, r1, Stack       #schiebe 2 auf Stack+1 
#             lw r1, r0, a           #hole 2 in r1
#             sw r2, r1, Stack       #schiebe 2 auf Stack+2
#             lw r4, r1, Stack       #hole 2 aus Stack+2
#             

#############################################################
#teste einen Programmaufruf mit Stack

#1. alle Register auf den Stack pushen:
             addi r7, r7, 1
             sw r1, r7, Stack
             addi r7, r7, 1
             sw r2, r7, Stack
             addi r7, r7, 1
             sw r3, r7, Stack
             addi r7, r7, 1
             sw r4, r7, Stack
             addi r7, r7, 1
             sw r5, r7, Stack
             addi r7, r7, 1
             sw r6, r7, Stack
             addi r7, r7, 1
             sw r7, r7, Stack
             
#2. Springe zum Unterprogramm:
            movi r5, call
            jalr r6, r5
            

 

            
            
             halt
#iwas tun...             
call:       add r4, r1, r2  
            jalr r5, r6


#Variablen:       
n:          .fill 1                            
a:          .fill 2
b:          .fill 3
null:       .fill 0

#Stack beginn:
Stack:      .fill 65535         #Stack beginnt mit ffff

        

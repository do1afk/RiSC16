##################################################################
#Übergabekonvention:
# -Maske (n) in r1
# -zu maskierendes Wort (a) in r2
# -Ergebnis wird in r3 zurück gegeben
#Masken: ntes Bit Maskieren => n = 2^n 
#0tes Bit = 2^0 = 1 => n € {1,2,4,8,16,... } 
#################################################################

#Vorbereitung:
             lw r1, r0, n           #Maske in r1
             lw r2, r0, a           #Wort in r2
#Maskieren:
             nand r3, r1, r2        #Wort maskieren => gibt invertiertes Ergebnis zurück
             nand r3, r3, r3        #Ergebnis invertieren
             halt

       
n:          .fill 8                            
a:          .fill 11
null:       .fill 0

        

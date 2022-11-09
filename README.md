# Projektarbeit RiSC16 - Arndt Karger (Technische Hochschule Mittelhessen)
## Systemroutinen für einen RiSC16-Prozessor
<br>

- __Ziel:__ 
> Das Erstellen von Systemroutinen zum Testen einer neu entwickelten Hardwareimplementierung. <br>

- __Dateistruktur:__ 
> /Dokumentation: <br>
       >> Dokumentation der Projektarbeit und Tex-Quellcode <br>
> /Testprogramme: <br>
       >> Testfiles zum Testen des Assemblers und Simulators ('fibonacci.s' aus https://user.eng.umd.edu/~blj/RiSC/ [zuletzt besucht 09.11.2022]) <br>
> RiSC16SIM_Arndt.c: Von Herrn Prof. Dr.-Ing. W. Bonath entwickelter Simulator mit neuen Debug-Funktionen <br>
> Routinen.s: In der Projektarbeit erstellter Quellcode

- __Bedienungshilfe:__ 
        
> __Registerverwendung:__

>> • r1: zur Wertübergabe, nach Unterprogrammaufruf unverändert <br>
>> • r2: zur Wertübergabe, nach Unterprogrammaufruf unverändert<br>
>> • r3: Ergebnisregister<br>
>> • r4: Zählregister innerhalb von Funktionen<br>
>> • r5: don’t-care<br>
>> • r6: Rücksprungadressen<br>
>> • r7: Stackpointer<br>


> __Funktionsaufruf:__ Definiere r5, r6 für Programmaufrufe   <br>
>> 1. Adresse von Unterprogramm in r5 laden:   <br> _movi r5, Unterprogramm_    <br>
>> 2. Zur Adresse in r5 springen, Rücksprungadresse in r6 speichern: <br> _jalr r6, r5_   <br>
>> 3. zurückspringen: (Hier ist die Rücksprungadresse (r5) unwichtig)  <br> _jalr r5, r6_   <br>


> __Stack:__ Definiere SP als r7  <br>
>> • push:      <br>
    _addi r7, r7, -1_ (SP dekrementieren)  <br>
    _sw r1, r7, 0_ (r1 pushen)             <br>
>> • pop:<br>
    _lw r3, r7, 0_ (in r3 poppen)   <br>
    _addi r7, r7, 1_ (SP inkrementieren, damit SP immer auf letztes Ereignis zeigt)   <br>

> __shift l:__       <br>
   >> • shiftweite (n) in r1, zu shiftendes Wort (a) in r2      <br>
   >> • Ergebnis wird in r3 zurückgegeben          <br>


> __MULv2:__ (MUL via add)   <br>
>> • Multiplikator in r1, Multiplikant in r2   <br>
>> • Ergebnis wird in r3 zurückgegeben     <br>


> __MULv3:__ (bitweise MUL)                   <br>
>>• Multiplikant in r1, Multiplikator in r2   <br>
>>• Ergebnis wird in r3 zurückgegeben       <br>


        
        
        



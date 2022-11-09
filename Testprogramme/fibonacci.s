# fibonacci.s
# berechne fibonacci folge f(i) = f(i-1) + f(i-2)
# r1 i
# r2 f(i-2)
# r3 f(i-1)
# r4 f(i)
# r5 imax  
#
#
	addi r1 r0 2    # zuerst das dritte glied berechnen
	addi r2 r0 1    # f(1) = 1
	addi r3 r0 1    # f(2) = 1
	addi r5 r0 10   # i_max
loop:	addi r1 r1 1
	add r4 r3 r2
	add r2 r3 r0    r3 -> r2
	add r3 r4 r0    r3 -> r2
	bne r1 r5 loop
	halt 

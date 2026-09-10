// This file implements and tests the bubble sort algorithm in ascending order // for ten values stored in memory assuming a non-leaf routine (preserve lr)

.text
.global main

main:
	ldr sp,=0xfffffffc
	ldr r1,=ARRAY_BASE   // load addr where data is
	mov r2,#10			// load N
	bl bubble_sort		// call routine
here:
	b here				// infinite loop


bubble_sort:
	push    {r4-r9,lr}	// preserve reg incluiding lr due to non-leaf
	sub r9,r2,#1		// r9 = N-1
	lsl r8,r9,#2        // r8 = (N-1) x 4
loop:
	mov r4,#0			// rst i index
	mov r5,#4			// rst j index
loop1:
	ldr r6,[r1,r4]		// r6 = array[i] 
	ldr r7,[r1,r5]		// r7 = array[j]
	cmp r6,r7		// r6 > r7 ?
	strlt r6,[r1,r5]	// no array[j] = r6
	strlt r7,[r1,r4]	// no array[i] = r7
	add r4,r4,#4		// i = i + 4
	add r5,r5,#4		// j = j + 4
	cmp r8,r5               // scan all elements of array?
	bge loop1		// no - loop again
	subs r9,r9,#1           // scans = scans -1
	bpl loop                // scans >= 0 ? then scan again
	pop {r4-r9,lr}          // restore registers
	mov pc,lr               // return to main program

.ltorg
ARRAY_BASE:
	.word  5, 3, 4, 0, 1, 7, 2, 6, 9, 8






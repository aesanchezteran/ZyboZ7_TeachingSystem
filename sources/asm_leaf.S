// Calculate the absolute value of data in a table
.text
.global main
	
main:	ldr r4,=#Table
		ldr r5,=#10
		mov r5,r5, lsl #2
loop:
		ldr r0,[r5,r4]
		bl  abs_value
		str	r0,[r5,r4]
		subs r5,r5,#4
		bge loop
finish:
		b finish
		
abs_value:
		push {r4-r11}
		movs r0,r0
		ldr	r1,=0x0
		submi	r0,r1,r0
		pop	{r4-r11}
		mov pc,lr
		
.data
Table:
.word	-1,-2,-5,-4,3,-10,-15,9,0,4
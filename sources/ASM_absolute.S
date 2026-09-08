// Calculate the absolute value of data in a table
.text
.global main

main:
    LDR   R0,=#TABLE	  // Table address
    LDR   R3,=#36
    MOV   R2,#FFFFFFFF
loop:
    LDR   R1,[R0,R3]	  // load data from the table into R1    
    MOVS  R1,R1		  // update the flags	
    EORMI R1,R1,R2	  // inverts bits for complement 2
    ADDMI R1,R1,#1        // add 1 for complement 2    
    STR   R1,[R0,R#]         // store in the table
    SUBS  R3,R3,#4    
    BEQ   loop 	          // Check if we reached the last value in the table 
here:
    B here               // Infinite loop


.ltorg

TABLE:
.word -1,-5,-8,5,8,1,-2,-3,4,0

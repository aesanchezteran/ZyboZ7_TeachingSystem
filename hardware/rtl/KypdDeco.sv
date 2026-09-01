`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alberto Sánchez
// 
// Create Date: 17.04.2023 12:47:52
// Design Name: 
// Module Name: decosource
// Project Name: keypad deco
// Target Devices: Zybo, Z-10, Z-20
// Tool Versions: 2022.1
// Description: This code implements a keypad decoder which is instantiated in a 
// Verilog wrapper so it can be inserted as a RTL module in a block design. 
// The system scans the columns of a hex keypad and reads the rows. Rows are synchronized.
// The system outputs a 5-bit key decoding the keys and no-pressed key.
//
//
//  1     2     3     A ---- row 1 (Pmod Pin 10)
//  4     5     6     B ---- row 2 (Pmod Pin 9)
//  7     8     9     C ---- row 3 (Pmod Pin 8)
//  0     F     E     D ---- row 4 (Pmod Pin 7)
//  |     |     |     |
// col 1 col 2 col 3 col 4
//(Pin4) (Pin3)(Pin2)(Pin1)
//
// Dependencies: 
//  
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module scaningfsm( input logic clk,
                    input logic rstn,
                    input logic strb,
                    input logic [3:0] rows,
                    output logic [3:0] cols,
                    output logic [3:0] state,
                    output logic valid);

/********************************************************************
*                               Scaning FSM                        *
*********************************************************************/                   
 
         // state definitions
         typedef enum logic [3:0] {S0,S1,S2,S3,S4,S5,S6,S7,S8} statetype;
         statetype instate, nextstate;
 
                    // state register
                    always_ff @(posedge clk)
                        if(~rstn) instate <= S0;
                        else if(strb) instate <= nextstate;
                        
                    //next state logic
                    always_comb 
                        case(instate)
                            S0: if(&rows)   nextstate = S0;
                                else        nextstate = S1;
                            S1: if(&rows)   nextstate = S2;
                                else        nextstate = S5;                 
                            S2: if(&rows)   nextstate = S3;
                                else        nextstate = S6;
                            S3: if(&rows)   nextstate = S4;
                                else        nextstate = S7;                        
                            S4: if(&rows)   nextstate = S0;
                                else        nextstate = S8;
                            S5: if(&rows)   nextstate = S0;
                                else        nextstate = S5;
                            S6: if(&rows)   nextstate = S0;
                                else        nextstate = S6;
                            S7: if(&rows)   nextstate = S0;
                                else        nextstate = S7;                                
                            S8: if(&rows)   nextstate = S0;
                                else        nextstate = S8;                                
                            default:        nextstate = S0;
                            endcase
                            
                    // output logic
                    always_comb
                        case(instate)
                            S0: begin cols = 4'h0; valid = 1'b0; end
                            S1: begin cols = 4'he; valid = 1'b0; end
                            S2: begin cols = 4'hd; valid = 1'b0; end
                            S3: begin cols = 4'hb; valid = 1'b0; end
                            S4: begin cols = 4'h7; valid = 1'b0; end
                            S5: begin cols = 4'he; valid = 1'b1; end
                            S6: begin cols = 4'hd; valid = 1'b1; end
                            S7: begin cols = 4'hb; valid = 1'b1; end
                            S8: begin cols = 4'h7; valid = 1'b1; end                            
                            default: begin cols = 4'h0; valid = 1'b0; end
                        endcase
      
/********************************************************************
*                             END --  Scanning FSM                  *
*********************************************************************/    
                        assign state = instate;
endmodule



module decoder( input logic valid,
                input logic [3:0] rows, cols,
                output logic [4:0] key);
/********************************************************************
*                               Key Decoder                         *
*********************************************************************/ 
                   always_comb
                    if(valid)
                          case({cols,rows})
                            8'he7:	key = 5'b00000; //0
                            8'heb:	key = 5'b00111; //7
                            8'hed:	key = 5'b00100; //4
                            8'hee:	key = 5'b00001; //1
                            8'hd7:	key = 5'b01111; //f
                            8'hdb:	key = 5'b01000; //8
                            8'hdd:	key = 5'b00101; //5
                            8'hde:	key = 5'b00010; //2
                            8'hb7:	key = 5'b01110; //e
                            8'hbb:	key = 5'b01001; //9
                            8'hbd:	key = 5'b00110; //6
                            8'hbe:	key = 5'b00011; //3
                            8'h77:	key = 5'b01101; //d
                            8'h7b:	key = 5'b01100; //c
                            8'h7d:	key = 5'b01011; //b
                            8'h7e:	key = 5'b01010; //a
                            default: key = 5'b10000;
                          endcase
                    else key = 5'b10000;
                    

/********************************************************************
*                           END -- Key Decoder                      *
*********************************************************************/ 
endmodule


module freqdiv #(parameter step=8192) (input logic clk, 
                                       input logic rstn,
                                       output logic strb);
/********************************************************************
*                               Frequency Divider                   *
*  step MUST be a power of 2 otherwise the overflow                 *
*  will not work.
*  clk @ 50 MHz
*  strb
*                                                                    *            
*********************************************************************/ 
    logic [31:0] count;

    //100Hz clock strobe/enable
    always_ff @(posedge clk)
        if(~rstn) {strb,count} <= 0;
        else {strb,count} <= count+step;
            
endmodule

/********************************************************************
*                               Synchonizer                         *
*********************************************************************/ 

module synchronizer(input logic clk,
                    input logic rstn,
                    input logic strb,
                     input logic [3:0] row_in,
                     output logic [3:0] sync_row);
         
         logic [3:0] temp_row;
         
         always_ff @(posedge clk)
            begin
            if(~rstn)
                begin
                    temp_row <= 0;
                    sync_row <= 0;
                end
            else if(strb)
                begin
                    temp_row <= row_in;
                    sync_row <= temp_row;
                end
            end

endmodule

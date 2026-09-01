`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USFQ
// Engineer: Alberto Sánchez
// 
// Create Date: 13.04.2023 08:52:52
// Design Name: keypad decoder
// Module Name: keypad_deco
// Project Name: Lab #4
// Target Devices: Zybo, Z-10, Z-20
// Tool Versions: 2022.1
// Description: This implements a hex 4 by 4 keypad decoder
// This is a verilog wrapper of a SystemVerilog code to scan the keypad
// The wrapper allows to insert the SV code in block design and interface
// with AXI GPIO  
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module keypad_deco(
    input clk,
    input rstn,
    input [3:0] rows,
    output [3:0] cols,
    
    output [3:0] sync_rows,
    output [3:0] state,
    output valid,
    
    // GPIO Interface definition for the output key
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 gpio_key TRI_O" *) 
    output [4:0] key,
    
    output strb
);
    
    freqdiv freqdiv_1(
        .clk(clk),
        .rstn(rstn),
        .strb(strb)
    );
    
    synchronizer synchronizer_1(
        .clk(clk),
        .rstn(rstn),
        .strb(1'b1),
        .row_in(rows),
        .sync_row(sync_rows)
    );
    
    scaningfsm scaningfsm_1(
        .clk(clk),
        .rstn(rstn),
        .strb(strb),
        .rows(sync_rows),
        .cols(cols),
        .state(state),
        .valid(valid)
    );
    
    decoder decoder_1(
        .valid(valid),
        .rows(sync_rows),
        .cols(cols),
        .key(key)
    );   

endmodule




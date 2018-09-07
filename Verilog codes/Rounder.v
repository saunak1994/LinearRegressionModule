`timescale 1ns/100ps
module Rounder(
    input [7:0] X,
    input [31:0] num,
    input [31:0] den,
    output reg [7:0] nA
    );
    
    reg [31:0] remainder,halfden;
    
    always@(*) begin
    remainder=num-(den*X);
    halfden=(den>>1);
  end
  
    always@(*) begin
    if(remainder>halfden)nA<=X+1;
    else nA<=X;
  end
  
    
endmodule
    

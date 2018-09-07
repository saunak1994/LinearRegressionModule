`timescale 1ns/100ps
module UpCounter(					                     //Upcounter for READY-Logic
out,  
enable,  
clk,  
reset     
);

output reg [15:0] out;
input enable,reset,clk;


always @(posedge clk)
if (reset) begin
  out <= 8'b0 ;
end 
else if (enable) begin
  out <= out + 1;
end
endmodule

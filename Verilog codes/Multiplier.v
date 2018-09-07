`timescale 1ns/100ps
module Multiplier(
  input [7:0] n1,
  input [7:0] n2,
  input select1,
  input select2,
  output reg [15:0] out
  );
  
  reg[7:0] x,y;
  
  always @(*) begin
  if(select1==1 && select2==0) begin
  x=n1;
  y=n2;
end

  else if(select2==1 && select1==0) begin
  x=n1;
  y=n1;
  end
end

  
  always @(*) begin 
    out=x*y;
  end
  
endmodule



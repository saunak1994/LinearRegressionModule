`timescale 1ns/100ps
`define INFILE1    "data/input_3_binary"
`define INFILE2    "data/output_3_binary"
`define IN_LENGTH  60
`define OUT_LENGTH 6
 
module lrm_tb;
parameter period = 20;

reg clk;
reg rst_hi;
reg predict;
reg [7:0] xi;
reg [7:0] yi;
wire ready;
wire done;
wire [7:0] yp;
wire [7:0] out_a;
wire [7:0] out_b;

integer i, k, l, err, cnt, total_cycle_num;
reg [16:0] data_base [0:`IN_LENGTH - 1];
reg [23:0] data_base_expect [0:`OUT_LENGTH - 1];
reg [16:0] data_tmp_i;
reg [23:0] data_tmp_expect;

initial	$readmemb(`INFILE1, data_base);
initial	$readmemb(`INFILE2, data_base_expect);

initial clk = 1'b0;
always #(period/2) clk = ~clk;

initial begin
  i = 0;
  k = 0;
  l = 0;
  err = 0;
  cnt = 0;
end

initial begin
  rst_hi = 1'b1;
  #(period)
  rst_hi = 1'b0;
   
  $display ("\n****** START to VERIFY the Linear Regresssion Module OPERATION ******");
  for(i = 0; i < `IN_LENGTH; i = i + k) begin
    @(negedge clk)
      if(ready == 1'b1) begin
        data_tmp_i = data_base[i];
        xi = data_tmp_i[16:9];
        yi = data_tmp_i[8:1];
        predict = data_tmp_i[0];
        if (predict == 1'b0) begin
          cnt = cnt + 1;
        end
        k = 1;
        $display("<Xi,Yi,PREDICT> = <%d,%d,%d>",xi,yi,predict); 
      end else begin
        xi = 8'bz;
        yi = 8'bz;
        predict = 1'bz;
        k = 0;
      end
  end
end  

always @(posedge clk) begin
    #(period*0.1)
    if (done == 1'b1) begin
      data_tmp_expect = data_base_expect[l]; 
      if (cnt < 2) begin
        if (yp !== data_tmp_expect[23:16]) begin
          $display("ERROR at %d: Yp=%d != expect Yp=%d (A and B are don't care so far)",
            l, yp, data_tmp_expect[23:16]);
           err = err + 1 ;   
        end
      end else begin
        if ((yp !== data_tmp_expect[23:16]) ||
            (out_a !== data_tmp_expect[15:8]) || 
            (out_b !== data_tmp_expect[7:0])) begin

          $display("ERROR at %d: Yp=%d A=%d B=%d != expect Yp=%d A=%d B=%d",
            l, yp, out_a, out_b, data_tmp_expect[23:16], data_tmp_expect[15:8], data_tmp_expect[7:0]);
           err = err + 1 ;   
        end
      end
      l = l + 1;
    end
    
    if( l == `OUT_LENGTH ) begin
      if (err == 0)
         $display("PASS! All results are correct!");
      else begin
         $display("---------------------------------------------");
         $display("There are %d errors!", err);
         $display("---------------------------------------------");
      end
      $display("---------------------------------------------");
      $display("Total number of cycles: %d", total_cycle_num);
      $display("---------------------------------------------");
      $finish;
    end
end

always @(posedge clk) begin
   if (rst_hi == 1'b1) 
      total_cycle_num = 0 ;
   else 
      total_cycle_num = total_cycle_num + 1 ;
end 

lrm lrm_0 (
  .CLK(clk),
  .RESET(rst_hi),
  .PREDICT(predict),
  .Yi(yi),
  .Xi(xi),
  .READY(ready),
  .DONE(done),
  .Yp(yp),
  .A(out_a),
  .B(out_b)
);

endmodule

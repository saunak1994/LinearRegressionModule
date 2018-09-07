`timescale 1ns/100ps
module lrm(
	input RESET,
	input [7:0] Xi,
	input [7:0] Yi,
	input CLK,
	input PREDICT,
	output reg READY,
	output reg DONE,
	output reg [7:0] A,
	output reg [7:0] B,
	output reg [7:0] Yp	
);


reg [31:0] N,N1;
reg [7:0] n1,n2;
reg nzero,nfirst;
reg [31:0] EXY,EX,EY,EXsq;
wire [15:0] out1;
wire [15:0] product1;
reg [15:0] O1;
reg [7:0] X,Y;
reg EN;
reg [7:0] nA,nB,nYp;
wire [7:0] An,Bn;
reg [31:0] num,num2,den,den2;
reg [31:0] GatedNumerator,GatedNumerator2,GatedDenominator,GatedDenominator2;
reg [31:0] rem,halfden,rem2,halfden2;



always @(*) begin		                      						//Enable for upcounter in READY Logic
	EN<=(~RESET);  
	end

    
always @(posedge CLK) begin		            						//Sampling inputs at clock edge
	if(RESET) begin
		n1<=0;
		n2<=0;
		
	end
	else if (~PREDICT && READY) begin
		n1<=Xi;
		n2<=Yi;
	end
end 


always @(posedge CLK) begin 
  if(RESET) N1<=0;             									//Last edge versions of N: to detect change in N
else N1<=N;
end


always @(posedge CLK) begin		            						//Logic for calculating coefficients
	if(RESET) begin	
		EXY<=0;
		EX<=0;
		EY<=0;
		EXsq<=0;
	end
	else if(N1!==N)begin
	  if(nzero) begin
		EXY<=EXY+product1;               
		EX<=EX+(n1);
		EY<=EY+(n2);
		EXsq<=EXsq;
		end
	end
		
	else if(nfirst) begin
		EXsq<=EXsq+product1;								//'product1' used to compute both n1*n1 and n1*n2: Hardware reuse performed for Area optimization
	end
end




always @(posedge CLK) begin                     						//Following three always block generate control logic for MUX select in HW reuse
  if(RESET) nzero<=0;
  else if(READY && ~PREDICT) nzero<=1;
  else nzero<=0;
  end
always @(posedge CLK) begin
  nfirst<=nzero;
end





Multiplier M1(.n1(n1),.n2(n2),.select1(nzero),.select2(nfirst),.out(product1));		//Multiplier module: Calculates simple product



  

    

always @(posedge CLK) begin		             						//DONE Logic
	if(RESET) DONE<=0;
	else if(PREDICT) DONE<=1;
	else DONE<=0;
end


UpCounter Count1(.out(out1),.enable(EN),.clk(CLK),.reset(RESET));				//16 bit Up counter: put any value after modulus (%) to flexibly change the frequency of READY signal	
always @(*) begin
  O1<=out1%4;
end

	                                       
	                                       
always @(posedge CLK) begin		             						//READY Logic 	
	if(O1==0)begin 
	 READY<=1;
	 end
	else READY<=0;
end


always @(posedge CLK) begin				           				//Outputs A and B: Calculated from Dummy Outputs nA and nB
	if(PREDICT) begin
	  if(N==0 || N==1) begin
	    A<=0;
	    B<=0;
	  end
	  else begin
		A<=nA;
		B<=nB;
		end
		
	end
end


always @(posedge CLK) begin				            				//Outputs Yp: Calculated from Dummy outputs nYp
  if(PREDICT) begin
    if(N==0 || N==1) begin
      Yp<=nYp;
    end
  else begin
    Yp<=(nYp);
  end
end
end


Rounder R1(.X(X),.num(num),.den(den),.nA(An));							//Rounder: implements rounding logic. returns ceiling if fractional part >= 0.5 otherwise floor
Rounder R2(.X(Y),.num(num2),.den(den2),.nA(Bn));

always @(*) begin
  if(RESET)begin
    nA<=0;
    nB<=0;
  end
else begin
  nA<=An;
  nB<=Bn;
end
end

always @(*) begin 					                                         //Dummy Outputs for A and B
	if(RESET) begin
	num<=0;                                                                    
	den<=0;
	end
	else if(PREDICT) begin
	num<=((N*EXY)-(EX*EY));
	den<=((N*EXsq)-(EX*EX));
	X<=num/den;                            				                 //1 division 
	
	num2<=(den*EY)-(num*EX);	
	den2<=den*N;
	Y<=num2/den2;					                                          //1 division
	end
end

/*
always @(*) begin                                             //Clock Gating section: will disallow division when predict is not asserted and hence saves power.
  if (PREDICT) begin
    GatedNumerator <= num;
    GatedDenominator <= den;
    GatedNumerator2 <= num2;
    GatedDenominator2 <= den2;
  end
else begin
    GatedNumerator <= 0;
    GatedDenominator <= 0;
    GatedNumerator2 <= 0;
    GatedDenominator2 <= 0;
end
end
*/


always @(*) begin					                     			//Dummy Outputs for Yp
  if(RESET) begin
    nYp<=0;
  end
else if(N==0) begin
  nYp<=8'b10000000;
end
else if(N==1) begin
  nYp<=n2;
end
else begin
  nYp<=nA*Xi+nB;					                       			//Using rounded A and B values for Yp: NO division
  end
end



always @(posedge CLK) begin				             				//N-Logic
	if (RESET)N<=0;
	else if(READY && ~PREDICT) N<=N+1;
	else N<=N;
end

endmodule

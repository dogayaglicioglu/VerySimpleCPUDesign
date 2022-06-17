`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:48:02 05/09/2021 
// Design Name: 
// Module Name:    Vscpu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Vscpu(clk,rst,data_fromRam,wrEn,addr_toRam,data_toRam);
parameter SIZE = 14;

input clk,rst;
input wire[31:0] data_fromRam;
output reg wrEn;
output reg [SIZE-1:0] addr_toRam;
output reg [31:0] data_toRam;
reg[3:0] st, stN;
reg[SIZE-1:0] pc,pcN;
reg[31:0] iw,iwN;
reg[31:0] r1,r1_n,r2,r2_n;

always@(posedge clk)begin
	if(rst)begin
		st <= 0;
		pc <= 14'b0;
		iw <= 32'b0;
		r1 <= 32'b0;
		r2 <= 32'b0;
	end
	else begin
		st <= stN;
		pc <= pcN;
		iw <= iwN;
		r1 <= r1_n;
		r2 <= r2_n;
	end
end
always@(*)begin
	stN = st;
	pcN = pc;
	iwN = iw;
	r1_n = r1;
	r2_n = r2;
	wrEn = 0;
	addr_toRam = 0;
	data_toRam = 0;
	case(st)
		0:begin
			pcN = 0;
			iwN = 0;
			r1_n = 0;
			r2_n = 0;
			stN = 1;
		end
		1:begin
			addr_toRam = pc;
			stN = 2;
		end
		2:begin
			iwN = data_fromRam;
			case(data_fromRam[31:28])
				{3'b000,1'b0}:begin//ADD 
					addr_toRam = data_fromRam[27:14];//read *R1
					stN = 3;
				end
				{3'b000,1'b1}:begin//ADDi // direk(4. state'e atlýyor.)
					addr_toRam = data_fromRam[27:14];
					stN = 4;
				end
				{3'b100,1'b0}:begin//CP
					addr_toRam = data_fromRam[13:0];
					stN = 4;
				end
				{3'b110,1'b0}:begin//BZJ
					addr_toRam = data_fromRam[27:14];
					stN = 3;
				end
				{3'b110,1'b1}:begin//BZJi
					addr_toRam = data_fromRam[27:14];
					stN = 4;
				end
				
				{3'b001,1'b0}:begin//NAND
					addr_toRam = data_fromRam[27:14];
					stN = 3;
				end
				{3'b001,1'b0}:begin//NANDi
					addr_toRam = data_fromRam[27:14];
					stN = 4;
				end
				{3'b010,1'b0}:begin//SRL
					addr_toRam = data_fromRam[27:14];
					stN = 3;
				end
				{3'b010,1'b1}:begin//SRLi
					addr_toRam = data_fromRam[27:14];
					stN = 4;
				end
				{3'b011,1'b0}:begin//LT
					addr_toRam = data_fromRam[27:14];
					stN = 3;
				end
				{3'b011,1'b1}:begin//LTi
					addr_toRam = data_fromRam[27:14];
					stN = 4;
				end
				{3'b111,1'b0}:begin//MUL
					addr_toRam = data_fromRam[27:14];
					stN = 3;
				end
				{3'b111,1'b1}:begin//MULi
					addr_toRam = data_fromRam[27:14];
					stN = 4;
				end
				{3'b010,1'b0}:begin//CPi
					addr_toRam = data_fromRam[27:14];
					r1_n = data_fromRam[13:0];
					stN = 4;
				end
				{3'b101,1'b0}:begin//CPI
					addr_toRam = data_fromRam[13:0];
					addr_toRam = data_fromRam;
					stN = 4;
				end
				{3'b101,1'b1}:begin//CPIi
					addr_toRam = data_fromRam[27:14];
					stN = 3;
				end
				default:begin
					pcN = pc;
					stN = 1;
				end
			endcase
		end
		3:begin
			r1_n = data_fromRam;
			addr_toRam = iw[13:0];
			stN = 4;
		end
		4:begin
			case(iw[31:28])
				{3'b000,1'b0}:begin//ADD
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = data_fromRam + r1;
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b000,1'b0}:begin//ADDi
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = data_fromRam + iw[13:0];
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b100,1'b0}:begin//CP
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = data_fromRam;
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b100,1'b1}:begin//CPi
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = r1;
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b101,1'b1}:begin//CPIi
					wrEn = 1;
					addr_toRam = r1;
					data_toRam = data_fromRam;
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b110,1'b0}:begin//BZJ
					pcN = (data_fromRam == 0) ? r1 : (pc + 1'b1);
					stN = 1;
				end
				{3'b110,1'b1}:begin//BZJi
					pcN = iw[13:0] + data_fromRam;
					stN = 1;
				end
				{3'b101,1'b0}:begin//CPI
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = data_fromRam;
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b001,1'b0}:begin//NAND
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = ~(data_fromRam & r1);
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b001,1'b1}:begin//NANDi
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = ~(data_fromRam & iw[13:0]);
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b010,1'b0}:begin//SRL
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = (data_fromRam < 32) ? (r1 >> data_fromRam) : (r1 << (data_fromRam - 32));
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b010,1'b1}:begin//SRLi
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = (iw[13:0] < 32) ? (data_fromRam >> iw[13:0]) : (data_fromRam << (iw[13:0] - 32)); 
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b011,1'b0}:begin//LT
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = (r1 < data_fromRam) ? 1:0;
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b011,1'b1}:begin//LTi
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = (data_fromRam < iw[13:0] ? 1:0);
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b111,1'b0}:begin//MUL
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = data_fromRam * r1;
					pcN = pc + 1'b1;
					stN = 1;
				end
				{3'b111,1'b1}:begin//MULi
					wrEn = 1;
					addr_toRam = iw[27:14];
					data_toRam = data_fromRam * iw[13:0];
					pcN = pc + 1'b1;
					stN = 1;
				end
					
			endcase
		end
	endcase
end
endmodule

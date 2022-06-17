`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:29:36 05/09/2021 
// Design Name: 
// Module Name:    tb 
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
module tb;
parameter SIZE = 14, DEPTH = 1024;
reg clk;
initial begin
	clk = 1;
	forever
		#5 clk = -clk;
end
reg rst;
initial begin
	rst = 1;
	repeat(10)@(posedge clk);
	rst <= #1 0;
	repeat(600) @(posedge clk);
	$display("result: %d",inst_blram.memory[600]);
	$finish;
end
wire wrEn;
wire[SIZE-1:0] addr_toRam;
wire[31:0] data_toRam,data_fromRam;
Vscpu inst_0(clk,rst,data_fromRam,wrEn,addr_toRam,data_toRam);
blram #(SIZE,DEPTH)inst_blram(
	.clk(clk),
	.rst(rst),
	.i_we(wrEn),
	.i_addr(addr_toRam),
	.i_ram_data_i(data_toRam),
	.i_ram_data_o(data_fromRam)
);
endmodule

module blram(clk,rst,i_we,i_addr,i_ram_data_i,i_ram_data_o);
parameter SIZE = 10, DEPTH = 1024;
input clk;
input rst;
input i_we;
input[SIZE-1:0] i_addr;
input[31:0] i_ram_data_i;
output reg[31:0] i_ram_data_o;
reg[31:0] memory[0:DEPTH-1];
always@(posedge clk)begin
	i_ram_data_o <= #1 memory[i_addr[SIZE-1:0]];
	if(i_we)
		memory[i_addr[SIZE-1:0]] <= #1 i_ram_data_i;
end
initial begin
		blram.memory[0] = 32'h809601f4;
		blram.memory[1] = 32'h80078258;
		blram.memory[2] = 32'ha007c04f;
		blram.memory[3] = 32'h6007801f;
		blram.memory[4] = 32'hc008401e;
		blram.memory[5] = 32'ha096004f;
		blram.memory[6] = 32'h1013c001;
		blram.memory[7] = 32'h8007804f;
		blram.memory[8] = 32'h700781fe;
		blram.memory[9] = 32'hc008801e;
		blram.memory[10] = 32'hd0080001;
		blram.memory[11] = 32'h80960258;
		blram.memory[30] = 32'h0;
		blram.memory[31] = 32'h0;
		blram.memory[32] = 32'h0;
		blram.memory[33] = 32'h6;
		blram.memory[34] = 32'hb;
		blram.memory[79] = 32'h1f5;
		blram.memory[500] = 32'h8;
		blram.memory[501] = 32'hb;
		blram.memory[502] = 32'h7;
		blram.memory[503] = 32'h5;
		blram.memory[504] = 32'h11;
		blram.memory[505] = 32'h14;
		blram.memory[506] = 32'h17;
		blram.memory[507] = 32'hc;
		blram.memory[508] = 32'h2;
		blram.memory[509] = 32'h9;
		blram.memory[600] = 32'h0;
end
endmodule

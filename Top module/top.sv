`timescale 1ns/1ps
`include "parallel_interface.sv"
`include "fifo.sv"
`include "serial_interface.sv"

module top #( 	parameter datasize = 32,
		parameter addrbits = 8,
		parameter depth = 128)
		(input [datasize-1:0] parallel_data_in,
		input	req,	input	p_clk,	input	n_rst,	input	flush,	input	s_clk,
		output	grant,	output	full,	output	empty,	output	output_psi);
				


wire parallel_to_fifo,fifo_to_serial;
wire insert, pop;

//module instantiation

parallel_interface P1 (	.req(req), .parallel_data_in(parallel_data_in), .p_clk(p_clk), .n_rst(n_rst), 
			.grant(grant), .serial_data_out(parallel_to_fifo), .out_data(insert));

fifo #(addrbits, depth)  F1 (	.dataIn(parallel_to_fifo), .insert(insert), .rst(n_rst),
				.clk_in(p_clk), .flush(flush), .clk_out (s_clk), 
				.full(full), .empty(empty), .dataOut(fifo_to_serial), .remove(pop));

serial_interface S1 (	.datain(fifo_to_serial), .pop(pop), 
			.req(~empty), .s_clk(s_clk), 
			.rst_n(n_rst), .dataout(output_psi));
endmodule

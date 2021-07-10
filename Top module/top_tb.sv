`timescale 10ns/1ns

module top_tb();

wire out, full, empty, grant;
reg  flush, p_clk, rst, s_clk, req;
reg [31:0] parallel_data_in;

top T1( .output_psi(out), .full(full), .empty(empty), .grant(grant),  
	.flush(flush), .s_clk(s_clk), .p_clk(p_clk), .n_rst(rst),
	.req(req), .parallel_data_in(parallel_data_in));

always #2 p_clk = ~ p_clk;
always #4 s_clk = ~ s_clk;
 
initial begin

//$monitor ("datain = %b empty = %b insert = %b output = %b", datain, empty, insert, out);
p_clk = 0;
s_clk = 0;
//datain = 0;
flush = 0;
rst = 0;
#10
rst = 1;
flush = 1;
#40
flush = 0;
#10
req = 1;
#1;
parallel_data_in = 32'h11111111;
#100;
req = 0;
#140
req = 1;
parallel_data_in = 32'hffffffff;
//flush = 1;
//#10
//req = 1;
//#10
//parallel_data_in = 32'hffffffff;
//#80
//req = 0;
	
#500 $finish; 
end
//
/*
    req = 1;
    #1;
    parallel_data_in = 32'h11111111;
    #150;
    req = 0;
*/
//
// initial begin

// $dumpfile("top_vcd.vcd");
// $dumpvars(0, top);
// end

/*always @ (posedge clk_in) begin

	if (insert == 1) begin
		datain = ~ datain;
		//#2;
	end
end */

endmodule

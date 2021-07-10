`timescale 1ns/1ps
module parallel_interface_tb ();
		logic   p_clk; 
		logic   n_rst; 
		logic req; 
		logic [31:0] parallel_data_in; 
		wire  grant;
        	wire serial_data_out;
		wire out_data;
		
	parallel_interface p1(p_clk, n_rst, req, parallel_data_in, grant, serial_data_out, out_data);
  
	always #2 p_clk = ~p_clk;
	  
	initial 
	begin
		p_clk = 0;
		n_rst = 0;
		req = 0;
		parallel_data_in = 0;
		#5;
		n_rst = 1;
		#10;
		req = 1;
		#1;
		parallel_data_in = 32'h1111_1111;
		#75;
		req = 0;
		#10;
		req = 1;
		#1;
		parallel_data_in = 32'hffff_ffff;
		#75;
		req = 0;
		#150;
		$finish;
	  end
	  
	  initial begin
		$dumpfile("parallel_interface_vcd.vcd");
		$dumpvars();
	  end
	  
endmodule

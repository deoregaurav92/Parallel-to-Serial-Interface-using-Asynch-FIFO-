//testbench for 'serial_psi.sv'
`timescale 1ns/1ps

module serial_interface_tb();
logic clk_tb, rst_tb_n, output_tb, input_tb, request_tb, pop_tb;
logic [1:0] state;

serial_interface dut1 (
  .s_clk(clk_tb),
  .rst_n(rst_tb_n),
  .dataout(output_tb),
  .datain(input_tb),
  .req(request_tb),
  .pop(pop_tb), 
  .state(state)
);

initial
begin: clock_setup
  clk_tb = 0;
  forever #5 clk_tb = !clk_tb;
end: clock_setup

initial
begin: device_testing
  rst_tb_n = 1; input_tb = 0; request_tb = 0;
  #13 rst_tb_n = 0;
  #20 rst_tb_n = 1;
  #20 input_tb = 1; request_tb = 1;
  #10 input_tb = 0;
  #40 input_tb = 1;
  #50 input_tb = 0;
  #10 input_tb = 1;
  #10 request_tb = 0;
  #400 $finish;
end: device_testing

initial
begin: dump_variables
  $dumpfile("serial_interface_vcd.vcd");
  $dumpvars();
end: dump_variables

endmodule

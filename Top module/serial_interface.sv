//Serial module for the Parallel Serial Interface
`timescale 1ns/1ps

`define SOF 8'h5a
`define EOF 8'h0f

module serial_interface
	#(parameter data_width = 5)
	(	input logic 	datain, s_clk, rst_n, req,
		output logic 	dataout, pop);

//==== SIGNALS ====
// input logic s_clk, rst_n;
// the data to be obtained from the FIFO
// input logic datain;

// when the FIFO wants output data (i.e. whenever it is not empty), this signal should be high
// when a frame is finished, the FIFO should set this signal low
// input logic req;

// that data to be sent out of the serial interface
// output logic dataout;

//when there is a successful data sample, this signal is sent high to tell the FIFO to pop the current data
//the serial interface expects new data on the next clock cycle
// output logic pop;

logic nextdataout, inputSample, request;
enum logic [1:0] {IDLE=2'b00, START_T=2'b01, DATA_T=2'b11, END_T=2'b10} state, nextstate;

logic [2:0] delimcounter, nextdelimcounter;
logic [data_width - 1:0] datacounter, nextdatacounter;

//==== FUNCTIONS ====
function findDelim;
  input startDelimeter;
  input [2:0] incount;

  //delimeters are read msb first, so inverted enumeration
  logic [0:7] delimToSend;

  begin: finddelim_def
    if(startDelimeter)
      delimToSend = `SOF;
    else
      delimToSend = `EOF;

    findDelim = delimToSend[incount];
  end: finddelim_def
endfunction: findDelim

//==== ALWAYS BLOCKS ====
always_ff @(posedge s_clk or negedge rst_n)
begin: updateff
  if(rst_n) begin
    state 			<= nextstate;
    delimcounter 	<= nextdelimcounter;
    dataout 		<= nextdataout;
    inputSample 	<= datain;
    request 		<= req;
    datacounter 	<= nextdatacounter;
  end
  else begin
    state 			<= IDLE;
    delimcounter 	<= 0;
    dataout 		<= 0;
    inputSample		<= 0;
    request 		<= 0;
    datacounter 	<= 0;
  end
end: updateff

always_comb
begin: statemachine
  case(state)
    IDLE: begin
      pop = 0;
      nextdatacounter = 0;
      if(request) 
	  begin
        nextstate = START_T;
        nextdelimcounter = 1;
        nextdataout = findDelim(1, delimcounter);
      end
      else
	  begin
        nextstate = IDLE;
        nextdelimcounter = 0;
        nextdataout = 0;
      end
    end

    START_T: begin
      nextdataout = findDelim(1, delimcounter);
      nextdatacounter = 0;
      if(delimcounter < 7) begin
        nextstate = START_T;
        nextdelimcounter = delimcounter + 1;
        if (delimcounter > 4)
          pop = 1;
        else
          pop = 0;
      end
      else begin
        nextstate = DATA_T;
        nextdelimcounter = 0;
        pop = 1;
      end
    end

    DATA_T: begin
      if(datacounter < (2 ** data_width) - 1 ) begin
        nextstate = DATA_T;
        nextdelimcounter = 0;
        nextdataout = inputSample;
        nextdatacounter = datacounter + 1;
        if (datacounter > (2 ** data_width) - 3)
          pop = 0;
        else
          pop = 1;
      end
      else begin
        nextstate = END_T;
        nextdelimcounter = 0;
        nextdataout =  inputSample;
        pop = 0;
        nextdatacounter = 0;
      end
    end

    END_T: begin
      pop = 0;
      nextdatacounter = 0;
      nextdataout = findDelim(0, delimcounter);
      if(delimcounter < 7) begin
        nextdelimcounter = delimcounter + 1;
        nextstate = END_T;
      end
      else begin
        nextdelimcounter = 0;
        nextstate = IDLE;
      end
    end
  endcase
end: statemachine

endmodule //end serial_interface

`timescale 1ns/1ps
module parallel_interface (	input p_clk, input n_rst, input	logic req, 
							input	logic [31:0] parallel_data_in,
							output	logic  grant, 
							output	logic serial_data_out,
							output	logic out_data);

  	typedef enum {IDLE, TAKE_INPUT_DATA, SEND_SERIAL_OUTPUT} fsm;
    fsm cs, ns;
  
  	logic grant_temp, serial_data_out_temp;
  	int	  bit_counter_temp, bit_counter;
	logic [31:0] parallel_data_reg, parallel_data_reg_temp;
	logic out_data_temp ;
    //logic out_data = 0; 
  
  	assign serial_data_out = parallel_data_reg[0];
	assign out_data = out_data_temp;
    
	// current_state logic of FSM
	
  always_ff @(posedge p_clk, negedge n_rst) begin
        if(!n_rst) begin
            cs         			<=  IDLE;
            grant				<=	0;
            bit_counter			<= 0;
			parallel_data_reg	<= 0;
			//serial_data_out <= 0;
			//out_data_temp <= 0;
        end
        else begin
            cs          		<= ns;
          	grant				<= grant_temp;
            bit_counter 		<= bit_counter_temp;
            parallel_data_reg 	<= parallel_data_reg_temp;
			//serial_data_out <= serial_data_out_temp;
        end
	end
	
	// next_state and output logic of FSM
	
    always_comb begin
        case(cs)
            IDLE:	begin
              	//serial_data_out_temp = 0;
				bit_counter_temp 		= 0;
				parallel_data_reg_temp 	= 0;
				out_data_temp 			= 0;
              	if(req) begin
                	ns 			= TAKE_INPUT_DATA;
                	grant_temp 	= 1;
              	end
                else begin	
                  	ns 			= IDLE;
                  	grant_temp 	= 0;
                end
            end
          
            TAKE_INPUT_DATA:	begin
              	serial_data_out_temp 	= 0;
              	bit_counter_temp		= 0;
				parallel_data_reg_temp 	= parallel_data_in;
				out_data_temp 			= 1;
            	ns 						= SEND_SERIAL_OUTPUT;
				grant_temp 				= 1;
            end 
          
          SEND_SERIAL_OUTPUT:	begin
              bit_counter_temp 			= bit_counter + 1;         
              parallel_data_reg_temp 	= parallel_data_reg >> 1; 	//Loading the 32-bit parallel input data
              if(bit_counter <= 31 ) 
				ns = cs;
              else begin
                ns 					= IDLE;
				out_data_temp 		= 0;
				bit_counter_temp 	= 0;
				end
            end     
        endcase
    end      
endmodule

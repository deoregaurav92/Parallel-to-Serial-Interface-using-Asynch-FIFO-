 module memory #( addrbits=8, depth=128)
               (input clk_in, flush, rst, sync_flush,
                input clk_out, rden, wren, 
                input [addrbits-1:0] rdaddr, wraddr,
                input  dataIn, 
                output reg  dataOut);

reg  FIFO [0:depth-1];
integer i;

// Writing into the FIFO 

always@(posedge clk_in, negedge rst)
begin
    if(!rst)
    begin
		for(i=0;i<depth;i=i+1)
		FIFO[i] <= 0;           
    end
    else if(flush)
    begin
		for(i=0;i<depth;i=i+1)
		FIFO[i] <= 0;
    end           
    else if(wren)        
    begin
		FIFO[wraddr] <= dataIn;
    end
    
end

// Reading from the FIFO 

always@(posedge clk_out, negedge rst)
begin
    if(!rst)
    begin
		dataOut <= FIFO[0];
    end
    else if(sync_flush)
    begin
		dataOut <= FIFO[0];
    end
    else if(rden)
    begin
		dataOut <= FIFO[rdaddr];
    end
    else if(!rden && (rdaddr == 0))
		dataOut <= FIFO[0];
    else if(!rden)
		dataOut <= FIFO[rdaddr];
end
endmodule

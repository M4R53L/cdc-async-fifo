// **************************************************** 
// Project      : Advanced Logic Design Course Lab 5  
// File         : sync_bridge.sv
// Authors      : Batya Mayer (206973349) & Marsel Nasr (205728702)
// ****************************************************

module sync_bridge (
    // Clock domain = clka
    input logic clka,
    input logic [7:0] din_clka,
    input logic data_valid_clka,
    	
	output logic data_req_clka,

    // Clock domain = clkb
    input logic clkb,
    input logic resetb_clkb,
    input logic data_req_clkb,
    	
	output logic data_valid_clkb,
    output logic [7:0] dout_clkb
);

	// Reset Synchronizer for clka domain
	logic resetb_clka;
	
    dff_sync #(.WIDTH(1)) reset_sync (
        .clk(clka),
        .resetb(resetb_clkb),
        .d(1'b1),
        .q(resetb_clka)
    );

    // FIFO Signals
    logic fifo_full, fifo_empty;
	
	    // Instantiate Async FIFO
    async_fifo fifo (
        .wr_clk(clka),
        .wr_resetb(resetb_clka),
        .wr_en(data_valid_clka),
        .din(din_clka),
        .full(fifo_full),
        .rd_clk(clkb),
        .rd_resetb(resetb_clkb),
        .rd_en(1'b1),
        .dout(dout_clkb),
        .empty(fifo_empty)
    );


    // Instantiate Synchronizer for data_req_clkb to clka domain
    logic sync_data_req_clkb;

    dff_sync #(.WIDTH(1)) sync_data_req (
        .clk(clka),
        .resetb(resetb_clka),
        .d(data_req_clkb),
        .q(sync_data_req_clkb)
    );
	
	// Clean pulses in clka domain
    pulse_cleaner cleaner_inst (.clk(clka),
								.resetb(resetb_clka),
								.pulse_in(sync_data_req_clkb),
								.pulse_out(data_req_clka));
   

    // Generate data_valid_clkb (separate FF)
    always_ff @(posedge clkb or negedge resetb_clkb) begin
        if (~resetb_clkb) begin
            data_valid_clkb <= 0;
        end else begin
            data_valid_clkb <= (~fifo_empty);
        end
    end

endmodule

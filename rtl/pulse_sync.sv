/// PULSE EXPANDER
module pulse_expand (
    input  logic clk,
    input  logic resetb,
    input  logic pulse_in,
    output logic [2:0] pulse_expand_out
);
    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            pulse_expand_out <= '0;
        end else if (pulse_in) begin
            pulse_expand_out <= '1;  // Expand the pulse
        end else begin
            pulse_expand_out <= {pulse_expand_out[1:0], 1'b0};  // Shift and reduce
        end
    end
endmodule

/// PULSE SYNCHRONIZER
module pulse_synchronizer (
    input  logic clk,
    input  logic resetb,
    input  logic d,
    output logic q
);
    logic sync_ff1, sync_ff2;

    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            sync_ff1 <= 1'b0;
        end else begin
            sync_ff1 <= d;  // First flip-flop
        end
    end
	
    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff2 <= sync_ff1; // Second flip-flop
        end
    end	

    assign q = sync_ff2;
endmodule

/// PULSE CLEANER
module pulse_cleaner (
    input  logic clk,
    input  logic resetb,
    input  logic pulse_in,
    output logic pulse_out
);
    logic pulse_in_d;

    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            pulse_in_d <= 1'b0;
        end else begin
            pulse_in_d <= pulse_in; // Delayed version of pulse_in
        end
    end

    assign pulse_out = pulse_in & ~pulse_in_d; // Detect rising edge
endmodule

module pulse_sync1 (
    input  logic clka,
    input  logic resetb_a,
    input  logic clkb,
    input  logic resetb_b,
    input  logic pulse_in,
    output logic pulse_out
);
    logic sync_out;
    logic pulse_cleaned;

    // Synchronize to clkb domain
    pulse_synchronizer sync_inst (.clk(clkb),.resetb(resetb_b),.d(pulse_in),.q(sync_out));

    // Clean pulses in clkb domain
    pulse_cleaner cleaner_inst (.clk(clkb),.resetb(resetb_b),.pulse_in(sync_out),.pulse_out(pulse_cleaned));
    
	assign pulse_out = pulse_cleaned;
	
endmodule


module pulse_sync2 (
    input  logic clka,
    input  logic resetb_a,
    input  logic clkb,
    input  logic resetb_b,
    input  logic pulse_in,
    output logic pulse_out
);
    logic [2:0] pulse_in_expand;
    logic pulse_in_sync_b;

    // Pulse Expansion in clka domain
    pulse_expand i_pulse_expand (
        .clk            (clka),
        .resetb         (resetb_a),
        .pulse_in       (pulse_in),
        .pulse_expand_out(pulse_in_expand)
    );

    // Synchronize the expanded pulse to clkb domain
    pulse_synchronizer i_pulse_synchronizer (
        .clk            (clkb),
        .resetb         (resetb_b),
        .d       (pulse_in_expand[2]),
        .q (pulse_in_sync_b)
    );

    // Clean the synchronized pulse in the clkb domain
    pulse_cleaner i_pulse_cleaner (
        .clk            (clkb),
        .resetb         (resetb_b),
        .pulse_in       (pulse_in_sync_b),
        .pulse_out      (pulse_out)
    );
endmodule

module pulse_sync3 (
    input  logic clka,
    input  logic resetb_a,
    input  logic clkb,
    input  logic resetb_b,
    input  logic pulse_in,
    output logic pulse_out
);
    
    logic request_clka;        
    logic request_sync_clkb;   
    logic ack_clkb;            
    logic ack_sync_clka;       

    // Step 1: Generate request in clka domain
    always_ff @(posedge clka or negedge resetb_a) begin
        if (~resetb_a) begin
            request_clka <= 1'b0;
        end else if (pulse_in) begin
            request_clka <= 1'b1; // Set request on pulse_in
        end else if (ack_sync_clka) begin
            request_clka <= 1'b0; // Clear request on acknowledgment
        end
    end

    // Step 2: Synchronize request to clkb domain
    pulse_synchronizer  sync_request_to_clkb (.clk(clkb),.resetb(resetb_b),.d(request_clka),.q(request_sync_clkb));

    // Step 3: Process request and generate acknowledgment in clkb domain
    always_ff @(posedge clkb or negedge resetb_b) begin
        if (~resetb_b) begin
            pulse_out <= 1'b0;
        end else begin
            // Generate a single-cycle pulse on request
            if (request_sync_clkb & ~ack_clkb) begin
                pulse_out <= 1'b1;
            end else begin
                pulse_out <= 1'b0;
            end
        end
    end
	
    always_ff @(posedge clkb or negedge resetb_b) begin
        if (~resetb_b) begin
            ack_clkb <= 1'b0;
        end else begin
            // Generate a single-cycle pulse on request
            if (request_sync_clkb & ~ack_clkb) begin
                ack_clkb <= 1'b1; // Set acknowledgment
            end else begin
                ack_clkb <= request_sync_clkb; // Maintain acknowledgment
            end
        end
    end	

    // Step 4: Synchronize acknowledgment back to clka domain
    pulse_synchronizer sync_ack_to_clka (.clk(clka),.resetb(resetb_a),.d(ack_clkb),.q(ack_sync_clka));

endmodule
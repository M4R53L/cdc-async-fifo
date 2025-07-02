// **************************************************** 
// Project      : Advanced Logic Design Course Lab 5  
// File         : sync_bridge_tb.sv
// Authors      : Batya Mayer (206973349) & Marsel Nasr (205728702)
// ****************************************************
`timescale 1ns/1ps

module sync_bridge_tb;

    // Signals
    logic clka, clkb;
    logic resetb_clkb;
    logic [7:0] din_clka, dout_clkb;
    logic data_valid_clka, data_req_clka;
    logic data_req_clkb, data_valid_clkb;

    // Internal signals
    logic monitor_error;

    // Instantiate the DUT
    sync_bridge dut (
        .clka(clka),
        .din_clka(din_clka),
        .data_valid_clka(data_valid_clka),
        .data_req_clka(data_req_clka),
        .clkb(clkb),
        .resetb_clkb(resetb_clkb),
        .data_req_clkb(data_req_clkb),
        .data_valid_clkb(data_valid_clkb),
        .dout_clkb(dout_clkb)
    );

    // Clock generation
    always #6.25 clka = ~clka; // 80 MHz clock
    always #10 clkb = ~clkb;   // 50 MHz clock
	
	initial begin
		clka = 0; // Initialize clock
		clkb = 0; // Initialize clock
	end

    // Reset generation
    initial begin
        resetb_clkb = 0;
        #50;
        resetb_clkb = 1;
    end

    // Block A: Generate 20 random numbers upon data request
    initial begin
        data_valid_clka = 0;
        din_clka = 0;
        wait(data_req_clka); // Wait for request from Block B
        for (int i = 0; i < 20; i++) begin
            @(posedge clka);
            din_clka = $urandom % 256; // Generate random data
            data_valid_clka = 1;
        end
		din_clka = 0;
        data_valid_clka = 0; // Deassert valid signal
    end

    // Block B: Send a single data request
    initial begin
        data_req_clkb = 0;
		#1000
        @(posedge clkb);
        data_req_clkb = 1; // Send request
        @(posedge clkb);
        data_req_clkb = 0; // Clear request
    end

    // Monitor: Track signals in clka domain
    initial begin
        forever begin
            @(posedge clka);
            if (data_req_clka) begin
                $display("[MONITOR] Request received in clka domain.");
            end
            if (data_valid_clka) begin
                $display("[MONITOR] Data sent from Block A: %d", din_clka);
            end
        end
    end

    // Comparator: Verify data integrity
    initial begin
        monitor_error = 0;
        @(posedge resetb_clkb); // Wait for reset to complete
        for (int i = 0; i < 20; i++) begin
            @(posedge clkb);
            if (data_valid_clkb) begin
                $display("[COMPARATOR] Data received in Block B: %d", dout_clkb);
                if (dout_clkb !== din_clka) begin
                    monitor_error = 1;
                    $display("[ERROR] Data mismatch: Sent = %d, Received = %d", din_clka, dout_clkb);
                end
            end
        end
    end

    // Simulation control
    initial begin
        #10000; // Run simulation for a limited time
        if (monitor_error) begin
            $display("[TEST FAILED] Data integrity check failed.");
        end else begin
            $display("[TEST PASSED] All data transfers were successful.");
        end
        $finish;
    end

endmodule

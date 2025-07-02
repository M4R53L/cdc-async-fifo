`timescale 1ns/1ps

module tb_pulse_sync1;

  //--------------------------------------------------------------------------
  // Parameters for clock periods
  //--------------------------------------------------------------------------
  localparam real CLK_PERIOD_A = 10.0; // 10 ns => 100 MHz
  localparam real CLK_PERIOD_B = 5.0;  // 5 ns  => 200 MHz

  //--------------------------------------------------------------------------
  // DUT I/O signals
  //--------------------------------------------------------------------------
  logic clka;
  logic clkb;
  logic resetb_a;
  logic resetb_b;
  logic pulse_in;
  logic pulse_out;

  //--------------------------------------------------------------------------
  // Instantiate the DUT
  //--------------------------------------------------------------------------
  pulse_sync1 dut (
    .clka      (clka),
    .resetb_a  (resetb_a),
    .clkb      (clkb),
    .resetb_b  (resetb_b),
    .pulse_in  (pulse_in),
    .pulse_out (pulse_out)
  );

  //--------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------
  initial begin
    clka = 1'b0;
    forever #(CLK_PERIOD_A / 2.0) clka = ~clka;
  end

  initial begin
    clkb = 1'b0;
    forever #(CLK_PERIOD_B / 2.0) clkb = ~clkb;
  end

  //--------------------------------------------------------------------------
  // Test Stimulus
  //--------------------------------------------------------------------------
  initial begin
    // Initialize signals
    resetb_a = 1'b0;
    resetb_b = 1'b0;
    pulse_in = 1'b0;

    // Apply reset
    #20;
    resetb_a = 1'b1;
    resetb_b = 1'b1;

    // Wait for system to stabilize
    #20;

    // Test 1: A pulse in clka domain
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    // Test 2: Another pulse
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    // Test 3: Reset the system
    resetb_a = 1'b0;
    resetb_b = 1'b0;
    #20;
    resetb_a = 1'b1;
    resetb_b = 1'b1;
    #50;

    // Test 5: Reset during a pulse
    #20;
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
	pulse_in = 1'b0;
    resetb_a = 1'b0; // Assert reset in the middle of a pulse
    resetb_b = 1'b0;
    #10;
    resetb_a = 1'b1;
    resetb_b = 1'b1;
    #100;

    #20;
    // Simulate a normal clka pulse
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    $stop;
  end

  //--------------------------------------------------------------------------
  // Signal Monitoring
  //--------------------------------------------------------------------------
  initial begin
    $monitor("Time: %0t | clka=%b resetb_a=%b | clkb=%b resetb_b=%b | pulse_in=%b pulse_out=%b",
              $time,   clka,  resetb_a,       clkb,  resetb_b,      pulse_in,   pulse_out);
  end

endmodule

module tb_pulse_sync2;

  //--------------------------------------------------------------------------
  // Parameters for clock periods
  //--------------------------------------------------------------------------
  localparam real CLK_PERIOD_A = 5.0; // 5 ns => 200 MHz
  localparam real CLK_PERIOD_B = 10.0;  // 10 ns  => 100 MHz

  //--------------------------------------------------------------------------
  // DUT I/O signals
  //--------------------------------------------------------------------------
  logic clka;
  logic clkb;
  logic resetb_a;
  logic resetb_b;
  logic pulse_in;
  logic pulse_out;

  //--------------------------------------------------------------------------
  // Instantiate the DUT
  //--------------------------------------------------------------------------
  pulse_sync2 dut (
    .clka      (clka),
    .resetb_a  (resetb_a),
    .clkb      (clkb),
    .resetb_b  (resetb_b),
    .pulse_in  (pulse_in),
    .pulse_out (pulse_out)
  );

  //--------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------
  initial begin
    clka = 1'b0;
    forever #(CLK_PERIOD_A / 2.0) clka = ~clka;
  end

  initial begin
    clkb = 1'b0;
    forever #(CLK_PERIOD_B / 2.0) clkb = ~clkb;
  end

  //--------------------------------------------------------------------------
  // Test Stimulus
  //--------------------------------------------------------------------------
  initial begin
    // Initialize signals
    resetb_a = 1'b0;
    resetb_b = 1'b0;
    pulse_in = 1'b0;

    // Apply reset
    #20;
    resetb_a = 1'b1;
    resetb_b = 1'b1;

    // Wait for system to stabilize
    #20;

    // Test 1: A pulse in clka domain
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    // Test 2: Another pulse
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    // Test 3: Reset the system
    resetb_a = 1'b0;
    resetb_b = 1'b0;
    #20;
    resetb_a = 1'b1;
    resetb_b = 1'b1;
    #50;

    // Test 5: Reset during a pulse
    #20;
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
	pulse_in = 1'b0;
    resetb_a = 1'b0; // Assert reset in the middle of a pulse
    resetb_b = 1'b0;
    #10;
    resetb_a = 1'b1;
    resetb_b = 1'b1;
    #100;

    #20;
    // Simulate a normal clka pulse
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    $stop;
  end

  //--------------------------------------------------------------------------
  // Signal Monitoring
  //--------------------------------------------------------------------------
  initial begin
    $monitor("Time: %0t | clka=%b resetb_a=%b | clkb=%b resetb_b=%b | pulse_in=%b pulse_out=%b",
              $time,   clka,  resetb_a,       clkb,  resetb_b,      pulse_in,   pulse_out);
  end

endmodule

module tb_pulse_sync3#(
	//--------------------------------------------------------------------------
	// Parameters for clock periods
	//--------------------------------------------------------------------------
  parameter real CLK_PERIOD_A = 5.0, // 5 ns => 200 MHz
  parameter real CLK_PERIOD_B = 10.0 // 10 ns  => 100 MHz
  );

  

  //--------------------------------------------------------------------------
  // DUT I/O signals
  //--------------------------------------------------------------------------
  logic clka;
  logic clkb;
  logic resetb_a;
  logic resetb_b;
  logic pulse_in;
  logic pulse_out;

  //--------------------------------------------------------------------------
  // Instantiate the DUT
  //--------------------------------------------------------------------------
  pulse_sync3 dut (
    .clka      (clka),
    .resetb_a  (resetb_a),
    .clkb      (clkb),
    .resetb_b  (resetb_b),
    .pulse_in  (pulse_in),
    .pulse_out (pulse_out)
  );

  //--------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------
  initial begin
    clka = 1'b0;
    forever #(CLK_PERIOD_A / 2.0) clka = ~clka;
  end

  initial begin
    clkb = 1'b0;
    forever #(CLK_PERIOD_B / 2.0) clkb = ~clkb;
  end

  //--------------------------------------------------------------------------
  // Test Stimulus
  //--------------------------------------------------------------------------
  initial begin
    // Initialize signals
    resetb_a = 1'b0;
    resetb_b = 1'b0;
    pulse_in = 1'b0;

    // Apply reset
    #20;
    resetb_a = 1'b1;
    resetb_b = 1'b1;

    // Wait for system to stabilize
    #20;

    // Test 1: A pulse in clka domain
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    // Test 2: Another pulse
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;
	
    // Test 3: Reset the system
    resetb_a = 1'b0;
    resetb_b = 1'b0;
    #20;
    resetb_a = 1'b1;
    resetb_b = 1'b1;
    #50;

    // Test 5: Reset during a pulse
    #20;
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
	pulse_in = 1'b0;
    resetb_a = 1'b0; // Assert reset in the middle of a pulse
    resetb_b = 1'b0;
    #10;
    resetb_a = 1'b1;
    resetb_b = 1'b1;
    #100;

    #20;
    // Simulate a normal clka pulse
    pulse_in = 1'b1;
    #(CLK_PERIOD_A);
    pulse_in = 1'b0;
    #100;

    $stop;
  end

  //--------------------------------------------------------------------------
  // Signal Monitoring
  //--------------------------------------------------------------------------
  initial begin
    $monitor("Time: %0t | clka=%b resetb_a=%b | clkb=%b resetb_b=%b | pulse_in=%b pulse_out=%b",
              $time,   clka,  resetb_a,       clkb,  resetb_b,      pulse_in,   pulse_out);
  end

endmodule

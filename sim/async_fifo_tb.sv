`timescale 1ns/1ps

module async_fifo_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 16;

    // Clock and reset signals
    logic wr_clk, rd_clk;
    logic wr_resetb, rd_resetb;

    // FIFO signals
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] din, dout;
    logic full, empty;

    // Test variables
    integer i;

    // Instantiate the FIFO
    async_fifo uut (
        .wr_clk(wr_clk),
        .wr_resetb(wr_resetb),
        .wr_en(wr_en),
        .din(din),
        .full(full),
        .rd_clk(rd_clk),
        .rd_resetb(rd_resetb),
        .rd_en(rd_en),
        .dout(dout),
        .empty(empty)
    );

    // Clock generation
    always #6.25 wr_clk = ~wr_clk; // 80 MHz
    always #10 rd_clk = ~rd_clk;   // 50 MHz

    // Reset logic
    initial begin
        wr_resetb = 0;
        rd_resetb = 0;
        #50;
        wr_resetb = 1;
        rd_resetb = 1;
    end

    // Testbench logic
    initial begin
        // Initialize signals
        wr_clk = 0;
        rd_clk = 0;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        // Delay to observe reset state
        #100;

        // Test Case 1: Write and Read a Single Data Word
        $display("Test Case 1: Write and Read a Single Data Word");
        //@(posedge wr_resetb);
        //@(posedge rd_resetb);
        #20;
        @(posedge wr_clk);
        wr_en = 1;
        din = 8'hA5; // Arbitrary data
        @(posedge wr_clk);
        wr_en = 0;
        #50; // Delay to observe data in FIFO
        @(posedge rd_clk);
        rd_en = 1;
        @(posedge rd_clk);
        rd_en = 0;
        #50;
        $display("Read Data: %0h (expected: A5)", dout);

        // Delay between test cases
        #200;

        // Test Case 2: Write and Read Multiple Words
        $display("Test Case 2: Write and Read Multiple Words");
        @(posedge wr_clk);
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            if (!full) begin
                wr_en = 1;
                din = i;
                @(posedge wr_clk);
                #5; // Delay to allow visibility of write
            end else begin
                wr_en = 0;
                $display("FIFO Full at cycle %0t", $time);
            end
        end
        wr_en = 0;

        #200; // Delay to observe state before reading

        @(posedge rd_clk);
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            if (!empty) begin
                rd_en = 1;
                @(posedge rd_clk);
                #5; // Delay to allow visibility of read
                rd_en = 0;
                $display("Read Data: %0d", dout);
            end else begin
                $display("FIFO Empty at cycle %0t", $time);
            end
        end

        // Delay between test cases
        #200;

        // Test Case 3: Overflow
        $display("Test Case 3: Overflow Detection");
        @(posedge wr_clk);
        for (i = 0; i < FIFO_DEPTH + 4; i = i + 1) begin
            if (!full) begin
                wr_en = 1;
                din = i;
            end else begin
                $display("FIFO Overflow at cycle %0t", $time);
            end
            @(posedge wr_clk);
            #5;
        end
        wr_en = 0;

        #200;

        // Test Case 4: Underflow
        $display("Test Case 4: Underflow Detection");
        @(posedge rd_clk);
        for (i = 0; i < FIFO_DEPTH + 1; i = i + 1) begin
            if (!empty) begin
                rd_en = 1;
            end else begin
                $display("FIFO Underflow at cycle %0t", $time);
            end
            @(posedge rd_clk);
            #5;
            rd_en = 0;
        end

        // Delay between test cases
        #200;

        // Test Case 5: Simultaneous Write and Read
        $display("Test Case 5: Simultaneous Write and Read");
        fork
            // Writer process
            begin
                for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
                    if (!full) begin
                        wr_en = 1;
                        din = i + 8'h10;
                        @(posedge wr_clk);
                        #10; // Delay for visibility of simultaneous operation
                    end
                end
                wr_en = 0;
            end

            // Reader process
            begin
                for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
                    if (!empty) begin
                        rd_en = 1;
                        @(posedge rd_clk);
                        #10;
                        rd_en = 0;
                        $display("Read Data: %0h", dout);
                    end
                end
            end
        join

        // Finish simulation
        $display("Testbench Completed!");
        #100;
        $finish;
    end
endmodule

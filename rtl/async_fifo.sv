// **************************************************** 
// Project      : Advanced Logic Design Course Lab 5  
// File         : async_fifo.sv
// Authors      : Batya Mayer (206973349) & Marsel Nasr (205728702)
// ****************************************************

module async_fifo #(
    // Data width in each FIFO word
    parameter DATA_WIDTH = 8,
    // For a FIFO depth of 16, we need 4 address bits.
    // We add 1 extra bit (making it 5 bits) to detect "full vs. empty"
    // which is the typical asynchronous FIFO scheme.
    parameter ADDR_WIDTH = 4
)(
    // Write interface
    input  logic                  wr_clk,
    input  logic                  wr_resetb,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] din,
    output logic                  full,

    // Read interface
    input  logic                  rd_clk,
    input  logic                  rd_resetb,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] dout,
    output logic                  empty
);

    // Extra pointer bit for detecting wrap-around vs. fullness
    localparam PTR_WIDTH = ADDR_WIDTH + 1;

    // -------------------------------------------------
    // FIFO storage (depth=16 => 4 address bits)
	// - Each element is DATA_WIDTH bits wide.
	// - Total size: 2^ADDR_WIDTH elements, indexed from 0 to (2^ADDR_WIDTH - 1).
    // -------------------------------------------------
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // -------------------------------------------------
    // Write pointer (binary & Gray)
    // -------------------------------------------------
    logic [PTR_WIDTH-1:0] wr_ptr_bin;
    logic [PTR_WIDTH-1:0] wr_ptr_bin_next;
    logic [PTR_WIDTH-1:0] wr_ptr_gray;

    // -------------------------------------------------
    // Read pointer (binary & Gray)
    // -------------------------------------------------
    logic [PTR_WIDTH-1:0] rd_ptr_bin;
    logic [PTR_WIDTH-1:0] rd_ptr_bin_next;
    logic [PTR_WIDTH-1:0] rd_ptr_gray;

    // -------------------------------------------------
    // Synchronized pointers (across clock domains)
    logic [PTR_WIDTH-1:0] rd_ptr_gray_w2r;  // from write domain -> read domain
    logic [PTR_WIDTH-1:0] wr_ptr_gray_r2w;  // from read domain -> write domain

    // After synchronization, convert Gray->bin for comparisons
    logic [PTR_WIDTH-1:0] rd_ptr_bin_w2r;
    logic [PTR_WIDTH-1:0] wr_ptr_bin_r2w;

    // =================================================
    // WRITE-POINTER LOGIC (in wr_clk domain)
    // =================================================
    always_ff @(posedge wr_clk or negedge wr_resetb) begin
        if (!wr_resetb)
            wr_ptr_bin <= '0;
        else if (wr_en & ~full)
            wr_ptr_bin <= wr_ptr_bin + 1;
    end

    // Convert to Gray
    bin2gray #(.WIDTH(PTR_WIDTH)) u_bin2gray_wr (
        .bin(wr_ptr_bin),
        .gray(wr_ptr_gray)
    );

    // Write memory on write enable (if not full)
    always_ff @(posedge wr_clk) begin
        if (wr_en & ~full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
        end
    end

    // Synchronize read pointer Gray into write domain
    dff_sync #(.WIDTH(PTR_WIDTH)) sync_rd_ptr_to_wr_1 (
        .clk    (wr_clk),
        .resetb (wr_resetb),
        .d      (rd_ptr_gray),
        .q      (wr_ptr_gray_r2w)
    );

    // Convert synchronized read-pointer (Gray) to binary
    gray2bin #(.WIDTH(PTR_WIDTH)) u_gray2bin_rd_in_wr (
        .gray (wr_ptr_gray_r2w),
        .bin (wr_ptr_bin_r2w)
    );

    // Generate FULL in the write clock domain
    assign full = (
        (wr_ptr_gray == {~wr_ptr_gray_r2w[PTR_WIDTH-1:PTR_WIDTH-2],
                          wr_ptr_gray_r2w[PTR_WIDTH-3:0]})
    );

    // =================================================
    // READ-POINTER LOGIC (in rd_clk domain)
    // =================================================
    always_ff @(posedge rd_clk or negedge rd_resetb) begin
        if (!rd_resetb)
            rd_ptr_bin <= '0;
        else if (rd_en & ~empty)
            rd_ptr_bin <= rd_ptr_bin + 1;
    end

    // Convert to Gray
    bin2gray #(.WIDTH(PTR_WIDTH)) u_bin2gray_rd (
        .bin(rd_ptr_bin),
        .gray(rd_ptr_gray)
    );

    // Read data from FIFO memory (synchronous read)
    // Update: Drive `dout` properly even when FIFO is empty
    always_ff @(posedge rd_clk or negedge rd_resetb) begin
        if (!rd_resetb) begin
            dout <= {DATA_WIDTH{1'b0}}; // Default value on reset
        end else if ((rd_en & (~empty)) == 1'b1) begin
            dout <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]]; // Valid data from memory
        end else begin
            dout <= {DATA_WIDTH{1'b0}};// Default value when empty or invalid read
        end
    end

    // Synchronize write pointer Gray into read domain
    dff_sync #(.WIDTH(PTR_WIDTH)) sync_wr_ptr_to_rd_1 (
        .clk    (rd_clk),
        .resetb (rd_resetb),
        .d      (wr_ptr_gray),
        .q      (rd_ptr_gray_w2r)
    );

    // Convert synchronized write-pointer (Gray) to binary
    gray2bin #(.WIDTH(PTR_WIDTH)) u_gray2bin_wr_in_rd (
        .gray (rd_ptr_gray_w2r),
        .bin (rd_ptr_bin_w2r)
    );

    // Generate EMPTY in the read clock domain
    assign empty = (rd_ptr_gray == rd_ptr_gray_w2r);

endmodule

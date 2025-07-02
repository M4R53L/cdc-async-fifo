// **************************************************** 
// Project      : Advanced Logic Design Course Lab 5  
// File         : pulse_cleaner.sv
// Authors      : Batya Mayer (206973349) & Marsel Nasr (205728702)
// ****************************************************

module pulse_cleaner (
    input  logic clk,
    input  logic resetb,
    input  logic pulse_in,
    output logic pulse_out
);
    logic pulse_reg;

    always_ff @(posedge clk or negedge resetb) begin
        if (~resetb) begin
            pulse_reg <= 1'b0;
        end else if (pulse_in) begin
            pulse_reg <= ~pulse_reg; // Toggle on pulse_in
        end
    end

    assign pulse_out = pulse_in & ~pulse_reg; // Output a single pulse
endmodule
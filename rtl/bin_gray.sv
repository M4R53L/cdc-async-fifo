// **************************************************** 
// Project      : Advanced Logic Design Course Lab 5  
// File         : bin2gray.sv
// Authors      : Batya Mayer (206973349) & Marsel Nasr (205728702)
// ****************************************************

module bin2gray #(parameter WIDTH = 4) (
    input  [WIDTH-1:0] bin,
    output [WIDTH-1:0] gray
);
    assign gray = bin ^ (bin >> 1);
endmodule


module gray2bin #(parameter WIDTH = 4) (
    input  logic [WIDTH-1:0] gray,
    output logic [WIDTH-1:0] bin
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_gray2bin
            if (i == WIDTH - 1) begin
                // MSB of binary is same as MSB of Gray
                always_comb bin[i] = gray[i];
            end else begin
                // XOR each Gray bit with the next higher binary bit
                always_comb bin[i] = bin[i + 1] ^ gray[i];
            end
        end
    endgenerate

endmodule


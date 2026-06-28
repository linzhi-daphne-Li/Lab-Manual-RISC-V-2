module mux5 #(parameter WIDTH = 32)(
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire [WIDTH-1:0] d2,
    input  wire [WIDTH-1:0] d3,
    input  wire [WIDTH-1:0] d4,
    input  wire [2:0]       sel,
    output reg  [WIDTH-1:0] y
);
    always @(*) begin
        case (sel)
            3'b000: y = d0; // ALUOut register
            3'b001: y = d1; // Data register
            3'b010: y = d2; // Current ALU result
            3'b011: y = d3; // PC register
            3'b100: y = d4; // Immediate
            default: y = d0;
        endcase
    end
endmodule

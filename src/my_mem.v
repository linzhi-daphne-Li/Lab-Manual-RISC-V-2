module my_mem #(
    parameter WIDTH = 32,
    parameter MEM_DEPTH = 256
)(
    input  wire             clk,
    input  wire             we,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] wd,
    output wire [WIDTH-1:0] rd
);
    reg [WIDTH-1:0] RAM [0:MEM_DEPTH-1];

    assign rd = RAM[a[31:2]];

    always @(posedge clk) begin
        if (we)
            RAM[a[31:2]] <= wd;
    end
endmodule

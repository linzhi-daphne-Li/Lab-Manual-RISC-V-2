module memory(
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] a,
    input  wire [31:0] wd,
    output wire [31:0] rd
);
    reg [31:0] RAM [0:255];

    assign rd = RAM[a[31:2]]; // word addressed

    always @(posedge clk) begin
        if (we) RAM[a[31:2]] <= wd;
    end
endmodule

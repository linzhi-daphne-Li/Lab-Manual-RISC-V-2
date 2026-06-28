module my_reg #(
    parameter WIDTH = 32,
    parameter REG_NUM = 32
)(
    input  wire             clk,
    input  wire             we,
    input  wire [4:0]       a1,
    input  wire [4:0]       a2,
    input  wire [4:0]       a3,
    input  wire [WIDTH-1:0] wd,
    output wire [WIDTH-1:0] rd1,
    output wire [WIDTH-1:0] rd2
);
    reg [WIDTH-1:0] RF [0:REG_NUM-1];

    assign rd1 = (a1 == 5'd0) ? {WIDTH{1'b0}} : RF[a1];
    assign rd2 = (a2 == 5'd0) ? {WIDTH{1'b0}} : RF[a2];

    always @(posedge clk) begin
        if (we && (a3 != 5'd0))
            RF[a3] <= wd;
    end
endmodule

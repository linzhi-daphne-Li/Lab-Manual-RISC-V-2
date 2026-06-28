module pc #(
    parameter WIDTH = 32
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             en,
    input  wire [WIDTH-1:0] pc_next,
    output reg  [WIDTH-1:0] pc_q
);
    always @(posedge clk) begin
        if (reset)
            pc_q <= {WIDTH{1'b0}};
        else if (en)
            pc_q <= pc_next;
    end
endmodule

module reg_file(
    input  wire        clk,
    input  wire        we3,
    input  wire [4:0]  a1,
    input  wire [4:0]  a2,
    input  wire [4:0]  a3,
    input  wire [31:0] wd3,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] RF [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) RF[i] = 32'b0;
    end

    assign rd1 = (a1 == 5'b0) ? 32'b0 : RF[a1];
    assign rd2 = (a2 == 5'b0) ? 32'b0 : RF[a2];

    always @(posedge clk) begin
        if (we3 && (a3 != 5'b0)) begin
            RF[a3] <= wd3;
        end
    end
endmodule

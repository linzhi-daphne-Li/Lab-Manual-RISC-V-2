module sign_ext(
    input  wire [31:7] instr,
    input  wire [2:0]  imm_src,
    output reg  [31:0] imm_ext
);
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_J = 3'b011;
    localparam IMM_U = 3'b100;

    always @(*) begin
        case (imm_src)
            IMM_I: imm_ext = {{20{instr[31]}}, instr[31:20]};
            IMM_S: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            IMM_B: imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            IMM_J: imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            IMM_U: imm_ext = {instr[31:12], 12'b0};
            default: imm_ext = 32'b0;
        endcase
    end
endmodule

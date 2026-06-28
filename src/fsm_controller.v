module fsm_controller(
    input  wire       clk,
    input  wire       reset,
    input  wire [6:0] op,
    output reg        pc_update,
    output reg        branch,
    output reg        we_ir,
    output reg        we_mem,
    output reg        we_rf,
    output reg        sel_mem_addr,
    output reg  [1:0] sel_alu_src_a,
    output reg  [1:0] sel_alu_src_b,
    output reg  [1:0] alu_op,
    output reg  [2:0] sel_result,
    output wire [3:0] state_dbg
);
    localparam OP_LW     = 7'b0000011;
    localparam OP_SW     = 7'b0100011;
    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_LUI    = 7'b0110111;

    localparam S_FETCH    = 4'd0;
    localparam S_DECODE   = 4'd1;
    localparam S_EXE_ADDR = 4'd2;
    localparam S_MEM_RD   = 4'd3;
    localparam S_WB_MEM   = 4'd4;
    localparam S_MEM_WR   = 4'd5;
    localparam S_EXE_R    = 4'd6;
    localparam S_WB_ALU   = 4'd7;
    localparam S_BEQ      = 4'd8;
    localparam S_EXE_I    = 4'd9;
    localparam S_JAL      = 4'd10;
    localparam S_WB_LUI   = 4'd11;

    reg [3:0] state, next_state;
    assign state_dbg = state;

    always @(posedge clk) begin
        if (reset) state <= S_FETCH;
        else state <= next_state;
    end

    always @(*) begin
        case (state)
            S_FETCH:  next_state = S_DECODE;
            S_DECODE: begin
                case (op)
                    OP_LW:     next_state = S_EXE_ADDR;
                    OP_SW:     next_state = S_EXE_ADDR;
                    OP_RTYPE:  next_state = S_EXE_R;
                    OP_ITYPE:  next_state = S_EXE_I;
                    OP_BRANCH: next_state = S_BEQ;
                    OP_JAL:    next_state = S_JAL;
                    OP_LUI:    next_state = S_WB_LUI;
                    default:   next_state = S_FETCH;
                endcase
            end
            S_EXE_ADDR: next_state = (op == OP_LW) ? S_MEM_RD : S_MEM_WR;
            S_MEM_RD:   next_state = S_WB_MEM;
            S_WB_MEM:   next_state = S_FETCH;
            S_MEM_WR:   next_state = S_FETCH;
            S_EXE_R:    next_state = S_WB_ALU;
            S_EXE_I:    next_state = S_WB_ALU;
            S_WB_ALU:   next_state = S_FETCH;
            S_BEQ:      next_state = S_FETCH;
            S_JAL:      next_state = S_FETCH;
            S_WB_LUI:   next_state = S_FETCH;
            default:    next_state = S_FETCH;
        endcase
    end

    always @(*) begin
        // safe defaults for every state
        pc_update     = 1'b0;
        branch        = 1'b0;
        we_ir         = 1'b0;
        we_mem        = 1'b0;
        we_rf         = 1'b0;
        sel_mem_addr  = 1'b0;   // 0: PC, 1: ALUOut
        sel_alu_src_a = 2'b00;  // 00: PC, 01: old PC, 10: rs1 register
        sel_alu_src_b = 2'b00;  // 00: rs2 register, 01: immediate, 10: constant 4
        alu_op        = 2'b00;  // 00: add, 01: subtract, 10: instruction ALU op
        sel_result    = 3'b000; // 000: ALUOut, 001: DataReg, 010: ALUResult, 011: PC, 100: Imm

        case (state)
            S_FETCH: begin
                sel_mem_addr  = 1'b0;
                we_ir         = 1'b1;
                sel_alu_src_a = 2'b00;
                sel_alu_src_b = 2'b10;
                alu_op        = 2'b00;
                sel_result    = 3'b010;
                pc_update     = 1'b1;
            end
            S_DECODE: begin
                // No architectural write. Register-file outputs are latched in datapath.
            end
            S_EXE_ADDR: begin
                sel_alu_src_a = 2'b10;
                sel_alu_src_b = 2'b01;
                alu_op        = 2'b00;
            end
            S_MEM_RD: begin
                sel_result    = 3'b000;
                sel_mem_addr  = 1'b1;
            end
            S_WB_MEM: begin
                sel_result    = 3'b001;
                we_rf         = 1'b1;
            end
            S_MEM_WR: begin
                sel_result    = 3'b000;
                sel_mem_addr  = 1'b1;
                we_mem        = 1'b1;
            end
            S_EXE_R: begin
                sel_alu_src_a = 2'b10;
                sel_alu_src_b = 2'b00;
                alu_op        = 2'b10;
            end
            S_WB_ALU: begin
                sel_result    = 3'b000;
                we_rf         = 1'b1;
            end
            S_BEQ: begin
                sel_alu_src_a = 2'b10;
                sel_alu_src_b = 2'b00;
                alu_op        = 2'b01;
                branch        = 1'b1;
            end
            S_EXE_I: begin
                sel_alu_src_a = 2'b10;
                sel_alu_src_b = 2'b01;
                alu_op        = 2'b10;
            end
            S_JAL: begin
                sel_result    = 3'b011; // rd = PC, which is already old_pc + 4
                pc_update     = 1'b1;
                we_rf         = 1'b1;
            end
            S_WB_LUI: begin
                sel_result    = 3'b100;
                we_rf         = 1'b1;
            end
        endcase
    end
endmodule

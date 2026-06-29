module main_decoder(
    input  wire       clk,
    input  wire       reset,
    input  wire [6:0] op,
    input  wire       zero,
    output reg        we_pc,
    output reg        we_ir,
    output reg        we_mem,
    output reg        we_rf,
    output reg        branch,
    output reg        pc_update,
    output reg        sel_mem_addr,
    output reg  [1:0] sel_result,
    output reg  [1:0] sel_alu_src_a,
    output reg  [1:0] sel_alu_src_b,
    output reg  [2:0] sel_ext,
    output reg  [1:0] alu_op,
    output reg  [3:0] state
);
    localparam OP_LW     = 7'b0000011;
    localparam OP_SW     = 7'b0100011;
    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_BEQ    = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_LUI    = 7'b0110111;

    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_J = 3'b011;
    localparam IMM_U = 3'b100;

    localparam ALU_OP_ADD    = 2'b00;
    localparam ALU_OP_BRANCH = 2'b01;
    localparam ALU_OP_RTYPE  = 2'b10;
    localparam ALU_OP_ITYPE  = 2'b11;

    
    localparam S_FETCH      = 4'd0;
    localparam S_DECODE     = 4'd1;
    localparam S_EXE_ADDR   = 4'd2;
    localparam S_MEM_RD     = 4'd3;
    localparam S_WB_MEM     = 4'd4;
    localparam S_MEM_WR     = 4'd5;
    localparam S_EXE_R      = 4'd6;
    localparam S_MEM_ALU    = 4'd7;
    localparam S_WB_ALU     = 4'd8;
    localparam S_BEQ        = 4'd9;
    localparam S_EXE_I      = 4'd10;
    localparam S_JAL        = 4'd11;
    localparam S_LUI        = 4'd12;
    localparam S_MEM_DUMMY  = 4'd13;
    localparam S_WB_DUMMY   = 4'd14;


    reg [3:0] next_state;

    always @(posedge clk) begin
        if (reset)
            state <= S_FETCH;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            S_FETCH:  next_state = S_DECODE;
            S_DECODE: begin
                case (op)
                    OP_LW:    next_state = S_EXE_ADDR;
                    OP_SW:    next_state = S_EXE_ADDR;
                    OP_RTYPE: next_state = S_EXE_R;
                    OP_ITYPE: next_state = S_EXE_I;
                    OP_BEQ:   next_state = S_BEQ;
                    OP_JAL:   next_state = S_JAL;
                    OP_LUI:   next_state = S_LUI;
                    default:  next_state = S_FETCH;
                endcase
            end

             // lw: IF -> ID -> address EX -> MEM read -> WB
            // sw: IF -> ID -> address EX -> MEM write -> dummy WB
            S_EXE_ADDR:  next_state = (op == OP_LW) ? S_MEM_RD : S_MEM_WR;
            S_MEM_RD:    next_state = S_WB_MEM;
            S_WB_MEM:    next_state = S_FETCH;
            S_MEM_WR:    next_state = S_WB_DUMMY;

            // R/I-type: IF -> ID -> EX -> dummy MEM(recompute/hold ALU result) -> WB
            S_EXE_R:     next_state = S_MEM_ALU;
            S_EXE_I:     next_state = S_MEM_ALU;
            S_MEM_ALU:   next_state = S_WB_ALU;
            S_WB_ALU:    next_state = S_FETCH;

            // beq/jal/lui also take five stages with dummy MEM/WB where needed.
            S_BEQ:       next_state = S_MEM_DUMMY;
            S_JAL:       next_state = S_MEM_DUMMY;
            S_LUI:       next_state = S_MEM_DUMMY;
            S_MEM_DUMMY: next_state = S_WB_DUMMY;
            S_WB_DUMMY:  next_state = S_FETCH;

        
            default:    next_state = S_FETCH;
        endcase
    end

    always @(*) begin
        case (op)
            OP_LW:    sel_ext = IMM_I;
            OP_SW:    sel_ext = IMM_S;
            OP_BEQ:   sel_ext = IMM_B;
            OP_JAL:   sel_ext = IMM_J;
            OP_LUI:   sel_ext = IMM_U;
            OP_ITYPE: sel_ext = IMM_I;
            default:  sel_ext = IMM_I;
        endcase
    end

    always @(*) begin
        we_pc         = 1'b0;
        we_ir         = 1'b0;
        we_mem        = 1'b0;
        we_rf         = 1'b0;
        branch        = 1'b0;
        pc_update     = 1'b0;
        sel_mem_addr  = 1'b0;
        sel_result    = 2'b00;
        sel_alu_src_a = 2'b00;
        sel_alu_src_b = 2'b00;
        alu_op        = ALU_OP_ADD;

        case (state)
            S_FETCH: begin
                sel_mem_addr  = 1'b0;   // memory address = PC
                we_ir         = 1'b1;   // load instruction register
                sel_alu_src_a = 2'b00;  // PC
                sel_alu_src_b = 2'b10;  // 4
                alu_op        = ALU_OP_ADD;
                sel_result    = 2'b10;  // current ALU result = PC + 4
                pc_update     = 1'b1;
                we_pc         = 1'b1;   // PC <= PC + 4
            end

            S_DECODE: begin
                sel_alu_src_a = 2'b01;  // old PC of current instruction
                sel_alu_src_b = 2'b01;  // immediate
                alu_op        = ALU_OP_ADD; // precompute branch/jump target into alu_reg
            end

            S_EXE_ADDR: begin
                sel_alu_src_a = 2'b10;  // rd1_reg
                sel_alu_src_b = 2'b01;  // immediate
                alu_op        = ALU_OP_ADD; // address = rs1 + imm
            end

            S_MEM_RD: begin
                sel_mem_addr  = 1'b1;   // memory address = alu_reg
            end

            S_WB_MEM: begin
                sel_result    = 2'b01;  // data_reg
                we_rf         = 1'b1;   // lw writes register
            end

            S_MEM_WR: begin
                sel_mem_addr  = 1'b1;   // memory address = alu_reg
                we_mem        = 1'b1;   // sw writes memory
            end

            S_EXE_R: begin
                sel_alu_src_a = 2'b10;  // rd1_reg
                sel_alu_src_b = 2'b00;  // rd2_reg
                alu_op        = ALU_OP_RTYPE;
            end

            S_EXE_I: begin
                sel_alu_src_a = 2'b10;  // rd1_reg
                sel_alu_src_b = 2'b01;  // immediate
                alu_op        = ALU_OP_ITYPE;
            end

            S_MEM_ALU: begin
                // Dummy MEM stage for R/I instructions.
                // Because alu_reg is always enabled in rv_mc, recompute the same ALU result here
                // so S_WB_ALU still receives the correct value.
                if (op == OP_RTYPE) begin
                    sel_alu_src_a = 2'b10;
                    sel_alu_src_b = 2'b00;
                    alu_op        = ALU_OP_RTYPE;
                end else begin
                    sel_alu_src_a = 2'b10;
                    sel_alu_src_b = 2'b01;
                    alu_op        = ALU_OP_ITYPE;
                end
            end

            S_WB_ALU: begin
                sel_result    = 2'b00;  // alu_reg
                we_rf         = 1'b1;   // R/I type writes register
            end

            S_BEQ: begin
                sel_alu_src_a = 2'b10;  // rd1_reg
                sel_alu_src_b = 2'b00;  // rd2_reg
                alu_op        = ALU_OP_BRANCH; // subtract for zero comparison
                sel_result    = 2'b00;  // precomputed branch target in alu_reg
                branch        = 1'b1;
                pc_update     = zero;
                we_pc         = zero;   // if equal: PC <= branch target
            end

            S_JAL: begin
                // PC target was precomputed in DECODE and stored in alu_reg.
                sel_result    = 2'b00;
                pc_update     = 1'b1;
                we_pc         = 1'b1;   // PC <= jump target
            end

            S_LUI: begin
                // Real writeback is delayed until S_WB_DUMMY to keep a 5-stage path.
            end

            S_MEM_DUMMY: begin
                // Dummy MEM stage for beq/jal/lui.
                // For jal, compute link value PC_old + 4 and store it into alu_reg for WB.
                if (op == OP_JAL) begin
                    sel_alu_src_a = 2'b01;  // old PC
                    sel_alu_src_b = 2'b10;  // 4
                    alu_op        = ALU_OP_ADD;
                end
            end

            S_WB_DUMMY: begin
                // Dummy WB for sw/beq. Real WB for jal/lui.
                if (op == OP_JAL) begin
                    sel_result    = 2'b00;  // alu_reg = PC_old + 4
                    we_rf         = 1'b1;
                end else if (op == OP_LUI) begin
                    sel_result    = 2'b11;  // immediate
                    we_rf         = 1'b1;
                end
            end

            default: begin
                // keep default safe zero values
            end
        endcase
    end
endmodule


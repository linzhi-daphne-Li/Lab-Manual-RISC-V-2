module rv_mc(
    input  wire clk,
    input  wire reset
);
    wire        we_pc, branch, we_ir, we_mem, we_rf, sel_mem_addr;
    wire [1:0]  sel_alu_src_a, sel_alu_src_b;
    wire [2:0]  sel_result, sel_ext, alu_control;
    wire [3:0]  state_dbg;

    wire [31:0] pc, pc_next, old_pc;
    wire [31:0] mem_addr, mem_rd, mem_wd;
    wire [31:0] instr, data_reg_out;
    wire [31:0] rf_rd1, rf_rd2, rd1_reg_out, rd2_reg_out;
    wire [31:0] imm_ext;
    wire [31:0] alu_src_a, alu_src_b, alu_result, alu_reg_out;
    wire [31:0] result;
    wire [31:0] branch_target;
    wire        zero;

    // Architectural PC and helper old_pc. old_pc stores the PC of the instruction in IR.
    flopenr #(32) PC_reg(.clk(clk), .reset(reset), .en(we_pc), .d(pc_next), .q(pc));
    flopenr #(32) old_pc_reg(.clk(clk), .reset(reset), .en(we_ir), .d(pc), .q(old_pc));

    mux2 #(32) ADDR_MUX(.d0(pc), .d1(alu_reg_out), .sel(sel_mem_addr), .y(mem_addr));

    memory MEM(.clk(clk), .we(we_mem), .a(mem_addr), .wd(mem_wd), .rd(mem_rd));

    flopenr #(32) instr_reg(.clk(clk), .reset(reset), .en(we_ir), .d(mem_rd), .q(instr));
    flopr   #(32) data_reg (.clk(clk), .reset(reset), .d(mem_rd), .q(data_reg_out));

    reg_file RF(
        .clk(clk), .we3(we_rf),
        .a1(instr[19:15]), .a2(instr[24:20]), .a3(instr[11:7]),
        .wd3(result), .rd1(rf_rd1), .rd2(rf_rd2)
    );

    flopr #(32) rd1_reg(.clk(clk), .reset(reset), .d(rf_rd1), .q(rd1_reg_out));
    flopr #(32) rd2_reg(.clk(clk), .reset(reset), .d(rf_rd2), .q(rd2_reg_out));

    sign_ext EXT(.instr(instr[31:7]), .sel_ext(sel_ext), .imm_ext(imm_ext));

    mux3 #(32) SRC_A_MUX(.d0(pc), .d1(old_pc), .d2(rd1_reg_out), .sel(sel_alu_src_a), .y(alu_src_a));
    mux3 #(32) SRC_B_MUX(.d0(rd2_reg_out), .d1(imm_ext), .d2(32'd4), .sel(sel_alu_src_b), .y(alu_src_b));

    alu ALU(.a(alu_src_a), .b(alu_src_b), .alu_control(alu_control), .result(alu_result), .zero(zero));
    flopr #(32) alu_reg(.clk(clk), .reset(reset), .d(alu_result), .q(alu_reg_out));

    // Extra target calculation keeps BEQ/JAL simple and reliable in this teaching implementation.
    assign branch_target = old_pc + imm_ext;
    assign pc_next = branch ? branch_target : result;

    mux5 #(32) RESULT_MUX(
        .d0(alu_reg_out), .d1(data_reg_out), .d2(alu_result), .d3(pc), .d4(imm_ext),
        .sel(sel_result), .y(result)
    );

    assign mem_wd = rd2_reg_out;

    controller CTRL(
        .clk(clk), .reset(reset), .op(instr[6:0]), .funct3(instr[14:12]), .funct7b5(instr[30]), .zero(zero),
        .we_pc(we_pc), .branch(branch), .we_ir(we_ir), .we_mem(we_mem), .we_rf(we_rf),
        .sel_mem_addr(sel_mem_addr), .sel_alu_src_a(sel_alu_src_a), .sel_alu_src_b(sel_alu_src_b),
        .sel_result(sel_result), .sel_ext(sel_ext), .alu_control(alu_control), .state_dbg(state_dbg)
    );
endmodule

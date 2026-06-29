module rv_mc(
    input wire clk,
    input wire reset
);
    wire [31:0] pc_q;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    wire [31:0] instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_rd;
    wire [31:0] dmem_rd;
    wire [31:0] imm_ext;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] rd1_reg_q;
    wire [31:0] rd2_reg_q;
    wire [31:0] data_reg_q;
    wire [31:0] alu_reg_q;
    wire [31:0] pc_old_q;
    wire [31:0] alu_src_a_data;
    wire [31:0] alu_src_b_data;
    wire [31:0] alu_result;
    wire [31:0] result;
    wire [31:0] result_mux_y;
    wire        zero;

    wire        we_pc;
    wire        we_ir;
    wire        we_mem;
    wire        we_rf;
    wire        reg_we;
    wire        branch;
    wire        pc_update;
    wire        sel_mem_addr;
    wire [1:0]  sel_result;
    wire [1:0]  sel_alu_src_a;
    wire [1:0]  sel_alu_src_b;
    wire [2:0]  sel_ext;
    wire [3:0]  alu_control;
    wire [3:0]  state;

    assign reg_we = we_rf;
    assign dmem_rd = mem_rd;

    // Multi-cycle design uses one shared memory. It is named IMEM so that
    // the original single-cycle test style can still load dut.IMEM.RAM.
    pc PC_reg(
        .clk(clk),
        .reset(reset),
        .en(we_pc),
        .pc_next(pc_next),
        .pc_q(pc_q)
    );

    mc_reg PC_OLD_REG(
        .clk(clk),
        .reset(reset),
        .en(we_ir),
        .d(pc_q),
        .q(pc_old_q)
    );

    mux2 #(32) MEM_ADDR_MUX(
        .d0(pc_q),
        .d1(alu_reg_q),
        .sel(sel_mem_addr),
        .y(mem_addr)
    );

    my_mem #(.WIDTH(32), .MEM_DEPTH(256)) IMEM(
        .clk(clk),
        .we(we_mem),
        .a(mem_addr),
        .wd(rd2_reg_q),
        .rd(mem_rd)
    );

    mc_reg instr_reg(
        .clk(clk),
        .reset(reset),
        .en(we_ir),
        .d(mem_rd),
        .q(instr)
    );

    mc_reg data_reg(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(mem_rd),
        .q(data_reg_q)
    );

    my_reg REGFILE(
        .clk(clk),
        .we(reg_we),
        .a1(instr[19:15]),
        .a2(instr[24:20]),
        .a3(instr[11:7]),
        .wd(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    mc_reg rd1_reg(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(rd1),
        .q(rd1_reg_q)
    );

    mc_reg rd2_reg(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(rd2),
        .q(rd2_reg_q)
    );

    sign_ext SIGN_EXT(
        .instr(instr[31:7]),
        .imm_src(sel_ext),
        .imm_ext(imm_ext)
    );

    mux4 #(32) ALU_SRC_A_MUX(
        .d0(pc_q),
        .d1(pc_old_q),
        .d2(rd1_reg_q),
        .d3(32'b0),
        .sel(sel_alu_src_a),
        .y(alu_src_a_data)
    );

    mux4 #(32) ALU_SRC_B_MUX(
        .d0(rd2_reg_q),
        .d1(imm_ext),
        .d2(32'd4),
        .d3(32'b0),
        .sel(sel_alu_src_b),
        .y(alu_src_b_data)
    );

    alu ALU(
        .a(alu_src_a_data),
        .b(alu_src_b_data),
        .alu_control(alu_control),
        .alu_result(alu_result),
        .zero(zero)
    );

    mc_reg alu_reg(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .d(alu_result),
        .q(alu_reg_q)
    );

    mux4 #(32) RESULT_MUX(
        .d0(alu_reg_q),
        .d1(data_reg_q),
        .d2(alu_result),
        .d3(imm_ext),
        .sel(sel_result),
        .y(result_mux_y)
    );

     // In S_JAL, PC is updated to the target precomputed in alu_reg.
    // JAL writes PC_old + 4 later in S_WB_DUMMY, so result does not need a special JAL override.
    assign result = result_mux_y;
    assign pc_plus4 = alu_result;
    assign pc_next = (state == 4'd11) ? alu_reg_q : result;


    controller CONTROLLER(
        .clk(clk),
        .reset(reset),
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7b5(instr[30]),
        .zero(zero),
        .we_pc(we_pc),
        .we_ir(we_ir),
        .we_mem(we_mem),
        .we_rf(we_rf),
        .branch(branch),
        .pc_update(pc_update),
        .sel_mem_addr(sel_mem_addr),
        .sel_result(sel_result),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .sel_ext(sel_ext),
        .alu_control(alu_control),
        .state(state)
    );
endmodule

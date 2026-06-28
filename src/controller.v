module controller(
    input  wire       clk,
    input  wire       reset,
    input  wire [6:0] op,
    input  wire [2:0] funct3,
    input  wire       funct7b5,
    input  wire       zero,
    output wire       we_pc,
    output wire       we_ir,
    output wire       we_mem,
    output wire       we_rf,
    output wire       branch,
    output wire       pc_update,
    output wire       sel_mem_addr,
    output wire [1:0] sel_result,
    output wire [1:0] sel_alu_src_a,
    output wire [1:0] sel_alu_src_b,
    output wire [2:0] sel_ext,
    output wire [3:0] alu_control,
    output wire [3:0] state
);
    wire [1:0] alu_op;

    main_decoder MAIN_DECODER(
        .clk(clk),
        .reset(reset),
        .op(op),
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
        .alu_op(alu_op),
        .state(state)
    );

    alu_decoder ALU_DECODER(
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .alu_control(alu_control)
    );
endmodule

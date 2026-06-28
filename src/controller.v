module controller(
    input  wire       clk,
    input  wire       reset,
    input  wire [6:0] op,
    input  wire [2:0] funct3,
    input  wire       funct7b5,
    input  wire       zero,
    output wire       we_pc,
    output wire       branch,
    output wire       we_ir,
    output wire       we_mem,
    output wire       we_rf,
    output wire       sel_mem_addr,
    output wire [1:0] sel_alu_src_a,
    output wire [1:0] sel_alu_src_b,
    output wire [2:0] sel_result,
    output wire [2:0] sel_ext,
    output wire [2:0] alu_control,
    output wire [3:0] state_dbg
);
    wire pc_update;
    wire [1:0] alu_op;

    fsm_controller FSM(
        .clk(clk), .reset(reset), .op(op),
        .pc_update(pc_update), .branch(branch), .we_ir(we_ir), .we_mem(we_mem), .we_rf(we_rf),
        .sel_mem_addr(sel_mem_addr), .sel_alu_src_a(sel_alu_src_a), .sel_alu_src_b(sel_alu_src_b),
        .alu_op(alu_op), .sel_result(sel_result), .state_dbg(state_dbg)
    );

    instr_decoder ID(.op(op), .sel_ext(sel_ext));

    alu_decoder AD(
        .alu_op(alu_op), .funct3(funct3), .funct7b5(funct7b5), .op(op), .alu_control(alu_control)
    );

    assign we_pc = pc_update | (branch & zero);
endmodule

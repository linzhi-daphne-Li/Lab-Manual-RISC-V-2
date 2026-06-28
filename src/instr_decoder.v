module instr_decoder(
    input  wire [6:0] op,
    output reg  [2:0] sel_ext
);
    localparam OP_LW     = 7'b0000011;
    localparam OP_SW     = 7'b0100011;
    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_LUI    = 7'b0110111;

    localparam EXT_I = 3'b000;
    localparam EXT_S = 3'b001;
    localparam EXT_B = 3'b010;
    localparam EXT_J = 3'b011;
    localparam EXT_U = 3'b100;

    always @(*) begin
        case (op)
            OP_LW:     sel_ext = EXT_I;
            OP_ITYPE:  sel_ext = EXT_I;
            OP_SW:     sel_ext = EXT_S;
            OP_BRANCH: sel_ext = EXT_B;
            OP_JAL:    sel_ext = EXT_J;
            OP_LUI:    sel_ext = EXT_U;
            OP_RTYPE:  sel_ext = EXT_I;
            default:   sel_ext = EXT_I;
        endcase
    end
endmodule

module alu_decoder(
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7b5,
    output reg  [3:0] alu_control
);
    localparam ALU_OP_ADD    = 2'b00;
    localparam ALU_OP_BRANCH = 2'b01;
    localparam ALU_OP_RTYPE  = 2'b10;
    localparam ALU_OP_ITYPE  = 2'b11;

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always @(*) begin
        case (alu_op)
            ALU_OP_ADD:    alu_control = ALU_ADD;
            ALU_OP_BRANCH: alu_control = ALU_SUB;
            ALU_OP_RTYPE: begin
                case (funct3)
                    3'b000: alu_control = funct7b5 ? ALU_SUB : ALU_ADD;
                    3'b001: alu_control = ALU_SLL;
                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;
                    3'b100: alu_control = ALU_XOR;
                    3'b101: alu_control = funct7b5 ? ALU_SRA : ALU_SRL;
                    3'b110: alu_control = ALU_OR;
                    3'b111: alu_control = ALU_AND;
                    default: alu_control = ALU_ADD;
                endcase
            end
            ALU_OP_ITYPE: begin
                case (funct3)
                    3'b000: alu_control = ALU_ADD;
                    3'b001: alu_control = ALU_SLL;
                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;
                    3'b100: alu_control = ALU_XOR;
                    3'b101: alu_control = funct7b5 ? ALU_SRA : ALU_SRL;
                    3'b110: alu_control = ALU_OR;
                    3'b111: alu_control = ALU_AND;
                    default: alu_control = ALU_ADD;
                endcase
            end
            default: alu_control = ALU_ADD;
        endcase
    end
endmodule

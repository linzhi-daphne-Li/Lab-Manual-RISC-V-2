module alu_decoder(
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7b5,
    input  wire [6:0] op,
    output reg  [2:0] alu_control
);
    localparam OP_RTYPE = 7'b0110011;

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_SLT = 3'b101;

    always @(*) begin
        case (alu_op)
            2'b00: alu_control = ALU_ADD; // address/PC calculation
            2'b01: alu_control = ALU_SUB; // branch compare
            2'b10: begin
                case (funct3)
                    3'b000: alu_control = (funct7b5 && (op == OP_RTYPE)) ? ALU_SUB : ALU_ADD;
                    3'b010: alu_control = ALU_SLT;
                    3'b110: alu_control = ALU_OR;
                    3'b111: alu_control = ALU_AND;
                    default: alu_control = ALU_ADD;
                endcase
            end
            default: alu_control = ALU_ADD;
        endcase
    end
endmodule

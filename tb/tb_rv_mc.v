`timescale 1ns/1ps

module tb_rv_mc;
    reg clk;
    reg reset;

    rv_mc dut(
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;

        $readmemh("programs/program.hex", dut.IMEM.RAM);

        $dumpfile("rv_mc.vcd");
        $dumpvars(0, tb_rv_mc);

        #12;
        reset = 1'b0;

        #600;

        $display("x1  = %0d", dut.REGFILE.RF[1]);
        $display("x2  = %0d", dut.REGFILE.RF[2]);
        $display("x3  = %0d", dut.REGFILE.RF[3]);
        $display("MEM[0] = %0d", dut.IMEM.RAM[0]);
        $display("x13 = %0d", dut.REGFILE.RF[13]);
        $display("x14 = 0x%08h", dut.REGFILE.RF[14]);
        $display("x16 = 0x%08h", dut.REGFILE.RF[16]);
        $display("x18 = %0d", dut.REGFILE.RF[18]);

        if (dut.REGFILE.RF[1]  !== 32'd5)        $fatal(1, "x1 check failed");
        if (dut.REGFILE.RF[2]  !== 32'd10)       $fatal(1, "x2 check failed");
        if (dut.REGFILE.RF[3]  !== 32'd15)       $fatal(1, "x3 check failed");
        if (dut.IMEM.RAM[0]    !== 32'd15)       $fatal(1, "memory check failed");
        if (dut.REGFILE.RF[13] !== 32'd15)       $fatal(1, "x13 check failed");
        if (dut.REGFILE.RF[14] !== 32'h12345000) $fatal(1, "x14 check failed");
        if (dut.REGFILE.RF[16] !== 32'd32)       $fatal(1, "x16 check failed");
        if (dut.REGFILE.RF[18] !== 32'd42)       $fatal(1, "x18 check failed");

        $display("PASS: multi-cycle RISC-V result matches the single-cycle test program.");
        $finish;
    end
endmodule

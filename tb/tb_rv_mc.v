`timescale 1ns/1ps
module tb_rv_mc;
    reg clk;
    reg reset;

    rv_mc dut(.clk(clk), .reset(reset));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("rv_mc.vcd");
        $dumpvars(0, tb_rv_mc);

        // The memory module has no initial block; the testbench loads the program hierarchically.
        $readmemh("programs/program.hex", dut.MEM.RAM);

        reset = 1'b1;
        #22;
        reset = 1'b0;

        repeat (80) @(posedge clk);

        $display("x1  = %0d", dut.RF.RF[1]);
        $display("x2  = %0d", dut.RF.RF[2]);
        $display("x3  = %0d", dut.RF.RF[3]);
        $display("MEM[0] = %0d", dut.MEM.RAM[0]);
        $display("x13 = %0d", dut.RF.RF[13]);
        $display("x14 = 0x%08h", dut.RF.RF[14]);
        $display("x15 = %0d (should be 0, skipped by BEQ)", dut.RF.RF[15]);
        $display("x16 = %0d (JAL return address)", dut.RF.RF[16]);
        $display("x17 = %0d (should be 0, skipped by JAL)", dut.RF.RF[17]);
        $display("x18 = %0d", dut.RF.RF[18]);

        if (dut.RF.RF[1]  !== 32'd5)        $fatal(1, "x1 wrong");
        if (dut.RF.RF[2]  !== 32'd10)       $fatal(1, "x2 wrong");
        if (dut.RF.RF[3]  !== 32'd15)       $fatal(1, "x3 wrong");
        if (dut.MEM.RAM[0] !== 32'd15)      $fatal(1, "MEM[0] wrong");
        if (dut.RF.RF[13] !== 32'd15)       $fatal(1, "x13 wrong");
        if (dut.RF.RF[14] !== 32'h12345000) $fatal(1, "x14 wrong");
        if (dut.RF.RF[15] !== 32'd0)        $fatal(1, "x15 should be skipped");
        if (dut.RF.RF[16] !== 32'd36)       $fatal(1, "x16 JAL return wrong");
        if (dut.RF.RF[17] !== 32'd0)        $fatal(1, "x17 should be skipped");
        if (dut.RF.RF[18] !== 32'd42)       $fatal(1, "x18 wrong");

        $display("PASS: multi-cycle RISC-V test completed.");
        $finish;
    end
endmodule

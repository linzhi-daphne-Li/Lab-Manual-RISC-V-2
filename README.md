# RISC-V-2 Multi-cycle Processor

This project combines the naming style from the uploaded single-cycle report with the new multi-cycle requirements from the RISC-V-2 lab manual.

## Main rules used

- Multi-cycle top module: `rv_mc`.
- Reused single-cycle module names: `pc`, `adder`, `mux2`, `mux4`, `my_reg`, `my_mem`, `sign_ext`, `alu`, `main_decoder`, `alu_decoder`, `controller`.
- New multi-cycle control/data signals: `we_pc`, `we_ir`, `we_mem`, `we_rf`, `sel_mem_addr`, `sel_result`, `sel_alu_src_a`, `sel_alu_src_b`, `sel_ext`, `pc_update`, `branch`.
- New multi-cycle registers: `PC_reg`, `instr_reg`, `data_reg`, `rd1_reg`, `rd2_reg`, `alu_reg`.
- One shared memory is used, because the RISC-V-2 lab manual states that instruction fetch and data access happen in different cycles.
- The shared memory instance is named `IMEM`, and the memory array is named `RAM`, so the testbench can load the program with `dut.IMEM.RAM`.
- Register file instance is `REGFILE`, and its array is named `RF`.

## Test program

The test program is exactly the one listed in the uploaded single-cycle report:

```asm
addi x1, x0, 5
addi x2, x0, 10
add x3, x1, x2
sw x3, 0(x0)
lw x13, 0(x0)
lui x14, 0x12345
beq x3, x13, label
label:
jal x16, end
end:
addi x18, x0, 42
```

No extra self-created instructions were added.

## Run

```bash
iverilog -g2012 -o sim tb/tb_rv_mc.v src/*.v
vvp sim
```

Or:

```bash
./run_iverilog.sh
```

## Expected results

- `x1 = 5`
- `x2 = 10`
- `x3 = 15`
- `IMEM.RAM[0] = 15` after `sw x3, 0(x0)`
- `x13 = 15`
- `x14 = 0x12345000`
- `x16 = 32`, because `jal x16, end` is at PC `28`, so link value is `PC + 4 = 32`
- `x18 = 42`

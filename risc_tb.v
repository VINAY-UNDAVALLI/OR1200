
`timescale 1ns/1ps

module tb;

reg clk;
reg rst;

// Instantiate the CPU
simple_openrisc_cpu DUT (
    .clk(clk),
    .rst(rst)
);

// Clock generation (100 MHz)
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test sequence
initial begin
    $dumpfile("risc_tb.vcd");
    $dumpvars(0, tb);

    rst = 1;
    #20;
    rst = 0;

    // Run simulation
    #200;

    $display("-----------------------------");
    $display("Register Values");
    $display("R1 = %0d", DUT.regfile[1]);
    $display("R2 = %0d", DUT.regfile[2]);
    $display("R3 = %0d", DUT.regfile[3]);
    $display("R4 = %0d", DUT.regfile[4]);
    $display("Memory[0] = %0d", DUT.dmem[0]);
    $display("-----------------------------");

    $finish;
end

endmodule

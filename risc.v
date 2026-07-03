
`timescale 1ns/1ps
//====================================================
// Simple OpenRISC-Inspired 32-bit CPU (Educational)
// Logic only - No testbench
//====================================================
module simple_openrisc_cpu(
    input clk,
    input rst
);

reg [31:0] pc;
reg [31:0] imem[0:255];
reg [31:0] dmem[0:255];
reg [31:0] regfile[0:31];

reg [31:0] if_instr,id_instr,ex_instr,mem_instr,wb_instr;
reg [31:0] if_pc,id_pc,ex_pc,mem_pc,wb_pc;

wire [5:0] opcode = id_instr[31:26];
wire [4:0] rs = id_instr[25:21];
wire [4:0] rt = id_instr[20:16];
wire [4:0] rd = id_instr[15:11];
wire [15:0] imm = id_instr[15:0];

reg [31:0] alu_result;
reg [31:0] mem_data;

integer i;

initial begin
    pc = 0;
    for(i=0;i<32;i=i+1) regfile[i]=0;
    for(i=0;i<256;i=i+1) begin
        imem[i]=0;
        dmem[i]=0;
    end

    // Demo program
    imem[0]=32'h20010005; // addi r1,r0,5
    imem[1]=32'h20020003; // addi r2,r0,3
    imem[2]=32'h00221820; // add r3,r1,r2
    imem[3]=32'hac030000; // sw r3,0(r0)
    imem[4]=32'h8c040000; // lw r4,0(r0)
end

always @(posedge clk or posedge rst) begin
    if(rst)
        pc <= 0;
    else begin
        // IF
        if_pc <= pc;
        if_instr <= imem[pc[9:2]];
        pc <= pc + 4;

        // ID
        id_pc <= if_pc;
        id_instr <= if_instr;

        // EX
        ex_pc <= id_pc;
        ex_instr <= id_instr;

        case(opcode)
            6'b001000: alu_result <= regfile[rs] + {{16{imm[15]}},imm};
            6'b000000:
                case(id_instr[5:0])
                    6'h20: alu_result <= regfile[rs] + regfile[rt];
                    6'h22: alu_result <= regfile[rs] - regfile[rt];
                    6'h24: alu_result <= regfile[rs] & regfile[rt];
                    6'h25: alu_result <= regfile[rs] | regfile[rt];
                    default: alu_result <= 0;
                endcase
            6'h23,6'h2B: alu_result <= regfile[rs] + {{16{imm[15]}},imm};
            default: alu_result <= 0;
        endcase

        // MEM
        mem_pc <= ex_pc;
        mem_instr <= ex_instr;

        case(ex_instr[31:26])
            6'h23: mem_data <= dmem[alu_result[9:2]];
            6'h2B: dmem[alu_result[9:2]] <= regfile[ex_instr[20:16]];
        endcase

        // WB
        wb_pc <= mem_pc;
        wb_instr <= mem_instr;

        case(mem_instr[31:26])
            6'b001000: regfile[mem_instr[20:16]] <= alu_result;
            6'h23:     regfile[mem_instr[20:16]] <= mem_data;
            6'b000000: regfile[mem_instr[15:11]] <= alu_result;
        endcase
    end
end

endmodule

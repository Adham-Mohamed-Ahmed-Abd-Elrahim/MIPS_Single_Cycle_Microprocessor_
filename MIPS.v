module MIPS 
#(parameter instr_width=32,data_width=32,op_width=5 ,test_value_width=16,width_alu_control=3)
(
    input clk ,
    input reset ,
    output [test_value_width-1:0] test_value
);
//internal_signals 
wire [instr_width-1:0] pc;
wire [instr_width-1:0] instruction;
wire zero,mem2reg,mem_wr,alu_src,reg_dst,reg_wr,jmp,pc_src ;
wire  [width_alu_control-1:0] alu_control;
wire  [data_width-1:0] read_data ; //from data_memory 
wire  [data_width-1:0] alu_out ; //from alu to data_mem
wire  [data_width-1:0] write_data ; //RD2 from reg_file to be written in data_mem
//***************instruction_memory *************
ins_memory /*#(.width(32) , .addr(32) ,.depth(128) )*/ ins_mem  
 //depth is only for testing ,real=2**addr
( .pc_in(pc),
  .instruction(instruction) 
);
//***************Data_memory ********************
data_memory /*#(.width(32),.depth(256),.addr(32),.test_width(16))*/ data_mem
(
   .clk(clk),
   .rst(reset) ,
   .WE(mem_wr),
   .read_addr(alu_out),//for alu result 
   .W_data(write_data),//for memory write
   .RD_out(read_data), //read output 
   .test_value(test_value) 
);
//***************control_unit*************
control_unit /*#(.width_code(6),width_alu_control(3)) */control_unt

( .op_code(instruction[31:26]),
.func(instruction[5:0]),
 .zero(zero),
.alu_control(alu_control),
.mem2reg(mem2reg),
 .mem_wr(mem_wr),
.alu_src(alu_src),
 .reg_dst(reg_dst),
 .reg_wr(reg_wr),
.jmp(jmp) ,
.pc_src(pc_src) //zero_flag
);
 data_path /*#(.instr_width(32),.data_width(32),.op_width(5))*/ data_pth

(  .clk(clk),
  .reset(reset) ,
 .instruction(instruction), //instruction word
 .read_data(read_data), //data read from data_mem
  //control signals 
 .alu_ctrl(alu_control), //alu control w=3bits 
 .pc_src(pc_src) ,//w=1
.mem2reg(mem2reg),//w=1
 .alu_src(alu_src),//w=1
 .reg_dst(reg_dst),//w=1
.reg_wr(reg_wr),//w=1
.jmp(jmp),//w=1
//outputs 
 .zero(zero),//zero flag 
.pc(pc), //w=32
.alu_output(alu_out),//w=32
.write_data(write_data) //w=32 
);
endmodule 
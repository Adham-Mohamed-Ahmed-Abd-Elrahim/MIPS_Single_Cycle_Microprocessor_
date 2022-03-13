module data_path 
#(parameter instr_width=32,data_width=32,op_width=5)
( input clk,
  input reset ,
  input [instr_width-1:0] instruction, //instruction word
  input [data_width-1:0] read_data, //data read from data_mem
  //control signals 
  input [2:0] alu_ctrl, //alu control w=3bits 
  input pc_src ,//w=1
input  mem2reg,//w=1
input  alu_src,//w=1
input  reg_dst,//w=1
input reg_wr,//w=1
input jmp,//w=1
//outputs 
output zero,//zero flag 
output [instr_width-1:0] pc, //w=32
output [data_width-1:0] alu_output,//w=32
output [data_width-1:0] write_data //w=32 
);
//internal signals 
wire [op_width-1:0] w_op ; //write operand in reg file 
wire [data_width-1:0] w_data;//write data to reg_file
wire [data_width-1:0] RD1,RD2;//outs from reg_file ----------
wire [data_width-1:0] alu_out ;
wire [data_width-1:0] alu_in2;
wire [data_width-1:0] sign_extend ;//------------
wire [instr_width-1:0] pc_in;
wire [instr_width-1:0] pc_out;
wire [instr_width-1:0] pc_pls4;
wire [instr_width-1:0] pc_branch;
wire [instr_width-1:0] sign_extend_shft;
wire [instr_width-1:0] pc_mux1_out;
//assignments 
assign pc =pc_out ;
assign alu_output =alu_out;
assign write_data =RD2 ;
pc /* #(.width(instr_width))*/ prog_count //program counter with pipe reg 
( .clk(clk) ,
.reset(reset) ,
.pc_in(pc_in),
.pc_out(pc_out)
);
PC_Adder /*#(.ins_width (instr_width))*/ pc_adder

(
.PC_in(pc_out),
.PC_out(pc_pls4) 

);
shift_left /*#(parameter width=instr_width)*/ shft_lft_2
(.in(sign_extend),
.out(sign_extend_shft)
);

adder /*#(.width(instr_width))*/ adder_pc_branch
(.in_0(sign_extend_shft),
 .in_1(pc_pls4),
 .out(pc_branch) 
);

mux #(.width(instr_width)) mux_pc_src
(.in_0(pc_pls4),
 .in_1(pc_branch),
 .sel(pc_src),
 .out (pc_mux1_out)
);

mux #(.width(instr_width)) mux_pc_jmp
(.in_0(pc_mux1_out),
 .in_1({pc_pls4[31:28],instruction[25:0],2'b00}),
 .sel(jmp),
 .out (pc_in)
);


//******************Reg_File**********************
Reg_file /*#(.width(data_width),.depth(32),.op_width(op_width))*/ reg_file
(.clk(clk),
 .reset(reset) ,
 .WE(reg_wr) , //write enable 
 .R_op1(instruction[25:21]),//read operand
 .R_op2(instruction[20:16]), //read operand
 .W_op(w_op), //write operand
 .W_data(w_data), //Date to be written
 .RD1(RD1), //outread 1 
 .RD2(RD2) //outread 2 
);
//muxes for register file 
mux #(.width(5)) mux_reg_dst
(.in_0(instruction[20:16]),
 .in_1(instruction[15:11]),
 .sel(reg_dst),
 .out (w_op)
);

 mux #(.width(32)) mux_mem2reg
(.in_0(alu_out),
 .in_1(read_data),
 .sel(mem2reg),
 .out (w_data)
);
//***************************************
//******************ALU**********************
ALU alu
/*#(.width(data_width))*/
(.op1(RD1) ,
.op2(alu_in2),
.ALU_control(alu_ctrl) ,
.result(alu_out) ,
.zero(zero) //zero_Flag
);
mux #(.width(32)) mux_alu_src
(.in_0(RD2),
 .in_1(sign_extend),
 .sel(alu_src),
 .out (alu_in2)
);
sign_extention sign_exten
/*#(.in_width(16),.out_width(32))*/
( .in(instruction[15:0]),
.out(sign_extend) 
);
endmodule 
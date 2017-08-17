/*
* Group no:14
* Assembled processor
*
* Here clock was used only in Program Counter. 
* This is a single cycle processor.
* So, @ rising edge , @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


*/


// assembled processor module
module Processor();

// initializing clock
	reg clock;


	initial
	clock = 1'b0;

	always
	#5 clock = ~clock;
	
//PC - call the program counter module
	wire [15:0]In;  //  Input for the pc
	wire [15:0] out; // output of the pc
	PC pc1(out,clock,In);
	
	
// call the Instruction Memory module
	wire [15:0]Instruction;
	Instruction_Mem Instruction_Mem1(Instruction,out);
	
	
//call the Controller module
	//  These 9 wires are outputs of controller module
	wire regDst,branch,Memread,MemtoReg,ALUop,Memwrite,ALUsrc,regWrite,jump;
	control mainController(Instruction[15:12],regDst,branch,Memread,MemtoReg,ALUop,Memwrite,ALUsrc,regWrite,jump);
	
	
// call 2 to 1 multiplexer	--------- Mux1
	wire writeReg; // output of mux1
	// mux2_to_1(out,i0,i1,s0) - s0 is the control input for mux
	mux2_to_1 mux1(writeReg,Instruction[3:0], Instruction[11:8],regDst);
	
	
	
// call the register file module	
	wire readData1,readData2; // outputs of register file
	wire writeData;           // input for register file - It stores data which is going to write in destination register
	registerFile registerfile1(readData1,readData2,Instruction[7:4],Instruction[3:0],writeReg,writeData,regWrite);

	
// call the Sign Extender
	wire [15:0] extendedOffset;
	signExtend SE(extendedOffset,Instruction[11:8]);
	
	
// call 2 to 1 multiplexer	--------- Mux2
	wire [15:0] ALUoperand2; // output of mux2 = 2nd operand(input) of ALU
	mux2_to_1 mux2(ALUoperand2,readData2, extendedOffset,ALUsrc);
	
	
//call the ALU module------- Main ALU
	wire lt,eq,gt,overflow,c_out,zero;
	wire [15:0] Datamemadr; // 1 output of ALU -- this is the address for data memory
	alu ALU(c_out,Datamemadr,zero,lt,eq,gt,overflow,readData1,ALUoperand2,ALUop);
	
	
// call the Data-Memory module
	wire [15:0] ReadData; // output for data memory
	DataMem dataMemory(ReadData,memRead,memWrite,Datamemadr,readData2);
	
	
// call 2 to 1 multiplexer	------------- Mux3
	mux2_to_1 mux3(writeData,Datamemadr, ReadData,MemtoReg);
	
	
// AND gate 
	wire mux4Control;  // output of the AND gate =  control input  of the Mux4
	and(mux4Control,branch,zero);
	
	
// call the adder module ---------------- Adder 1
	// pc should be updated by adding 1 byte
	// our pc is not byte addressable, unit address of pc = memory address size @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	wire [15:0] adder2operand1;
	adder adder1(adder2operand1,out, 16'h1);
	
	
//  call the jump address generator
	// It concatenates the addresses and makes the jumping address
	wire [15:0] mux5_i1; 
	jumpAddress jumpadr(mux5_i1,Instruction[11:0],adder2operand1[15:13]);
	
	
// call the adder module ---------------- Adder 2
	wire mux4_i1;
	adder adder2(mux4_i1,adder2operand1,extendedOffset);
	
	
// call 2 to 1 multiplexer	------------- Mux4
	wire mux5_i0;
	mux2_to_1 mux4(mux5_i0,adder2operand1, mux4_i1,mux4Control);
	
	
// call 2 to 1 multiplexer	------------- Mux5
	mux2_to_1 mux5(In,mux5_i0, mux5_i1,jump);

endmodule


//   INSTRUCTION MEMORY   
module Instruction_Mem(Instruction,Iaddr);

	// output of the Program Counter
	input [15:0] Iaddr;
	
	output [15:0] Instruction;
	
	// register file 
	reg[15:0] myreg[256:0];
	// Temporary registers
	reg [15:0] temp;
	

	always@(Iaddr)
	begin
		
		myreg [0]=16'h2301;
		temp=myreg[Iaddr];
		
	end
	
	assign Instruction=temp;
	
endmodule




//    ADDER	
module adder(sum,a, b);
	
	// I/O port declarations
	output [15:0] sum;
	input[15:0] a, b;
		
	assign sum = a + b ;	
	
endmodule



//     LEFT SHIFT (1 bit)
module left_shift1(shiftedOffset,offset);
	
	// I/O port declarations
	input [15:0]offset;
	output [15:0]shiftedOffset;
	
	reg [15:0]Temp;
	
	always @(offset)
	begin
		//Temp={offset[14:0],0};
		Temp=offset << 1;
	
	end
	
	assign shiftedOffset=Temp;

endmodule



//   JUMP ADDRESS GENERATOR
module jumpAddress(out,ins,pc);
	//// I/O port declarations
	input [2:0]pc;
	input [11:0]ins;

	output [15:0]out;
	// temporary register
	reg [15:0]temp;

	always @(pc,ins)
	begin
		temp[15:13]=pc;
		temp[12:1]=ins;
		temp[0]=1'b0;
	end

	assign out=temp;
	
endmodule



//   DATA MEMORY
module DataMem(readData,memRead,memWrite,address,writeData);

	input memRead,memWrite;
	input [15:0]address,writeData;

	output [15:0]readData;

	reg[15:0] myreg[255:0];
	reg [15:0]Temp; 

	always @(memWrite,memRead,address,writeData)
	begin
	
		//write to the data memory
		if(memWrite==1)
		begin
			myreg[address]=writeData;
		end
		
		//read from the data memory

		if(memRead==1)
		begin
			Temp=myreg[address];
		end
	end

	assign readData=Temp;	
		
endmodule



//  ALU 
module alu(c_out,z,zero,lt,eq,gt,overflow,x,y,c);
  input signed [15:0] x,y;   // x & y are signed numbers
  input [2:0] c;             // Op Code
  
  output [15:0] z;			 // output of the operation 
  output zero;               // output of ALU -- used in branch instructions 
  output c_out,overflow,lt,gt,eq;
  
  // Temporary registers
  reg [15:0] ztemp;
  reg zeroTemp;
  reg c_out_temp,overflow_temp,lt_temp,gt_temp,eq_temp;

  always @(c,x,y)
  begin
  
  
	//to determine the two numbers are equal or less than or greater than
   
    begin
      if(x<y)
        begin
        lt_temp=1'b1;
        gt_temp=1'b0;
        eq_temp=1'b0;
      end
	  
	  else if(x>y)
      begin
        lt_temp=1'b0;
        gt_temp=1'b1;
        eq_temp=1'b0;
      end
	  
      else
      begin
        lt_temp=1'b0;
        gt_temp=1'b0;
        eq_temp=1'b1;
      end
      
    end
    
    
		case(c)
		  3'b000://and operation
		  begin
			ztemp=x & y;
			
			zeroTemp=1'b0;
			c_out_temp=1'b0;
			overflow_temp=1'b0; 
		  end
		  
		  3'b001://or operation
		  begin
			ztemp=x | y;
			zeroTemp=1'b0;
			c_out_temp=1'b0;
			overflow_temp=1'b0;
		  end
		  
		  
		  3'b010://add operation 
		  begin 
			ztemp=x+y;
			zeroTemp=1'b0;
			c_out_temp=16'h0;
			overflow_temp=c_out_temp;
		  end
		  
		  3'b011:// Subtract operation
		  begin
			{c_out_temp,ztemp}=x-y;
				if(lt_temp==1'b1 | gt_temp==1'b1)//change here to temp values
				begin
				zeroTemp=1'b1;
				end
				
				else
				begin
				zeroTemp=1'b0;
				end
			
			overflow_temp=c_out_temp;        
		  end
		  
		  3'b111://set less than
		  begin
			if(lt==1'b1)
			begin
				ztemp=16'd1;
			   
			end
			  
			else
			begin
				ztemp=16'd0;
			end
			  
			 zeroTemp=1'b0; 
			 c_out_temp=1'b0;
			 overflow_temp=1'b0;
			  
		  end
		  
		  3'b100://add for unsigned numbers
		  begin
		  
		  end
		  
		  default:
		  $display("INVALID ALU OPCODE");
	   endcase 
    
  end
  
  assign z=ztemp;
  assign zero=zeroTemp;
  assign c_out= c_out_temp;
  assign  overflow=overflow_temp;
  assign lt=lt_temp;
  assign gt=gt_temp;
  assign eq=eq_temp;
 
 endmodule 


 
 //   SIGN EXTENDER
module signExtend(offset_16,offset_4);

	input [3:0]offset_4;
	output [15:0]offset_16;
	
	reg [15:0]extended;

	always @(offset_4)
	begin
		extended[3:0] = offset_4[3:0];
		extended[15:4] = {12 {offset_4[3]} };
	end
	
	assign offset_16=extended;

endmodule




//   PROGRAM COUNTER
module PC(Out,clk,In);
		
      output [15:0] Out;
	  
	  input [15:0] In;
      input clk;    // clock
  
      reg [15:0] Out;
 
	always @(posedge clk)
	begin
		if (In>=0)
		begin
    		Out = In;
		end 
		
		else  
		begin
		Out = 16'h0;
		end
	end

endmodule



//          REGISTER FILE
module registerFile(readData1,readData2,readReg1,readReg2,writeReg,writeData,RegWrite);

	input [15:0]writeData;
	input [3:0]readReg1,readReg2,writeReg;
	input RegWrite;
	
	output [15:0]readData1,readData2;

	reg[15:0] myreg[15:0];
	reg [15:0] tmp1,tmp2;
	
	always @(readReg1,readReg2,writeReg,writeData,RegWrite)
	begin
		
		if(RegWrite==1)
		begin
			myreg[writeReg]=writeData;
			tmp1=myreg[readReg1];
			tmp2=myreg[readReg2];
		end
	
	end
	
	assign readData1=tmp1;
  	assign readData2=tmp2;
	
endmodule



//     CONTROLLER
module control(opCode,regDst1,branch1,Memread1,MemtoReg1,ALUop1,Memwrite1,ALUsrc1,regWrite1,jump1);
	input [3:0] opCode;
	
	output regDst1,branch1,Memread1,Memwrite1,ALUsrc1,regWrite1,jump1,MemtoReg1;
	output[2:0] ALUop1;
	
	reg regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg;
	reg[2:0] ALUop;
	
	always @(opCode)	
	begin 
		case(opCode)
		
			//controller outputs for R-type operations
			
			
			//add
			4'h2:
			begin 
			regDst=1'b1;
			branch=1'b0;
			Memread=1'b0;
			Memwrite=1'b0;
			MemtoReg=1'b0;
			ALUsrc=1'b0;
			regWrite=1'b1;
			jump=1'b0;
			ALUop=3'b010;
			end
			
			
			//sub
			4'h6:
			begin 
			regDst=1'b1;
			branch=1'b0;
			Memread=1'b0;
			Memwrite=1'b0;
			MemtoReg=1'b0;
			ALUsrc=1'b0;
			regWrite=1'b1;
			jump=1'b0;
			ALUop=3'b011;
			end
			//and
			4'h0:
			begin 
			regDst=1'b1;
			branch=1'b0;
			Memread=1'b0;
			Memwrite=1'b0;
			MemtoReg=1'b0;
			ALUsrc=1'b0;
			regWrite=1'b1;
			jump=1'b0;
			ALUop=3'b000;
			end
			
			
			//or
			4'h1:
			begin 
			regDst=1'b1;
			branch=1'b0;
			Memread=1'b0;
			Memwrite=1'b0;
			MemtoReg=1'b0;
			ALUsrc=1'b0;
			regWrite=1'b1;
			jump=1'b0;
			ALUop=3'b001;
			end
			
			
			//set less than
			4'h7:
			begin 
			regDst=1'b1;
			branch=1'b0;
			Memread=1'b0;
			Memwrite=1'b0;
			MemtoReg=1'b0;
			ALUsrc=1'b0;
			regWrite=1'b1;
			jump=1'b0;
			ALUop=3'b111;
			end
			
			
			//lw
			4'h8:
			begin 
			regDst=1'b0;//i change this to zero
			branch=1'b0;
			Memread=1'b1;
			Memwrite=1'b0;
			MemtoReg=1'b1;
			ALUsrc=1'b1;
			regWrite=1'b1;
			jump=1'b0;
			ALUop=3'b010;
			end
			
			
			//sw
			4'ha:
			begin 
			//regDst=1'b0;
			branch=1'b0;
			Memread=1'b0;
			Memwrite=1'b1;
			//MemtoReg=1'b0;
			ALUsrc=1'b1;
			regWrite=1'b0;
			jump=1'b0;
			ALUop=3'b010;
			end
			
			
			//branch not equal
			4'he:
			begin 
			//regDst=1'b1;//dont care
			branch=1'b1;
			Memread=1'b0;//dont care
			Memwrite=1'b0;//dc
			MemtoReg=1'b0;
			ALUsrc=1'b1;//change here 
			regWrite=1'b0;//dc
			jump=1'b0;
			ALUop=3'b011;
			end
			
			//jump
			4'hf:
			begin 
			//regDst=1'b1;
			branch=1'b0;
			Memread=1'b0;
			Memwrite=1'b0;
			//MemtoReg=1'b0;
			//ALUsrc=1'b0;
			regWrite=1'b0;
			jump=1'b1;
			//ALUop=3'b011;
			end
			
			default:
			$disply("INVALID OPCODE");
		endcase
		
	end
	
	assign regDst1=regDst;
	assign	branch1=branch;
	assign	Memread1=Memread;
	assign	Memwrite1=Memwrite;
	assign	MemtoReg1=MemtoReg;
	assign ALUsrc1=ALUsrc;
	assign	regWrite1=regWrite;
	assign jump1=jump;
	assign	ALUop1=ALUop;
	
endmodule




//   2 TO 1 MULTIPLEXER
module mux2_to_1 (out, i0, i1,s0);
	
	// Port declarations from the I/O diagram
	output out;
	
	input i0, i1;
	input s0;
	// Internal wire declarations
	reg tempout;
	
	always @(s0,i0,i1)
	begin	
	
		if (s0==1'b0)
			tempout = i0;
		else
			tempout = i1;

		end	
	
	assign out=tempout;
	
endmodule


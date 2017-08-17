//Test bench for controller
module test;

reg [3:0] opCode;
reg clock;
wire regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg;
wire [2:0] ALUop;

control c(opCode,clock,regDst,branch,Memread,MemtoReg,ALUop,Memwrite,ALUsrc,regWrite,jump);


initial 
begin

//AND operation instruction opcode,gives the output 10000000001
opCode=4'd0;clock=0;clock=1;
#1 $display("OP Code(AND) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);

//OR operation instruction opcode, gives the output 10000001001

opCode=4'd1;//clock=0;clock=1;
#1 $display("OP Code(OR) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);
//Add operation instruction opcode,gives the output 10000010001
opCode=4'd2;//clock=0;clock=1;
#1 $display("OP Code(ADD) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);

//Sub operation instruction opcode,gives the output 10000011001
opCode=4'd6;//clock=0;clock=1;
#1 $display("OP Code(SUB) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);

//SLT operation instruction opcode,,gives the output 10000111001
opCode=4'd7;//clock=0;clock=1;
#1 $display("OP Code(SLT) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);
//LW operation instruction opcode,gives the output 00011010011
opCode=4'd8;//clock=0;clock=1;
#1 $display("OP Code(LW) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);
//SW operation instruction opcode,gives the output x000x010110
opCode=4'd10;//clock=1;clock=0;clock=1;
#1 $display("OP Code(SW) : %4h",opCode);
#1 $display("Control output =\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);
//BNE operation instruction opcode, gives the output x010x011000
opCode=4'd14;//clock=0;clock=1;
#1 $display("OP Code(BNE) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);

//JMP operation instruction opcode,gives the output x100xxxx0x0
opCode=4'd15;//clock=0;clock=1;
#1 $display("OP Code(JUMP) : %4h",opCode);
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);

//When clock is zero the output from the control unit does not change.
opCode=4'd14;clock=0;//clock=1;
#1 $display("Control output=\n regDst: %1b \t branch: %1b \tMemread:%1b \tMemwrite:%1b\t ALUsrc:%1b\t regWrite:%1b \tjump:%1b\t MemtoReg:%1b \tALUop:%3b",regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg,ALUop);
end

endmodule



//module controller
module control(opCode,clock,regDst1,branch1,Memread1,MemtoReg1,ALUop1,Memwrite1,ALUsrc1,regWrite1,jump1);
	input [3:0] opCode;
	input clock;
	output regDst1,branch1,Memread1,Memwrite1,ALUsrc1,regWrite1,jump1,MemtoReg1;
	output[2:0] ALUop1;
	
	
	reg regDst,branch,Memread,Memwrite,ALUsrc,regWrite,jump,MemtoReg;
	reg[2:0] ALUop;
	
	

	always @(posedge clock,opCode)	

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
			regDst=1'b0;
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
			//dont cares are commented
			4'hf:
			begin 
			//regDst=1'b0;
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
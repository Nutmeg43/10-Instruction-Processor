class processor_instruction_seq extends uvm_sequence_item;
    `uvm_object_utils(processor_instruction_seq)
    
    //Opcode enums
    localparam NOP = 4'b0000;
    localparam LD  = 4'b0001;
    localparam STR = 4'b0010;
    localparam BRA = 4'b0011;
    localparam XOR = 4'b0100;
    localparam ADD = 4'b0101;
    localparam SHL = 4'b0110;
    localparam SHR = 4'b0111;
    localparam HLT = 4'b1000;
    localparam CMP = 4'b1001;
    
    //Condition code enums
    localparam ALWAYS = 4'b0000;
    localparam PARITY = 4'b0001;
    localparam EVEN   = 4'b0010;
    localparam CARRY  = 4'b0011;
    localparam NEG    = 4'b0100;
    localparam ZERO   = 4'b0101;
    localparam NCARRY = 4'b0110;
    localparam POS    = 4'b0111;
    
    rand logic              reset;
    rand logic [3:0]        opcode;
    rand logic              src_type;
    rand logic              dest_type;
    rand logic [3:0]        condition_code;
    rand logic [11:0]       src_address;
    rand logic [11:0]       dest_address;
    rand logic [31:0]       ram_init_wadrs;
    rand logic              initialize_instructions; 
    
    logic [31:0]            ram_write_instruction;
    logic [2:0]             cur_state;   
    logic                   cur_halt;  
    logic [31:0]            cur_result;
    logic [31:0]            cur_instruction;
    logic                   cur_branch_valid;
    logic [4:0]             cur_status;


    //Constrain src address
    constraint default_src_address{
        solve opcode before src_address;
        if (opcode == SHL || opcode == SHR){
            src_address <= 16;
        }
        src_address <= 31;
    }
    
    //Constrain dest address
    constraint default_dest_address{
        dest_address <= 31;
    }

    //Constrain opcode weighted
    constraint default_opcode{
        opcode dist{
            NOP := 1,
            LD  := 25,
            STR := 25,
            BRA := 5,
            XOR := 15,
            ADD := 20,
            SHL := 20,
            SHR := 20,
            HLT := 1,
            CMP := 20
        };
    }
    
    //Constrain default condition code, if opcode is branch
    constraint default_condition_code{
        condition_code dist{
            ALWAYS := 50,
            PARITY := 50,
            EVEN   := 5,
            CARRY  := 5,
            NEG    := 5,
            ZERO   := 5,
            NCARRY := 10,
            POS    := 10
        };
    }
    
    //Constrain source destination based on opcode
    constraint default_src_type{
        solve opcode before src_type;
        if(opcode inside {LD, XOR, ADD, CMP} ) {
            src_type == 1;
        }
        else if(opcode inside{STR, HLT, NOP, SHL, SHR}){
            src_type == 0;
        }
    }
    
    //Constrain destination based on opcode
    constraint default_dest_type{
        solve opcode before dest_type;
        if(opcode inside{XOR, ADD, SHL, SHR, CMP, LD}){
            dest_type == 1;
        }
        else if(opcode inside{STR}){
            dest_type == 0;
        }
    }
    
    
    //After randomizing, set write instruction to data that was randomized
    function void post_randomize();
        if (opcode == BRA) begin
            ram_write_instruction = {opcode, condition_code, src_address, dest_address};     
        end
        else begin
            ram_write_instruction = {opcode, src_type, dest_type, 1'b0, 1'b0, src_address, dest_address};        
        end
    endfunction
    
    
    function new(string name="processor_instruction_seq");
        super.new(name);
    endfunction   
    
    
endclass

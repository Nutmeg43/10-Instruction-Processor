class processor_cov;
                              
    
    logic [11:0]        src_address;
    logic [11:0]        dest_address;  
    logic [3:0]         condition_code;
    logic [4:0]         status;
    logic               reset;
    logic               halt;  
    logic               branch_valid;
    logic               src_type;
    logic               dest_type;
    logic [3:0]         opcode;
    logic [2:0]         state; 
        
    //Condition code enums
    localparam ALWAYS = 4'b0000;
    localparam PARITY = 4'b0001;
    localparam EVEN   = 4'b0010;
    localparam CARRY  = 4'b0011;
    localparam NEG    = 4'b0100;
    localparam ZERO   = 4'b0101;
    localparam NCARRY = 4'b0110;
    localparam POS    = 4'b0111;
    
    covergroup opcode_cg;
        cp_opcode : coverpoint opcode{
            bins NOP = {4'b0000};
            bins LD  = {4'b0001};
            bins STR = {4'b0010};
            bins BRA = {4'b0011};
            bins XOR = {4'b0100};
            bins ADD = {4'b0101};
            bins SHL = {4'b0110};
            bins SHR = {4'b0111};
            bins CMP = {4'b1000};
        }     
    endgroup
    
    covergroup src_dest_type_cg;
        cp_src_type : coverpoint src_type{
            bins zero_one = (0 => 1);
            bins one_zero = (1 => 0);
        }
        
        cp_dest_type : coverpoint dest_type{
            bins zero_one = (0 => 1);
            bins one_zero = (1 => 0); 
        }
    endgroup
    
    covergroup state_cg;
        cp_state : coverpoint state{
            bins RESET      = {3'b000};
            bins WRITE      = {3'b001};
            bins FETCH      = {3'b010};
            bins DECODE     = {3'b011};
            bins EXECUTE    = {3'b100};
            bins STORE      = {3'b101};
            bins WRITE_BACK = {3'b110};
            bins HALT       = {3'b111}; 
        }
        
        cp_branch_valid : coverpoint branch_valid{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_halt : coverpoint halt{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_reset : coverpoint reset{
            bins one = {1};
            bins zero = {0};
        }
        
    endgroup
    
    covergroup status_cg;
        cp_status_bit_zero : coverpoint status[0]{
            bins one = {1};
            bins zero = {0};
        } 
        
        cp_status_bit_one : coverpoint status[1]{
            bins one = {1};
            bins zero = {0};
        } 
        
        cp_status_bit_two : coverpoint status[2]{
            bins one = {1};
            bins zero = {0};
        } 
        
        cp_status_bit_three : coverpoint status[3]{
            bins one = {1};
            bins zero = {0};
        } 
        
        cp_status_bit_four : coverpoint status[4]{
            bins one = {1};
            bins zero = {0};
        } 
    endgroup
    
    covergroup dest_addr_cg ;
        cp_dest_addr_zero : coverpoint dest_address[0]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_one : coverpoint dest_address[1]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_two : coverpoint dest_address[2]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_three : coverpoint dest_address[3]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_four : coverpoint dest_address[4]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_five : coverpoint dest_address[5]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_six : coverpoint dest_address[6]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_seven : coverpoint dest_address[7]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_eight : coverpoint dest_address[8]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_nine : coverpoint dest_address[9]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_ten : coverpoint dest_address[10]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_dest_addr_eleven : coverpoint dest_address[11]{
            bins one = {1};
            bins zero = {0};
        }
        
    endgroup
    
    covergroup src_addr_cg ;
        cp_src_addr_zero : coverpoint src_address[0]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_one : coverpoint src_address[1]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_two : coverpoint src_address[2]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_three : coverpoint src_address[3]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_four : coverpoint src_address[4]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_five : coverpoint src_address[5]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_six : coverpoint src_address[6]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_seven : coverpoint src_address[7]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_eight : coverpoint src_address[8]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_nine : coverpoint src_address[9]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_ten : coverpoint src_address[10]{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_src_addr_eleven : coverpoint src_address[11]{
            bins one = {1};
            bins zero = {0};
        }
        
    endgroup
    
    function new();
        opcode_cg = new();
        src_dest_type_cg = new();
        state_cg = new();
        status_cg = new();
        dest_addr_cg = new();
        src_addr_cg = new();
    endfunction
    
endclass

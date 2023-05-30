class processor_sb extends uvm_scoreboard;
    `uvm_component_utils(processor_sb)
    
    `uvm_analysis_imp_decl(_sb_port) 
    uvm_analysis_imp_sb_port#(processor_instruction_seq, processor_sb) analysis_sb_port;
    
    logic [31:0] sb_ram [4095:0];
    logic [31:0] sb_reg [4095:0];
    logic [31:0] sb_result;
    logic sb_branch_valid;
    logic sb_halt;
    logic [4:0] sb_status;  
    logic sb_carry;
        
    //Coverage 
    processor_cov cov = new();
    
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
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_sb_port = new("sb_port",this);
    endfunction
    
    //Start of sim, set coverage to start
    function void start_of_simulation_phase(uvm_phase phase);
        cov.opcode_cg.start();     
        cov.src_dest_type_cg.start();
        cov.state_cg.start();
        cov.state_cg.start();
        cov.dest_addr_cg.start();
        cov.src_addr_cg.start();
    endfunction
    
    function void report_phase(uvm_phase phase);
        cov.opcode_cg.stop();
        cov.src_dest_type_cg.stop();
        cov.state_cg.stop();
        cov.state_cg.stop();
        cov.dest_addr_cg.stop();
        cov.src_addr_cg.stop();
        `uvm_info("COV",$sformatf("Coverage results: %f opcode functional coverage", cov.opcode_cg.get_coverage()),UVM_LOW);
        `uvm_info("COV",$sformatf("Coverage results: %f src_dest_typ functional coverage", cov.src_dest_type_cg.get_coverage()),UVM_LOW);
        `uvm_info("COV",$sformatf("Coverage results: %f state functional coverage", cov.state_cg.get_coverage()),UVM_LOW);
        `uvm_info("COV",$sformatf("Coverage results: %f status functional coverage", cov.status_cg.get_coverage()),UVM_LOW);
        `uvm_info("COV",$sformatf("Coverage results: %f dest_addr functional coverage", cov.dest_addr_cg.get_coverage()),UVM_LOW);
        `uvm_info("COV",$sformatf("Coverage results: %f src_addr functional coverage", cov.src_addr_cg.get_coverage()),UVM_LOW);
    endfunction        
    
    virtual function void write_sb_port(processor_instruction_seq item);
        
        //Reset all memories
        if (item.cur_state == 3'b000) begin
            for(int i = 0; i < 4096; i = i + 1) begin
               sb_ram[i] = '0;
               sb_reg[i] = '0; 
            end
        end
        
        //Add the item to our SB memory
        else if (item.cur_state == 3'b001) begin
            sb_ram[item.ram_init_wadrs] = item.ram_write_instruction;
            `uvm_info("SB", $sformatf("Just wrote instruction 0x%0x to RAM address 0x%0x", item.ram_write_instruction, item.ram_init_wadrs), UVM_LOW);
        end
        
        //Cacluate the result in the SB
        else if(item.cur_state == 3'b101) begin
            `uvm_info("SB", $sformatf("Calculating sb_result for instruction = 0x%0x", item.cur_instruction), UVM_LOW);
            case(item.cur_instruction[31:28])
                NOP : begin
                    sb_result = '0; 
                    sb_carry = 1'b0;
                    sb_branch_valid = 1'b0;
                    sb_halt = 1'b0;
                end
                LD  : begin
                    sb_result = sb_ram[item.cur_instruction[23:12]];
                    sb_branch_valid = 1'b0;
                    sb_reg[item.cur_instruction[11:0]] = sb_result;
                end
                STR : begin
                    sb_result = sb_reg[item.cur_instruction[23:12]];
                    sb_branch_valid = 1'b0;
                    sb_ram[item.cur_instruction[11:0]] = sb_result;
                end
                BRA : begin
                    case(item.cur_instruction[27:24])
                        ALWAYS  :  sb_branch_valid = 1'b1;
                        PARITY  :  sb_branch_valid = (sb_status[1] == 1'b1) ? 1'b1 : 1'b0;
                        EVEN    :  sb_branch_valid = (sb_status[2] == 1'b1) ? 1'b1 : 1'b0;
                        CARRY   :  sb_branch_valid = (sb_status[0] == 1'b1) ? 1'b1 : 1'b0;  
                        NEG     :  sb_branch_valid = (sb_status[3] == 1'b1) ? 1'b1 : 1'b0; 
                        ZERO    :  sb_branch_valid = (sb_status[4] == 1'b1) ? 1'b1 : 1'b0; 
                        NCARRY  :  sb_branch_valid = (sb_status[0] == 1'b0) ? 1'b1 : 1'b0; 
                        POS     :  sb_branch_valid = (sb_status[4] == 1'b0 & sb_status[3] == 1'b0) ? 1'b1 : 1'b0;               
                        default : begin
                            sb_branch_valid = '0;
                        end
                    endcase
                    sb_result = item.cur_instruction[11:0]; //Result always set, but branch_valid will determine if is valid or note
                end
                XOR : begin
                    `uvm_info("SB", $sformatf("XOR: opone = 0x%0x, optwo = 0x%0x",sb_reg[item.cur_instruction[11:0]], sb_reg[item.cur_instruction[23:12]]), UVM_LOW);
                    sb_result = sb_reg[item.cur_instruction[11:0]] ^ sb_reg[item.cur_instruction[23:12]];
                    sb_branch_valid = 1'b0;
                    sb_reg[item.cur_instruction[11:0]] = sb_result;
                end
                ADD : begin
                    {sb_carry, sb_result} = sb_reg[item.cur_instruction[11:0]] + sb_reg[item.cur_instruction[23:12]];
                    sb_branch_valid = 1'b0;
                    sb_reg[item.cur_instruction[11:0]] = sb_result;
                end
                SHL : begin
                    sb_result = sb_reg[item.cur_instruction[11:0]] << item.cur_instruction[23:12];
                    sb_branch_valid = 1'b0;
                    sb_reg[item.cur_instruction[11:0]] = sb_result;
                end
                SHR : begin
                    sb_result = sb_reg[item.cur_instruction[11:0]] >> item.cur_instruction[23:12];
                    sb_branch_valid = 1'b0;
                    sb_reg[item.cur_instruction[11:0]] = sb_result;
                end
                HLT : begin
                    sb_halt = 1'b1;
                    sb_branch_valid = 1'b0;
                end
                CMP : begin
                    sb_result = ~sb_reg[item.cur_instruction[23:12]];
                    sb_branch_valid = 1'b0;
                    sb_reg[item.cur_instruction[11:0]] = sb_result;
                end
                default :  begin
                    sb_result = '0; 
                    sb_carry = 1'b0;
                    sb_branch_valid = 1'b0;
                    sb_halt = 1'b0;
                end
            endcase
            
            sb_status[0] = sb_carry;   //Set Carry
            sb_status[1] = sb_result[7:0] ^ sb_result[15:8]; //Set Parity
            sb_status[2] = (item.cur_instruction[31:28] == BRA) ? status[2] : ~sb_result[0]; //Set Even
            sb_status[3] = sb_result < 0 ? 1'b1 : 1'b0; //Set Neg
            sb_status[4] = sb_result == 0 ? 1'b1 : 1'b0; //Set Zero
            
        end
        
        //Check SB result against DUT result
        else if(item.cur_state == 3'b110) begin
            `uvm_info("SB", $sformatf("Checking result for instruction = 0x%0x", item.cur_instruction), UVM_LOW);
            if(sb_result != item.cur_result) begin
                `uvm_error("SB_ERROR", $sformatf("sb_expected_result was = 0x%0x while DUT result was 0x%0x", sb_result, item.cur_result));
            end
        end        
        
        //Set all coverage fields
        cov.reset = item.reset;
        cov.src_type = item.src_type;
        cov.dest_type = item.dest_type;
        cov.condition_code = item.condition_code;
        cov.src_address = item.src_address;
        cov.dest_address = item.dest_address;
        cov.opcode = item.opcode;
        cov.state = item.cur_state;
        cov.halt = item.cur_halt;
        cov.branch_valid = item.cur_branch_valid;
        cov.status = item.cur_status;
        
        //Sample
        cov.opcode_cg.sample();
        cov.src_dest_type_cg.sample();
        cov.state_cg.sample();
        cov.status_cg.sample();
        cov.dest_addr_cg.sample();
        cov.src_addr_cg.sample();
    endfunction
    
endclass

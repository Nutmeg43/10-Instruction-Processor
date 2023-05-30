interface processor_intf#(
    DATA_WIDTH = 32,
    ADDRESS_WIDTH = 12
)(
    input clk
);

    logic reset;
    logic [ADDRESS_WIDTH-1:0] ram_init_wadrs;
    logic [DATA_WIDTH-1:0] ram_write_instruction;
    logic initialize_instructions;
    logic [2:0] cur_state;   
    logic cur_halt;  
    logic [31:0] cur_result;
    logic [31:0] cur_instruction;
    logic cur_branch_valid;
    logic [4:0] cur_status;
    
    
    clocking cb @(posedge clk);
        output reset;
        output ram_init_wadrs;
        output ram_write_instruction;
        output initialize_instructions;
        input cur_state;
        input cur_result;
        input cur_instruction;
        input cur_halt;
        input cur_branch_valid;       
        input cur_status;
    endclocking
    
endinterface
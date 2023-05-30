`include "uvm.sv"
import uvm_pkg::*;
`include "processor_intf.sv"
import processor_pkg::*;

module J_10_tb#(
    DATA_WIDTH = 32,
    ADDRESS_WIDTH = 12
)();

    logic clk;
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
    
    processor_intf #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) processor_intf_instance(
        .clk(clk)
    );
    
    
    
    processor_fsm #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) processor_intf(
        .clk(clk),
        .reset(processor_intf_instance.reset),
        .ram_init_wadrs(processor_intf_instance.ram_init_wadrs),
        .ram_write_instruction(processor_intf_instance.ram_write_instruction),
        .initialize_instructions(processor_intf_instance.initialize_instructions),
        .cur_halt(processor_intf_instance.cur_halt),
        .cur_state(processor_intf_instance.cur_state),
        .cur_result(processor_intf_instance.cur_result),
        .cur_instruction(processor_intf_instance.cur_instruction),
        .cur_branch_valid(processor_intf_instance.cur_branch_valid),
        .cur_status(processor_intf_instance.cur_status)
    );
    
    always #5 clk = ~clk;
    
    
    initial begin
        clk = 0;
        uvm_config_db#(virtual processor_intf)::set(null, "*", "processor_intf", processor_intf_instance);
        run_test("processor_test");
        $stop();
    end
    
    /*
    initial begin
       clk = 0;
       reset = 1;
       #35
       reset = 0;
       initialize_instructions = 1;
       ram_init_wadrs = 12'h00;
       ram_write_instruction = 32'b0101_1_1_00_000000000000_000000000001; //Says "ADD R1 R0"
       #10
       ram_init_wadrs = 12'h01;
       ram_write_instruction = 32'b0011_0000_000000000000_000000001001; //Says "BRA ALWAYS R9
       #10
       ram_init_wadrs = 12'b000000001001;
       ram_write_instruction = 32'b0101_1_1_00_000000000000_000000000011; //Says "ADD R3 R0"
       #10
       ram_init_wadrs = 12'b000000001010;
       ram_write_instruction = 32'b0001_1_0_00_000000000011_000000000111; //Says "LD R3 MEM7" 
       #10
       ram_init_wadrs = 12'b000000001011;
       ram_write_instruction = 32'b0010_0_1_00_000000000111_000000000000; //Says "STR R0 MEM7" 
       #10
       ram_init_wadrs = 12'b000000001100;
       ram_write_instruction = 32'b0110_0_1_00_000000000101_000000000000; //Says "SHL R0 5" 
       #10
       initialize_instructions = 0;        
   end
   * */
    
endmodule
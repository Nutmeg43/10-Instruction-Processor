class processor_monitor extends uvm_monitor;
    `uvm_component_utils(processor_monitor)
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual processor_intf intf;
    uvm_analysis_port #(processor_instruction_seq) write_sb_port;
    int cmd_completion_cnt = 0;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        write_sb_port = new("write_sb_port",this);
        if(!uvm_config_db#(virtual processor_intf)::get(this,"","processor_intf",intf)) begin
            `uvm_fatal("MON", "Could not get VIF, check if set correctly in test");
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            @(intf.cb) begin
                processor_instruction_seq item = processor_instruction_seq::type_id::create("item");
                item.ram_init_wadrs = intf.ram_init_wadrs;
                item.ram_write_instruction = intf.ram_write_instruction;
                item.cur_instruction = intf.cur_instruction;
                item.cur_result = intf.cur_result;
                item.cur_state = intf.cur_state;
                item.cur_halt = intf.cur_halt;
                item.cur_branch_valid = intf.cur_branch_valid;
                item.cur_status = intf.cur_status;
                item.opcode = intf.cur_instruction[31:28];
                item.src_type = intf.cur_instruction[27];
                item.dest_type = intf.cur_instruction[26];
                item.src_address = intf.cur_instruction[23:12];
                item.dest_address = intf.cur_instruction[11:0];
                item.reset = intf.reset;
                if (intf.cur_state == 3'b110) begin
                    `uvm_info("MON", $sformatf("Monitoring: result = 0x%0x, opcode= 0x%0x", intf.cur_result, intf.cur_instruction[31:28]),UVM_LOW);
                    cmd_completion_cnt = cmd_completion_cnt + 1; 
                end
                else if(intf.cur_state == 3'b111) begin
                    cmd_completion_cnt = 75;    
                end
                write_sb_port.write(item);
            end
        end
        
    endtask
    
    
endclass
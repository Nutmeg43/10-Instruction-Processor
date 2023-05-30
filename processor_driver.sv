class processor_driver extends uvm_driver #(processor_instruction_seq);
    `uvm_component_param_utils(processor_driver)
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction 
    
    virtual processor_intf intf;
    processor_instruction_seq item;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item  = processor_instruction_seq::type_id::create("item");
        if(!uvm_config_db#(virtual processor_intf)::get(this,"","processor_intf",intf)) begin
           `uvm_fatal("DRV", "Could not get VIF check if set in test correctly"); 
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            seq_item_port.get_next_item(item);
            @(intf.cb) begin
                `uvm_info("DRV", $sformatf("Driving: reset = 0x%0x, wadrs = 0x%0x, instr= 0x%0x",item.reset, item.ram_init_wadrs,item.ram_write_instruction),UVM_LOW);
                intf.reset <= item.reset;
                intf.ram_init_wadrs <= item.ram_init_wadrs;
                intf.ram_write_instruction <= item.ram_write_instruction;
                intf.initialize_instructions <= item.initialize_instructions;      
            end
            seq_item_port.item_done();
        end
        
    endtask
    
endclass
class processor_agent extends uvm_agent;
    `uvm_component_utils(processor_agent)
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    processor_monitor monitor;
    uvm_sequencer#(processor_instruction_seq) sequencer;
    processor_driver  driver;    
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = processor_monitor::type_id::create("monitor",this);
        sequencer = uvm_sequencer#(processor_instruction_seq)::type_id::create("sequencer",this);
        driver = processor_driver::type_id::create("driver",this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    
endclass
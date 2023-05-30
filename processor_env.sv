class processor_env extends uvm_env;
    `uvm_component_utils(processor_env)
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    processor_agent agent;
    processor_sb    sb;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = processor_agent::type_id::create("agent",this);
        sb = processor_sb::type_id::create("sb",this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.write_sb_port.connect(sb.analysis_sb_port);
    endfunction    
    
endclass

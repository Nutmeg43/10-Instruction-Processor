class processor_test extends uvm_test;
    `uvm_component_utils(processor_test)
    
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    processor_init_seq   seq;
    processor_env        env;
    
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = processor_env::type_id::create("env",this);
        seq = processor_init_seq::type_id::create("seq");
        //uvm_config_db#(uvm_object_wrapper)::set(this,"env.agent.sequencer.run_phase", 
          //  "default_sequence",processor_init_seq::type_id::get()
        //);
    endfunction
    
    //Print the topology of design
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
    
    //Run phase
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 20); //20 time units after all transactions complete
        seq.start(env.agent.sequencer);
        wait(env.agent.monitor.cmd_completion_cnt == 75);
        phase.drop_objection(this);
    endtask
    
endclass

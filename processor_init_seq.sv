class processor_init_seq extends uvm_sequence #(processor_instruction_seq);
    `uvm_object_utils(processor_init_seq)
    
    function new(string name="processor_init_seq");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction
    
    int wadrs = 0;
    
    virtual task body();
        `uvm_do_with(req, { req.reset == 1'b1; } );
        `uvm_do_with(req, {req.ram_init_wadrs == wadrs; req.initialize_instructions == 1'b1; req.reset == 1'b0;})
        repeat(75) begin
            `uvm_do_with(req, {req.ram_init_wadrs == wadrs; req.initialize_instructions == 1'b1; req.reset == 1'b0;} );
            wadrs = wadrs + 1;
        end
        `uvm_do_with(req, {req.initialize_instructions == 1'b0; req.reset == 1'b0;} );
    endtask
        
endclass    
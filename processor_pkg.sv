/*
 * Author: Jacob Salmon
 * 
 * Description: Package for all classes needed to run
 * 
 * Notable Info: Includes uvm.sv, but comercial simulators might precompile this
 */
 
package processor_pkg;
    `include "uvm.sv"
    import uvm_pkg::*;
    `include "processor_cov.sv"
    `include "processor_instruction_seq.sv"
    `include "processor_init_seq.sv"
    `include "processor_driver.sv"
    `include "processor_monitor.sv"
    `include "processor_sb.sv"
    `include "processor_agent.sv"
    `include "processor_env.sv"
    `include "processor_test.sv"    
endpackage

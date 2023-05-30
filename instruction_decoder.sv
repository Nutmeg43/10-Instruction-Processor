module instruction_decoder#(
    DATA_WIDTH = 32,
    ADDRESS_WIDTH = 12
)(
    input  [DATA_WIDTH-1:0] instruction,
    input  [DATA_WIDTH-1:0] dest_reg_read,    //Value that will be read from file reg (muxed for r1)
    input  [DATA_WIDTH-1:0] src_reg_read,     //Value that will be read from file read(muxed for r2)
    output logic [3:0] cc,
    output logic [3:0] opcode,
    output logic [DATA_WIDTH-1:0] operand_one,
    output logic [DATA_WIDTH-1:0] operand_two,
    output logic dest_type,
    output logic r_en_one,
    output logic r_en_two,
    output logic [ADDRESS_WIDTH-1:0] r_adrs_one,
    output logic [ADDRESS_WIDTH-1:0] r_adrs_two,
    output logic [ADDRESS_WIDTH-1:0] dest_adrs
);
    

    always_comb begin
        opcode = instruction[31:28];
        cc = instruction[27:24];
        operand_two = (instruction[27] | (opcode == 4'b0010)) ? src_reg_read  : instruction[23:12];
        operand_one = (instruction[26] & (opcode != 4'b0011)) ? dest_reg_read : instruction[11:0]; //Always take address on branch
        dest_type = instruction[26] & (opcode != 4'b0011); //Make sure we don't try and write on a branch
        r_en_one = instruction[26];
        r_en_two = instruction[27] | (opcode == 4'b0010);
        r_adrs_one = instruction[11:0];
        r_adrs_two = instruction[23:12];
        dest_adrs = instruction[11:0];
    end

endmodule
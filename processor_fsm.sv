module processor_fsm#(
    DATA_WIDTH = 32,
    ADDRESS_WIDTH = 12
)(  
    input clk,
    input reset,
    input [ADDRESS_WIDTH-1:0] ram_init_wadrs,
    input [DATA_WIDTH-1:0] ram_write_instruction,
    input initialize_instructions,
    output logic [2:0] cur_state,
    output logic cur_halt,
    output logic cur_branch_valid,
    output logic [31:0] cur_result,
    output logic [31:0] cur_instruction,
    output logic [4:0] cur_status
);

    //Holds current state
    logic [2:0]     state;

    //ALU Parts
    logic           branch_valid;
    logic           halt;
    logic [4:0]     status;
    
    //File Reg
    logic  w_en;
    
    //Instruction Reg
    logic dest_type;
    logic [DATA_WIDTH-1:0] src_reg_in;
    logic [DATA_WIDTH-1:0] instruction;
    
    //RAM
    logic ram_w_en;
    logic ram_r_en;
    logic [ADDRESS_WIDTH-1:0] ram_r_adrs;
    logic [ADDRESS_WIDTH-1:0] ram_w_adrs;
    logic [DATA_WIDTH-1:0] ram_w_data;
    logic [DATA_WIDTH-1:0] ram_r_data;  
    
    //Program counter
    logic [11:0]   pc;
    logic          inc_pc;
    
    //Shared
    logic reset_all;
    logic  [ADDRESS_WIDTH-1:0] dest_adrs; //Shared by IR(Out) and File reg(In)
    logic [31:0]    result; //Shared by ALU(out) ad File reg(In)
    logic [31:0] operand_one; //Shared by IR(out) and ALU(in)
    logic [31:0] operand_two; //Shared by IR(out) and ALU(in)
    logic  [31:0] dest_reg_read; //Shared by File reg (out) and IR (in)
    logic  [31:0] src_reg_read; //Shared by File reg (out) and IR (in)
    logic r_en_one; //Shared by File reg and IR
    logic r_en_two; //Shared by File reg and IR
    logic [11:0] r_adrs_one; //Shared by File reg and IR
    logic [11:0] r_adrs_two; //Shared by File reg and IR
    logic [3:0] cc; //Shared by ALU and IR
    logic [3:0] opcode; //Shared by ALU and IR
    

    localparam RESET      = 3'b000;
    localparam WRITE      = 3'b001;
    localparam FETCH      = 3'b010;
    localparam DECODE     = 3'b011;
    localparam EXECUTE    = 3'b100;
    localparam STORE      = 3'b101;
    localparam WRITE_BACK = 3'b110;
    localparam HALT       = 3'b111;
    
    //Opcode enums
    localparam NOP = 4'b0000;
    localparam LD  = 4'b0001;
    localparam STR = 4'b0010;
    localparam BRA = 4'b0011;
    localparam XOR = 4'b0100;
    localparam ADD = 4'b0101;
    localparam SHL = 4'b0110;
    localparam SHR = 4'b0111;
    localparam HLT = 4'b1000;
    localparam CMP = 4'b1001;    
    
    
    always_ff @(posedge clk) begin        
        case(state)
            RESET : begin
                if(reset) begin
                    reset_all <= 1;
                end
                else if(initialize_instructions) begin
                    state <= WRITE;
                    reset_all <= 0;
                end    
            end
            WRITE : begin
                if(initialize_instructions) begin
                    state <= WRITE;
                end
                else if(!reset & !initialize_instructions) begin
                    state <= FETCH;
                end
                else if(reset) begin
                    state <= RESET;    
                end
            end
            FETCH : begin
                state <= DECODE;
            end
            DECODE : begin
                state <= EXECUTE;
                instruction <= ram_r_data;
            end
            EXECUTE : begin
                state <= STORE;
                inc_pc <= 1;
            end
            STORE : begin
                if(halt) begin
                    state <= HALT;
                end
                else begin
                    state <= WRITE_BACK;
                end
                inc_pc <= 0;
            end
            WRITE_BACK : begin
                state <= FETCH;
            end
            HALT : begin
               if(reset) begin
                  state <= RESET; 
               end
            end
            default : begin
                state <= RESET;
            end
        endcase
    end
    
    
    assign w_en = (state == STORE) & dest_type; //Set w_en for file reg 
    assign ram_w_adrs = (state == WRITE) ?  ram_init_wadrs : dest_adrs; //Set write address to ram
    assign src_reg_in = (opcode == 4'b0001) ? ram_r_data :  src_reg_read; //Set src reg, for LD (src == memory, dest== reg)
    assign ram_w_en = (((opcode == 4'b0010) && (state == WRITE_BACK))) ||  initialize_instructions; //Write to ram on STORE or init
    assign ram_w_data = (state == WRITE) ? ram_write_instruction : result; //Set data to write to ram, either result or init
    assign ram_r_adrs = (state == FETCH) ? pc : r_adrs_two;
    assign ram_r_en = (state == FETCH) || ((state == EXECUTE) && (opcode == 4'b0001));
    assign cur_state = state;
    assign cur_result = result;
    assign cur_halt = halt;
    assign cur_instruction = instruction;
    assign cur_status = status;
    assign cur_branch_valid = branch_valid;
    
        
    //Instances of components
    program_counter #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) program_counter_instance(
        .reset(reset_all),
        .bra_result(result[11:0]),
        .bra_valid(branch_valid),
        .inc_pc(inc_pc),
        .pc(pc)
    );
    
    
    ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) ram_instance(
        .clk(clk),
        .w_en(ram_w_en),
        .r_en_one(ram_r_en),
        .r_adrs_one(ram_r_adrs),
        .w_adrs(ram_w_adrs),
        .w_data(ram_w_data),
        .reset(reset_all),
        .r_data_one(ram_r_data)
    );
    
    instruction_decoder instruction_decoder_instance(
        .instruction(instruction),
        .dest_reg_read(dest_reg_read),
        .src_reg_read(src_reg_in),
        .cc(cc),
        .opcode(opcode),
        .operand_one(operand_one),
        .operand_two(operand_two),
        .dest_type(dest_type),
        .r_en_one(r_en_one),
        .r_en_two(r_en_two),
        .r_adrs_one(r_adrs_one),
        .r_adrs_two(r_adrs_two),
        .dest_adrs(dest_adrs)
    );

    ALU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ALU_instance(
        .r1(operand_one),
        .r2(operand_two),
        .cc(cc),
        .opcode(opcode),
        .halt(halt),
        .status_state(status),
        .branch_valid(branch_valid),
        .result(result)
    );
    
    file_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) file_register_instance(
        .clk(clk),
        .w_en(w_en),
        .r_en_one(r_en_one),
        .r_en_two(r_en_two),
        .r_adrs_one(r_adrs_one),
        .r_adrs_two(r_adrs_two),
        .w_adrs(dest_adrs),
        .w_data(result),
        .reset(reset_all),
        .r_data_one(dest_reg_read),
        .r_data_two(src_reg_read)
    );
    

endmodule
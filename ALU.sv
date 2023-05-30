module ALU #(
    DATA_WIDTH = 32
)(
    input  [DATA_WIDTH-1:0]         r1,
    input  [DATA_WIDTH-1:0]         r2,
    input  [3:0]                    cc,
    input  [3:0]                    opcode,
    output logic                    halt,
    output logic                    branch_valid,
    output logic [DATA_WIDTH-1:0]   result,
    output logic [4:0]              status_state
);

    logic [4:0] status; //Save status for conditional brances
    logic carry;
    
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
    
    //Condition code enums
    localparam ALWAYS = 4'b0000;
    localparam PARITY = 4'b0001;
    localparam EVEN   = 4'b0010;
    localparam CARRY  = 4'b0011;
    localparam NEG    = 4'b0100;
    localparam ZERO   = 4'b0101;
    localparam NCARRY = 4'b0110;
    localparam POS    = 4'b0111;
    
    always_comb begin 
        case(opcode)
            
            NOP : begin
                result = '0; 
                carry = 1'b0;
                branch_valid = 1'b0;
                halt = 1'b0;
            end
            LD  : begin
                result = r2;
                branch_valid = 1'b0;
            end
            STR : begin
                result = r2;
                branch_valid = 1'b0;
            end
            BRA : begin
                case(cc)
                    ALWAYS  :  branch_valid = 1'b1;
                    PARITY  :  branch_valid = (status[1] == 1'b1) ? 1'b1 : 1'b0;
                    EVEN    :  branch_valid = (status[2] == 1'b1) ? 1'b1 : 1'b0;
                    CARRY   :  branch_valid = (status[0] == 1'b1) ? 1'b1 : 1'b0;  
                    NEG     :  branch_valid = (status[3] == 1'b1) ? 1'b1 : 1'b0; 
                    ZERO    :  branch_valid = (status[4] == 1'b1) ? 1'b1 : 1'b0; 
                    NCARRY  :  branch_valid = (status[0] == 1'b0) ? 1'b1 : 1'b0; 
                    POS     :  branch_valid = (status[4] == 1'b0 & status[3] == 1'b0) ? 1'b1 : 1'b0;               
                    default : begin
                        branch_valid = '0;
                    end
                endcase
                result = r1; //Result always set, but branch_valid will determine if is valid or note
            end
            XOR : begin
                result = r1 ^ r2;
                branch_valid = 1'b0;
            end
            ADD : begin
                {carry,result} = r1 + r2;
                branch_valid = 1'b0;
            end
            SHL : begin
                result = r1 << r2;
                branch_valid = 1'b0;
            end
            SHR : begin
                result = r1 >> r2;
                branch_valid = 1'b0;
            end
            HLT : begin
                halt = 1'b1;
                branch_valid = 1'b0;
            end
            CMP : begin
                result = ~r2;
                branch_valid = 1'b0;
            end
            default :  begin
                result = '0; 
                carry = 1'b0;
                branch_valid = 1'b0;
                halt = 1'b0;
            end   
        endcase        
    end
    
    
    assign status[0] = carry;   //Set Carry
    assign status[1] = result[7:0] ^ result[15:8]; //Set Parity
    assign status[2] = (opcode == BRA) ? status[2] : ~result[0]; //Set Even
    assign status[3] = result < 0 ? 1'b1 : 1'b0; //Set Neg
    assign status[4] = result == 0 ? 1'b1 : 1'b0; //Set Zero
    assign status_state = status;
    

endmodule
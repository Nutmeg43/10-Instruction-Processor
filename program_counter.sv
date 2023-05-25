module program_counter #(
    ADDRESS_WIDTH = 12
)(
    input reset,
    input [ADDRESS_WIDTH-1:0] bra_result,
    input bra_valid,
    input inc_pc,
    output [ADDRESS_WIDTH-1:0] pc
);

    logic [ADDRESS_WIDTH-1:0] pc_reg;

    always_ff @(posedge inc_pc or posedge reset) begin
         if(reset) begin
            pc_reg <= '0;
        end
        else if(bra_valid) begin
            pc_reg <= bra_result;
        end
        else begin
            pc_reg <= pc_reg + 1;
        end       
    end

    assign pc = pc_reg;

endmodule
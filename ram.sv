module ram #(
    DATA_WIDTH = 32,
    ADDRESS_WIDTH = 12
)(  
    input  clk,
    input  w_en,
    input  r_en_one,
    input  [ADDRESS_WIDTH-1:0] r_adrs_one,
    input  [ADDRESS_WIDTH-1:0] w_adrs,
    input  [DATA_WIDTH-1:0] w_data,  
    input  reset,
    output logic  [DATA_WIDTH-1:0] r_data_one
);

    integer i;
    logic [31:0] memory [(2**ADDRESS_WIDTH)-1:0];
    

    always_ff @ (negedge clk) begin
        if(reset) begin
            for(i = 0; i < 2**ADDRESS_WIDTH; i++) begin
                memory[i] <= 32'h000_0000;
            end
            r_data_one <= '0;
        end  
        else begin
           if(r_en_one) begin
               r_data_one <= memory[r_adrs_one];
           end
           if(w_en) begin
               memory[w_adrs] <= w_data;
           end
        end    
    end


endmodule
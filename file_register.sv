module file_register #(
    DATA_WIDTH = 32,
    ADDRESS_WIDTH = 12
)(  
    input  clk,
    input  w_en,
    input  r_en_one,
    input  r_en_two,
    input  [ADDRESS_WIDTH-1:0] r_adrs_one,
    input  [ADDRESS_WIDTH-1:0] r_adrs_two,
    input  [ADDRESS_WIDTH-1:0] w_adrs,
    input  [DATA_WIDTH-1:0] w_data,  
    input  reset,
    output logic  [DATA_WIDTH-1:0] r_data_one,
    output logic  [DATA_WIDTH-1:0] r_data_two
);

    integer i;
    logic [DATA_WIDTH-1:0] memory [(2**ADDRESS_WIDTH)-1:0];
    

    always_ff @ (negedge clk) begin
        if(reset) begin
            for(i = 0; i < 2**ADDRESS_WIDTH; i++) begin
                memory[i] <= 32'h000_0000;
            end
            r_data_one <= '0;
            r_data_two <= '0;
        end  
        else begin
           if(r_en_one) begin
               r_data_one <= memory[r_adrs_one];
           end
           if(r_en_two) begin
               r_data_two <= memory[r_adrs_two];
           end
           if(w_en) begin
               memory[w_adrs] <= w_data;
           end
        end    
    end


endmodule
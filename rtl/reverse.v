module reverse_with_en #(
    parameter DATA_WIDTH = 8
)(
    input wire [DATA_WIDTH-1:0] in_data,
    input wire en,
    output wire [DATA_WIDTH-1:0] out_data
);
    // Khi en = 1, đảo ngược dữ liệu; khi en = 0, giữ nguyên dữ liệu
    // For loop để đảo ngược bit
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : reverse_loop
            assign out_data[i] = en ? in_data[i] : in_data[DATA_WIDTH-1-i];
        end
    endgenerate
endmodule
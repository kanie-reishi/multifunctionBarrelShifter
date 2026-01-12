module rotating_left_1_bit #(
    parameter DATA_WIDTH = 8
)(
    input wire [DATA_WIDTH-1:0] in_data,
    output wire [DATA_WIDTH-1:0] out_data
);
    assign out_data = {in_data[DATA_WIDTH-2:0], in_data[DATA_WIDTH-1]};
endmodule
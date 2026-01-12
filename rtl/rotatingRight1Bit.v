module rotating_right_1_bit #(
    parameter DATA_WIDTH = 8
)(
    input wire [DATA_WIDTH-1:0] in_data,
    output wire [DATA_WIDTH-1:0] out_data
);
    assign out_data = {in_data[0], in_data[DATA_WIDTH-1:1]};
endmodule
module barrel_Shifter_LR_reverse #(
    parameter DATA_WIDTH = 8
)(
    input wire lr, // 0: Left, 1: Right
    input wire [DATA_WIDTH-1:0] in_data,
    output wire [DATA_WIDTH-1:0] out_data
);
    wire [DATA_WIDTH-1:0] temp_data_1, temp_data_2;
    // Instantiate the reverse module
    reverse_with_en #(.DATA_WIDTH(DATA_WIDTH)) reverse_inst (
        .in_data(in_data),
        .en(lr), // Use lr to control reversal
        .out_data(temp_data_1)
    );
    // Rotate right
    rotating_right_1_bit #(.DATA_WIDTH(DATA_WIDTH)) right_rotator (
        .in_data(temp_data_1),
        .out_data(temp_data_2)
    );
    // Reverse again for left rotation
    reverse_with_en #(.DATA_WIDTH(DATA_WIDTH)) reverse_inst2 (
        .in_data(temp_data_2),
        .en(lr), // Use lr to control reversal
        .out_data(out_data)
    );
endmodule
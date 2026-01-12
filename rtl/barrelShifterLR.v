module barrel_Shifter_LR_1bit #(
    parameter DATA_WIDTH = 8
)(
    input wire [DATA_WIDTH-1:0] in_data,
    input wire lr,
    output wire [DATA_WIDTH-1:0] out_data
);

    wire [DATA_WIDTH-1:0] left_rotated;
    wire [DATA_WIDTH-1:0] right_rotated;

    rotating_left_1_bit #(.DATA_WIDTH(DATA_WIDTH)) left_rotator (
        .in_data(in_data),
        .out_data(left_rotated)
    );

    rotating_right_1_bit #(.DATA_WIDTH(DATA_WIDTH)) right_rotator (
        .in_data(in_data),
        .out_data(right_rotated)
    );

    mux2to1 #(.DATA_WIDTH(DATA_WIDTH)) mux (
        .sel(lr),
        .in0(left_rotated),
        .in1(right_rotated),
        .out_data(out_data)
    );
endmodule
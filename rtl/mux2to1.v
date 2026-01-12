module mux2to1 #(
    parameter DATA_WIDTH = 8
)(
    input wire sel,
    input wire [DATA_WIDTH-1:0] in0,
    input wire [DATA_WIDTH-1:0] in1,
    output wire [DATA_WIDTH-1:0] out_data
);
    assign out_data = sel ? in1 : in0;
endmodule
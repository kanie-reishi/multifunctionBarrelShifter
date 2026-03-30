module barrel_shifter_top (
    input  wire        clk,        // 100 MHz clock (W5)
    input  wire [3:0]  sw,         // 4 switches: input data
    input  wire        btn_left,   // Button Left  (W19) – rotate left
    input  wire        btn_right,  // Button Right (T17) – rotate right
    input  wire        btn_reset,  // Button Center(U18) – load input
    output wire [3:0]  led,        // LEDs: echo stored output
    output reg  [6:0]  seg,        // 7-segment cathodes (active low)
    output reg  [3:0]  an          // 7-segment anodes   (active low)
);

    parameter DATA_WIDTH = 4;

    // -------------------------------------------------------
    //  Button debouncers → single-cycle pulses
    // -------------------------------------------------------
    wire pulse_left, pulse_right, pulse_reset;

    debouncer db_left (
        .clk      (clk),
        .btn_in   (btn_left),
        .btn_pulse(pulse_left)
    );

    debouncer db_right (
        .clk      (clk),
        .btn_in   (btn_right),
        .btn_pulse(pulse_right)
    );

    debouncer db_reset (
        .clk      (clk),
        .btn_in   (btn_reset),
        .btn_pulse(pulse_reset)
    );

    // -------------------------------------------------------
    //  Barrel shifter (combinational, used on demand)
    // -------------------------------------------------------
    reg                   lr;
    wire [DATA_WIDTH-1:0] shifted_data;

    barrel_Shifter_LR_reverse #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_shifter (
        .lr      (lr),
        .in_data (data_reg),
        .out_data(shifted_data)
    );

    // -------------------------------------------------------
    //  Output register (holds result, updated by buttons)
    // -------------------------------------------------------
    reg [DATA_WIDTH-1:0] data_reg = 4'b0000;

    always @(posedge clk) begin
        if (pulse_reset) begin
            // Load new input from switches
            data_reg <= sw;
        end else if (pulse_left) begin
            // Rotate left: lr = 0
            data_reg <= shifted_data;
        end else if (pulse_right) begin
            // Rotate right: lr = 1
            data_reg <= shifted_data;
        end
        // else: IDLE – hold current value
    end

    // Set lr direction for the barrel shifter
    always @(*) begin
        if (pulse_right)
            lr = 1'b1;
        else
            lr = 1'b0; // default left (also used when pulse_left active)
    end

    // -------------------------------------------------------
    //  LEDs echo stored output
    // -------------------------------------------------------
    assign led = data_reg;

    // -------------------------------------------------------
    //  7-segment refresh counter (~1.5 kHz @ 100 MHz)
    // -------------------------------------------------------
    reg [16:0] refresh_counter = 0;

    always @(posedge clk)
        refresh_counter <= refresh_counter + 1;

    wire [1:0] digit_sel = refresh_counter[16:15];

    // -------------------------------------------------------
    //  Digit multiplexer – each digit shows one bit (0 or 1)
    //    AN3 = bit[3]  AN2 = bit[2]  AN1 = bit[1]  AN0 = bit[0]
    // -------------------------------------------------------
    reg current_bit;

    always @(*) begin
        case (digit_sel)
            2'b00: begin
                an          = 4'b1110; // AN0 → bit[0]
                current_bit = data_reg[0];
            end
            2'b01: begin
                an          = 4'b1101; // AN1 → bit[1]
                current_bit = data_reg[1];
            end
            2'b10: begin
                an          = 4'b1011; // AN2 → bit[2]
                current_bit = data_reg[2];
            end
            2'b11: begin
                an          = 4'b0111; // AN3 → bit[3]
                current_bit = data_reg[3];
            end
            default: begin
                an          = 4'b1111;
                current_bit = 1'b0;
            end
        endcase
    end

    // -------------------------------------------------------
    //  7-segment: display "0" or "1" (active low)
    //  seg[0]=a, seg[1]=b, seg[2]=c, seg[3]=d,
    //  seg[4]=e, seg[5]=f, seg[6]=g
    // -------------------------------------------------------
    always @(*) begin
        if (current_bit)
            //               gfe_dcba
            seg = 7'b111_1001; // "1" (segments b, c ON)
        else
            //               gfe_dcba
            seg = 7'b100_0000; // "0" (segments a,b,c,d,e,f ON)
    end

endmodule

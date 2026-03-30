module debouncer #(
    parameter DEBOUNCE_LIMIT = 1_000_000  // 10 ms at 100 MHz
)(
    input  wire clk,
    input  wire btn_in,      // raw button input (active high)
    output reg  btn_pulse     // single-cycle pulse on press
);

    reg [19:0] counter = 0;
    reg        btn_stable = 0;
    reg        btn_prev   = 0;

    // Debounce: wait for button to be stable for DEBOUNCE_LIMIT cycles
    always @(posedge clk) begin
        if (btn_in != btn_stable) begin
            counter <= counter + 1;
            if (counter >= DEBOUNCE_LIMIT) begin
                btn_stable <= btn_in;
                counter    <= 0;
            end
        end else begin
            counter <= 0;
        end
    end

    // Edge detection: generate single-cycle pulse on rising edge
    always @(posedge clk) begin
        btn_prev  <= btn_stable;
        btn_pulse <= btn_stable & ~btn_prev;
    end

endmodule

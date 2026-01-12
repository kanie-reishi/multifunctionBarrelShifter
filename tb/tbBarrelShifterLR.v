`timescale 1ns/1ps

module tb_barrel_shifter; 

    // 1. Parameters
    parameter DATA_WIDTH = 8;

    // 2. Internal Signals 
    reg clk;
    reg lr;                         // 0: Left, 1: Right (Giả định)
    reg [DATA_WIDTH-1:0] in_data;   // Dữ liệu đầu vào
    wire [DATA_WIDTH-1:0] out_data_basic; // Dữ liệu đầu ra quan sát được từ UUT cơ bản
    wire [DATA_WIDTH-1:0] out_data_opt; // Dữ liệu đầu ra quan sát được từ UUT tối ưu

    // 3. Instantiate UUT (Unit Under Test)
    barrel_Shifter_LR_1bit #(.DATA_WIDTH(DATA_WIDTH)) uut1 (
        .in_data(in_data),
        .lr(lr),
        .out_data(out_data_basic)
    );
    barrel_Shifter_LR_reverse #(.DATA_WIDTH(DATA_WIDTH)) uut2 (
        .in_data(in_data),
        .lr(lr),
        .out_data(out_data_opt)
    );
    // 4. Clock Generation (Tạo xung nhịp)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Chu kỳ 10ns (100MHz)
    end
    
    // 5. Test Vectors and Stimulus
    // So sánh kết quả giữa hai UUT
    initial begin
        lr = 0;
        in_data = 0;
        #15
        $display("Comparing Outputs between Basic and Optimized Designs:");

        repeat (100) begin
            @(negedge clk);
            lr = $random % 2;
            in_data = $random;

            @(posedge clk);
            #1; // Chờ một chút để đảm bảo tín hiệu ổn định
            if (out_data_basic !== out_data_opt) begin
                $display("Mismatch Detected at time %0t: LR=%b, Input=%b, Basic Output=%b, Optimized Output=%b", 
                          $time, lr, in_data, out_data_basic, out_data_opt);
            end else begin
                $display("Match at time %0t: LR=%b, Input=%b, Output=%b", 
                          $time, lr, in_data, out_data_basic);
            end
        end
        $display("Comparison Finished.");
        $finish;
    end
endmodule
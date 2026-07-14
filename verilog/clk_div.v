// clk_div — 时钟分频器
// 50MHz → 1Hz + 1KHz
module clk_div (
    input  wire clk_50MHz,
    output reg  clk_1Hz,
    output reg  clk_1KHz
);

    // 1Hz: 50,000,000 / 2 = 25,000,000
    parameter CNT_1HZ  = 25_000_000;
    // 1KHz: 50,000,000 / 1000 / 2 = 25,000
    parameter CNT_1KHZ = 25_000;

    reg [24:0] cnt_1hz;
    reg [15:0] cnt_1khz;

    // 1Hz 分频
    always @(posedge clk_50MHz) begin
        if (cnt_1hz == CNT_1HZ - 1) begin
            cnt_1hz <= 0;
            clk_1Hz <= ~clk_1Hz;
        end else begin
            cnt_1hz <= cnt_1hz + 1;
        end
    end

    // 1KHz 分频
    always @(posedge clk_50MHz) begin
        if (cnt_1khz == CNT_1KHZ - 1) begin
            cnt_1khz <= 0;
            clk_1KHz <= ~clk_1KHz;
        end else begin
            cnt_1khz <= cnt_1khz + 1;
        end
    end

endmodule

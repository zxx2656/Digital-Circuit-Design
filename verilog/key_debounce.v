// key_debounce — 按键消抖 + 两级同步器
// 1KHz采样，连续20次同值才输出，消抖≈20ms
module key_debounce (
    input  wire clk_1KHz,
    input  wire sw_rst_raw,
    input  wire sw_pause_raw,
    output wire sw_rst_clean,
    output wire sw_pause_clean
);

    // 两级同步器 + 消抖，分别处理两个开关
    debounce_core u_rst   (.clk(clk_1KHz), .raw(sw_rst_raw),   .clean(sw_rst_clean));
    debounce_core u_pause (.clk(clk_1KHz), .raw(sw_pause_raw), .clean(sw_pause_clean));

endmodule


// debounce_core — 消抖核心（可复用）
module debounce_core (
    input  wire clk,
    input  wire raw,
    output reg  clean
);

    reg sync1, sync2;      // 两级同步
    reg [4:0] cnt;         // 采样计数器，0~20
    reg       prev_sync;

    // 两级同步器 — 消除亚稳态
    always @(posedge clk) begin
        sync1 <= raw;
        sync2 <= sync1;
    end

    // 消抖逻辑 — 连续20次同值才更新输出
    always @(posedge clk) begin
        if (sync2 != prev_sync) begin
            cnt      <= 0;
            prev_sync <= sync2;
        end else if (cnt < 20) begin
            cnt <= cnt + 1;
        end else begin
            clean <= sync2;
        end
    end

endmodule

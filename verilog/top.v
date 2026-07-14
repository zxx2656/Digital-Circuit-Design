// top — 秒表顶层模块
// 例化全部子模块，连接外部引脚
module top (
    input  wire       clk_50MHz,       // 核心板晶振
    input  wire       SW_RST,          // 拨动开关1: 闭合(0)=启动, 断开(1)=清零
    input  wire       SW_PAUSE,        // 拨动开关2: 闭合(0)=暂停, 断开(1)=恢复
    output wire [7:0] SEG,             // 数码管段选 a~g+dp
    output wire [4:1] DIG,             // 数码管位选 — 共阳极: 0=亮
    output wire       LED_RUN,         // 绿色LED — 计数中亮
    output wire       LED_PAUSE        // 红色LED — 暂停中亮
);

    // 内部信号
    wire clk_1Hz, clk_1KHz;
    wire sw_rst_clean, sw_pause_clean;
    wire count_en, count_clr;
    wire led_run, led_pause;
    wire [15:0] bcd;

    // 模块1: 时钟分频
    clk_div u_clk_div (
        .clk_50MHz (clk_50MHz),
        .clk_1Hz   (clk_1Hz),
        .clk_1KHz  (clk_1KHz)
    );

    // 模块2: 按键消抖
    key_debounce u_key_debounce (
        .clk_1KHz       (clk_1KHz),
        .sw_rst_raw     (SW_RST),
        .sw_pause_raw   (SW_PAUSE),
        .sw_rst_clean   (sw_rst_clean),
        .sw_pause_clean (sw_pause_clean)
    );

    // 模块3: 状态机
    fsm_ctrl u_fsm_ctrl (
        .clk_1Hz        (clk_1Hz),
        .sw_rst_clean   (sw_rst_clean),
        .sw_pause_clean (sw_pause_clean),
        .count_en       (count_en),
        .count_clr      (count_clr),
        .led_run        (led_run),
        .led_pause      (led_pause)
    );

    // 模块4: 60进制计数器
    counter_60 u_counter_60 (
        .clk_1Hz  (clk_1Hz),
        .count_en (count_en),
        .count_clr(count_clr),
        .bcd      (bcd)
    );

    // 模块5: 显示译码
    seg_decoder u_seg_decoder (
        .clk_1KHz (clk_1KHz),
        .bcd      (bcd),
        .seg      (SEG),
        .dig      (DIG)
    );

    // LED 输出
    assign LED_RUN   = led_run;
    assign LED_PAUSE = led_pause;

endmodule

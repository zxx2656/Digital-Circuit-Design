// fsm_ctrl — 控制状态机
// IDLE / COUNT / PAUSE 三态，sw_rst 优先级最高
module fsm_ctrl (
    input  wire clk_1Hz,
    input  wire sw_rst_clean,
    input  wire sw_pause_clean,
    output reg  count_en,
    output reg  count_clr,
    output reg  led_run,
    output reg  led_pause
);

    localparam IDLE  = 3'b001;
    localparam COUNT = 3'b010;
    localparam PAUSE = 3'b100;

    reg [2:0] state, next_state;

    // 时序逻辑 — 状态寄存器
    always @(posedge clk_1Hz) begin
        state <= next_state;
    end

    // 组合逻辑 — 状态转移
    // SW_RST: 闭合(0)=启动, 断开(1)=清零
    // SW_PAUSE: 闭合(0)=暂停, 断开(1)=恢复
    always @(*) begin
        next_state = state;
        case (state)

            IDLE: begin
                if (sw_rst_clean == 1'b0)       // 闭合 → 启动
                    next_state = COUNT;
            end

            COUNT: begin
                if (sw_rst_clean == 1'b1)       // 断开 → 清零（优先）
                    next_state = IDLE;
                else if (sw_pause_clean == 1'b0) // 闭合 → 暂停
                    next_state = PAUSE;
            end

            PAUSE: begin
                if (sw_rst_clean == 1'b1)       // 断开 → 清零（优先）
                    next_state = IDLE;
                else if (sw_pause_clean == 1'b1) // 断开 → 恢复
                    next_state = COUNT;
            end

            default: next_state = IDLE;
        endcase
    end

    // 组合输出
    // 绿灯：计数中亮。红灯：清零/预置或暂停时亮
    always @(*) begin
        count_en   = (state == COUNT);
        count_clr  = (state == IDLE);
        led_run    = (state == COUNT);                      // 绿灯=计数
        led_pause  = (state == IDLE) || (state == PAUSE);   // 红灯=清零/预置/暂停
    end

endmodule

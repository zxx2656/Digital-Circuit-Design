// counter_60 — 60进制BCD计数器
// 4级级联: 秒个→秒十→分个→分十, 59:59+1→00:00
module counter_60 (
    input  wire       clk_1Hz,
    input  wire       count_en,
    input  wire       count_clr,
    output reg [15:0] bcd              // {min_h[3:0], min_l[3:0], sec_h[3:0], sec_l[3:0]}
);

    // 修改这两个参数即可改变预置值（验收时重下载）
    parameter INIT_MIN   = 0;          // 预置分钟 (例: 15→15:45)
    parameter INIT_SEC   = 0;          // 预置秒钟

    // 清零模式: 1=回到00:00, 0=回到预置值
    // 两种都符合课设要求，验收时根据老师要求调整
    parameter CLEAR_TO_ZERO = 1;

    // 直接用 part-select 访问各 BCD 位，不需要额外 wire
    // bcd[3:0]=sec_l, bcd[7:4]=sec_h, bcd[11:8]=min_l, bcd[15:12]=min_h

    // 边界检测：当前值 = 59:59
    wire is_59_59 = (bcd[15:12]==4'd5) && (bcd[11:8]==4'd9) &&
                    (bcd[7:4]==4'd5)  && (bcd[3:0]==4'd9);

    // 进位信号
    wire carry_sl = count_en && (bcd[3:0]   == 4'd9);  // 秒个→秒十
    wire carry_sh = count_en && carry_sl && (bcd[7:4]  == 4'd5);  // 秒十→分个
    wire carry_ml = count_en && carry_sh && (bcd[11:8] == 4'd9);  // 分个→分十

    // 检测 count_clr 下降沿 — 离开 IDLE 时加载预置值
    reg count_clr_prev;
    always @(posedge clk_1Hz) count_clr_prev <= count_clr;
    wire load_init = count_clr_prev && !count_clr;

    // 预置值编码
    wire [15:0] init_val = { (INIT_MIN/10), (INIT_MIN%10),
                             (INIT_SEC/10), (INIT_SEC%10) };

    always @(posedge clk_1Hz or posedge count_clr) begin
        if (count_clr) begin
            // 清零：CLEAR_TO_ZERO=1 → 00:00, =0 → 预置值
            bcd <= CLEAR_TO_ZERO ? 16'd0 : init_val;

        end else if (load_init) begin
            // 从 IDLE 进入 COUNT — 加载预置值
            bcd <= init_val;

        end else if (count_en) begin

            if (is_59_59) begin
                // 59:59 → 直接归零 00:00
                bcd <= 16'd0;

            end else begin
                // 秒个位
                if (bcd[3:0] == 4'd9)
                    bcd[3:0] <= 4'd0;
                else
                    bcd[3:0] <= bcd[3:0] + 1;

                // 秒十位（进位触发）
                if (carry_sl) begin
                    if (bcd[7:4] == 4'd5)
                        bcd[7:4] <= 4'd0;
                    else
                        bcd[7:4] <= bcd[7:4] + 1;
                end

                // 分个位（进位触发）
                if (carry_sh) begin
                    if (bcd[11:8] == 4'd9)
                        bcd[11:8] <= 4'd0;
                    else
                        bcd[11:8] <= bcd[11:8] + 1;
                end

                // 分十位（进位触发）
                if (carry_ml) begin
                    if (bcd[15:12] == 4'd5)
                        bcd[15:12] <= 4'd0;
                    else
                        bcd[15:12] <= bcd[15:12] + 1;
                end
            end

        end
    end

endmodule

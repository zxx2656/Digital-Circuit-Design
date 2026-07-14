// seg_decoder — 显示译码 + 动态扫描
// BCD→7段码(共阳极,0=亮,1=灭) + 4位动态扫描
// DIG[1]=秒个(最右) DIG[2]=秒十 DIG[3]=分个 DIG[4]=分十(最左)
module seg_decoder (
    input  wire       clk_1KHz,
    input  wire [15:0] bcd,           // {min_h, min_l, sec_h, sec_l}
    output reg  [7:0] seg,            // {dp,g,f,e,d,c,b,a}
    output reg  [4:1] dig             // 共阳极: 0=该位亮, 1=灭
);

    wire [3:0] min_h, min_l, sec_h, sec_l;
    assign {min_h, min_l, sec_h, sec_l} = bcd;

    reg [1:0] scan_state;             // 0=关, 1=换图案, 2=开
    reg [2:0] scan_cnt;               // 1→2→3→4→1...

    reg [3:0] current_bcd;

    // 扫描时序 — Break-Before-Make: 关 → 换图案 → 开
    always @(posedge clk_1KHz) begin
        case (scan_state)
            2'd0: begin
                dig        <= 4'b1111;      // 全关
                scan_state <= 2'd1;
            end
            2'd1: begin
                // 根据 scan_cnt 选对应的 BCD
                case (scan_cnt)
                    3'd1: current_bcd = sec_l;   // 秒个
                    3'd2: current_bcd = sec_h;   // 秒十
                    3'd3: current_bcd = min_l;   // 分个
                    3'd4: current_bcd = min_h;   // 分十
                endcase
                scan_state <= 2'd2;
            end
            2'd2: begin
                // 打开对应位 (共阳极: 0=亮)
                case (scan_cnt)
                    3'd1: dig <= 4'b1110;        // 秒个亮
                    3'd2: dig <= 4'b1101;        // 秒十亮
                    3'd3: dig <= 4'b1011;        // 分个亮
                    3'd4: dig <= 4'b0111;        // 分十亮
                endcase
                scan_cnt   <= (scan_cnt == 3'd4) ? 3'd1 : scan_cnt + 1;
                scan_state <= 2'd0;
            end
        endcase
    end

    // 7段译码 — 共阳极: 0=亮, 1=灭 — 纯组合逻辑
    // seg = {dp, g, f, e, d, c, b, a}
    always @(*) begin
        case (current_bcd)
            4'd0: seg = 8'b1100_0000;  // 0
            4'd1: seg = 8'b1111_1001;  // 1
            4'd2: seg = 8'b1010_0100;  // 2
            4'd3: seg = 8'b1011_0000;  // 3
            4'd4: seg = 8'b1001_1001;  // 4
            4'd5: seg = 8'b1001_0010;  // 5
            4'd6: seg = 8'b1000_0010;  // 6
            4'd7: seg = 8'b1111_1000;  // 7
            4'd8: seg = 8'b1000_0000;  // 8
            4'd9: seg = 8'b1001_0000;  // 9
            default: seg = 8'b1111_1111; // 全灭
        endcase
    end

endmodule

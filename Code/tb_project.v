/***************************************************************************
 * Copyright (C) 2026 Intelligent System Architecture (ISA) Lab. All rights reserved. 
 * 
 * This file is written solely for academic use in 
 * AI Accelerator Design course assignment 
 * Department of Electrical and Electronics Engineering, Konkuk University 
 *
 * Unauthorized distribution is strictly prohibited.
 ***************************************************************************/
 
/////////////////////////////////////////////////
/* YOU NEED TO COMPLETE THIS TESTBENCH AS WELL */
/////////////////////////////////////////////////
 
`timescale 1ns / 1ps

module tb_project;

    // 테스트 모드 선택
    // EXTRA_TEST = 0: base 8-batch 테스트
    // EXTRA_TEST = 1: extra 16-batch 테스트
    parameter EXTRA_TEST = 0;
    //parameter EXTRA_TEST = 1;

    // 검사할 output 개수
    // base는 64개, extra는 128개
    localparam integer NUM_OUT = (EXTRA_TEST) ? 128 : 64;

    reg clk;                 // clock 신호
    reg rst;                 // reset 신호
    reg run;                 // project 시작 신호
    reg batch_mode;          // 0: base, 1: extra

    wire done;               // project 연산 완료 신호
    wire [3:0] state;        // project FSM 상태

    wire        re_X;        // X memory read enable
    wire [6:0]  addr_X;      // X memory 주소
    wire [7:0]  data_X;      // X memory에서 읽은 data

    wire        re_W1;       // W1T memory read enable
    wire [5:0]  addr_W1;     // W1T memory 주소
    wire [7:0]  data_W1;     // W1T memory에서 읽은 data

    wire        re_W2;       // W2T memory read enable
    wire [5:0]  addr_W2;     // W2T memory 주소
    wire [7:0]  data_W2;     // W2T memory에서 읽은 data

    wire        we_Y;        // Y memory write enable
    wire [6:0]  addr_Y;      // project가 쓰는 Y memory 주소
    wire [15:0] data_Y;      // project가 쓰는 Y output data

    reg         tb_check;    // 1이면 testbench가 Y memory를 읽음
    reg  [6:0]  tb_addr_Y;   // testbench가 읽을 Y memory 주소
    wire [6:0]  mem_addr_Y;  // 실제 Y memory에 들어가는 주소
    wire        mem_we_Y;    // 실제 Y memory write enable
    wire [15:0] mem_dout_Y;  // Y memory에서 읽은 data

    reg [15:0] golden_Y [0:127]; // 정답 output을 저장하는 배열

    integer i;               // output 비교를 위한 반복 변수
    integer num_correct;     // 맞은 output 개수
    integer num_error;       // 틀린 output 개수

    reg [3:0] prev_state;    // state 변화 출력용 이전 state 저장

    // 계산 중에는 project가 Y memory 주소를 제어하고,
    // 검사 중에는 testbench가 Y memory 주소를 제어한다.
    assign mem_addr_Y = (tb_check) ? tb_addr_Y : addr_Y;

    // 검사 중에는 Y memory에 write하지 않도록 write enable을 0으로 만든다.
    assign mem_we_Y   = (tb_check) ? 1'b0      : we_Y;

    // 10ns period clock 생성, 즉 100MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // project module 인스턴스화
    // FC1, Norm, ReLU, FC2 연산은 모두 project 내부에서 수행된다.
    // testbench는 연산을 직접 하지 않고 결과만 검증한다.
    project U_project (
        .clk        (clk),
        .rst        (rst),
        .run        (run),
        .batch_mode (batch_mode),
        .done       (done),
        .state      (state),

        .re_X       (re_X),
        .addr_X     (addr_X),
        .data_X     (data_X),

        .re_W1      (re_W1),
        .addr_W1    (addr_W1),
        .data_W1    (data_W1),

        .re_W2      (re_W2),
        .addr_W2    (addr_W2),
        .data_W2    (data_W2),

        .we_Y       (we_Y),
        .addr_Y     (addr_Y),
        .data_Y     (data_Y)
    );

generate

// base test일 때 사용하는 memory 설정
if (EXTRA_TEST == 0) begin : BASE_MEM

    // FC1에서 사용할 W1T weight memory
    mem_behavior #(
        .firmware ("data/model/w1_t_hex.txt"),
        .bitline  (8),
        .bitaddr  (6),
        .binary   (0)
    ) U_mem_W1T (
        .clk  (clk),
        .en   (re_W1),
        .we   (1'b0),
        .addr (addr_W1),
        .din  (8'd0),
        .dout (data_W1)
    );

    // FC2에서 사용할 W2T weight memory
    mem_behavior #(
        .firmware ("data/model/w2_t_hex.txt"),
        .bitline  (8),
        .bitaddr  (6),
        .binary   (0)
    ) U_mem_W2T (
        .clk  (clk),
        .en   (re_W2),
        .we   (1'b0),
        .addr (addr_W2),
        .din  (8'd0),
        .dout (data_W2)
    );

    // base input X memory
    mem_behavior #(
        .firmware ("data/inout_base/x_hex.txt"),
        .bitline  (8),
        .bitaddr  (7),
        .binary   (0)
    ) U_mem_X (
        .clk  (clk),
        .en   (re_X),
        .we   (1'b0),
        .addr (addr_X),
        .din  (8'd0),
        .dout (data_X)
    );

    // base 정답 output을 golden_Y에 저장
    initial begin
        $readmemh("data/inout_base/y_hex.txt", golden_Y);
    end

end else begin : EXTRA_MEM

    // extra test에서도 W1T weight는 동일하게 사용
    mem_behavior #(
        .firmware ("data/model/w1_t_hex.txt"),
        .bitline  (8),
        .bitaddr  (6),
        .binary   (0)
    ) U_mem_W1T (
        .clk  (clk),
        .en   (re_W1),
        .we   (1'b0),
        .addr (addr_W1),
        .din  (8'd0),
        .dout (data_W1)
    );

    // extra test에서도 W2T weight는 동일하게 사용
    mem_behavior #(
        .firmware ("data/model/w2_t_hex.txt"),
        .bitline  (8),
        .bitaddr  (6),
        .binary   (0)
    ) U_mem_W2T (
        .clk  (clk),
        .en   (re_W2),
        .we   (1'b0),
        .addr (addr_W2),
        .din  (8'd0),
        .dout (data_W2)
    );

    // extra input X memory
    mem_behavior #(
        .firmware ("data/inout_extra/x_hex.txt"),
        .bitline  (8),
        .bitaddr  (7),
        .binary   (0)
    ) U_mem_X (
        .clk  (clk),
        .en   (re_X),
        .we   (1'b0),
        .addr (addr_X),
        .din  (8'd0),
        .dout (data_X)
    );

    // extra 정답 output을 golden_Y에 저장
    initial begin
        $readmemh("data/inout_extra/y_hex.txt", golden_Y);
    end

end
endgenerate

    // project가 계산한 최종 Y를 저장하는 output memory
    // 정답값으로 초기화하지 않고, project의 계산 결과를 저장하는 용도이다.
    mem_behavior #(
        .firmware (""),
        .bitline  (16),
        .bitaddr  (7),
        .binary   (0)
    ) U_mem_Y (
        .clk  (clk),
        .en   (1'b1),
        .we   (mem_we_Y),
        .addr (mem_addr_Y),
        .din  (data_Y),
        .dout (mem_dout_Y)
    );

    // 전체 testbench 동작 순서
    initial begin
        rst        = 1'b1;          // 처음에는 reset 상태
        run        = 1'b0;          // run은 처음에 0
        batch_mode = EXTRA_TEST[0]; // EXTRA_TEST에 맞춰 batch_mode 설정
        tb_check   = 1'b0;          // 처음에는 project가 Y memory를 제어
        tb_addr_Y  = 7'd0;          // Y memory 검사 주소 초기화

        i = 0;                      // 반복 변수 초기화
        num_correct = 0;            // correct count 초기화
        num_error   = 0;            // error count 초기화
        prev_state  = 4'hf;         // 이전 state 초기화

        #20;

        // 현재 test mode 출력
        $display("==================================================");
        if (EXTRA_TEST)
            $display("TEST MODE: EXTRA 16-batch");
        else
            $display("TEST MODE: BASE 8-batch");
        $display("==================================================");

        // golden file이 제대로 읽혔는지 확인하기 위한 출력
        $display("golden_Y[0] = %h", golden_Y[0]);
        $display("golden_Y[1] = %h", golden_Y[1]);

        // reset을 10 clock 동안 유지
        repeat (10) @(posedge clk);
        rst <= 1'b0;

        // reset 해제 후 몇 cycle 대기
        repeat (5) @(posedge clk);

        // run을 한 clock 동안 1로 만들어 project 시작
        run <= 1'b1;
        @(posedge clk);
        run <= 1'b0;

        $display("[TB] Project started at time %0t", $time);

        // project가 done을 올릴 때까지 대기
        wait(done == 1'b1);

        $display("[TB] Project done at time %0t", $time);

        // output memory를 읽기 전 잠깐 대기
        repeat (5) @(posedge clk);

        // 이제 testbench가 Y memory를 읽기 시작
        tb_check <= 1'b1;
        repeat (2) @(posedge clk);

        // Y memory의 값을 순서대로 읽어서 golden_Y와 비교
        for (i = 0; i < NUM_OUT; i = i + 1) begin
            tb_addr_Y <= i[6:0];    // 읽을 Y address 설정

            @(posedge clk);
            #2;                     // read data 안정화를 위한 짧은 delay

            if (mem_dout_Y === golden_Y[i]) begin
                num_correct = num_correct + 1;
                $display("[CORRECT] Y[%0d] = %h", i, mem_dout_Y);
            end else begin
                num_error = num_error + 1;
                $display("[WRONG]   Y[%0d] = %h, expected = %h",
                         i, mem_dout_Y, golden_Y[i]);
            end
        end

        // output checking 종료
        tb_check <= 1'b0;

        // 최종 결과 출력
        $display("==================================================");
        $display("RESULT: correct = %0d, error = %0d, total = %0d",
                 num_correct, num_error, NUM_OUT);

        if (num_error == 0)
            $display("PASS: All outputs are correct.");
        else
            $display("FAIL: Some outputs are wrong.");

        $display("==================================================");

        #100;
        $finish;
    end

    // timeout 방지용 코드
    // done이 너무 오래 올라오지 않으면 simulation을 종료한다.
    initial begin
        #10000000;
        $display("[TB ERROR] Timeout. done was not asserted.");
        $finish;
    end

    // state가 바뀔 때마다 현재 state와 done 값을 출력
    always @(posedge clk) begin
        if (!rst && state != prev_state) begin
            $display("[TIME %0t] state = %0d, done = %b", $time, state, done);
            prev_state <= state;
        end
    end

endmodule
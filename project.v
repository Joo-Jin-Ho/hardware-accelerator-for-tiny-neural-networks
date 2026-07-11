`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/03 16:08:52
// Design Name: 
// Module Name: project
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cla4(                          	// 4비트 덧셈기 모듈 선언
    input  [3:0] A,                     	// 4비트 입력값 A 선언
    input  [3:0] B,                     	// 4비트 입력값 B 선언
    input        Cin,                   	// 초기 carry 입력값 선언
    output [3:0] S,                     	// 4비트 출력값 S 선언
    output       Cout,                  	// 최종 carry 출력값 선언
    output       G_group,               	// Generate 신호그룹 선언
    output       P_group                	// Propagate 신호그룹 선언
);
    wire [3:0] G, P;                    	// 각 비트별 Generate와 Propagate
    wire [3:1] C;                       	// 중간 내부 carry 비트
    
    assign G = A & B;                   	// A와 B가 모두 1이면 무조건 캐리가 발생 => 무조건 윗자리로 자리올림을 한다. (Carry 발생여부)
    assign P = A ^ B;                   	// A와 B 둘 중 하나가 1이면 하위 캐리를 다음으로 전달 (Carry를 전달할 수 있는지 확인)
                                        	// 모든 비트의 캐리를 거의 동시에 계산하므로 비트 수가 많아져도 연산 속도가 매우 빨라진다.
                                                                                                        
    assign C[1] = G[0]|(P[0]&Cin);                                                                      				// S[1]을 계산할 때 사용할 Carry를 계산
    assign C[2] = G[1]|(P[1]&G[0])|(P[1]&P[0]&Cin);                                                     				// S[2]을 계산할 때 사용할 Carry를 계산
    assign C[3] = G[2]|(P[2]&G[1])|(P[2]&P[1]&G[0])|(P[2]&P[1]&P[0]&Cin);                               			// S[3]을 계산할 때 사용할 Carry를 계산
    assign Cout = G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0])|(P[3]&P[2]&P[1]&P[0]&Cin);   	// 4비트 덧셈기에서 출력될 Cout을 계산
                        
    assign S[0] = P[0]^Cin;             // 계산 결과값인 S의 S[0]을 계산
    assign S[1] = P[1]^C[1];            // 계산 결과값인 S의 S[1]을 계산
    assign S[2] = P[2]^C[2];            // 계산 결과값인 S의 S[2]을 계산
    assign S[3] = P[3]^C[3];            // 계산 결과값인 S의 S[3]을 계산
    
    assign G_group = G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0]);                         // Carry를 만들었고, Group 밖으로 나갈 수 있는지 계산
    assign P_group = P[3]&P[2]&P[1]&P[0];                                                             		// Carry를 통과시킬 수 있는지 계산
    
endmodule                                   // 모듈 선언 끝

// -------------------------------------------------------
// 8-bit Carry Lookahead Adder 
// -------------------------------------------------------

module cla8(                          		// 8비트 덧셈기 모듈 선언
    input  [7:0] A,                     	// 8비트 입력값 A 선언
    input  [7:0] B,                     	// 8비트 입력값 B 선언
    input        Cin,                   	// 초기 carry 입력값 선언
    output [7:0] S,                    		// 8비트 출력값 S 선언
    output       Cout,                		// 최종 carry 출력값 선언
    output       G_group,                	// Generate 신호그룹 선언
    output       P_group                 	// Propagate 신호그룹 선언
);                         
    wire C8;                             	// A4_1에서 출력되는 P,G group을 통해 계산한 A4_2의 입력 carry 값
    wire G0, G1;                        	// A4_1에서 출력되는 Generate 신호그룹
    wire P0, P1;                        	// A4_1에서 출력되는 Propagate 신호그룹
    
    assign C8 = G0|(P0&Cin);            	// input만으로 A4_2에 전달할 carry 계산
    assign G_group = G1|(P1&G0);  		    // 8bit만으로 계산된 Generate
    assign P_group = P1&P0;             	// 8bit만으로 계산된 Propagate
    
    cla4 A4_1(.A(A[3:0]),.B(B[3:0]),.Cin(Cin),.S(S[3:0]),.Cout(),.G_group(G0),.P_group(P0)); // LSB 4bit 연산 
    
    cla4 A4_2(.A(A[7:4]),.B(B[7:4]),.Cin(C8),.S(S[7:4]),.Cout(Cout),.G_group(G1),.P_group(P1)); // MSB 4bit 연산
endmodule                               	// 모듈 선언 끝

// -------------------------------------------------------
// 16-bit Carry Lookahead Adder
// -------------------------------------------------------

module cla16(                          		   // 16비트 덧셈기 모듈 선언
    input  [15:0] A,                     		// 16비트 입력값 A 선언
    input  [15:0] B,                     		// 16비트 입력값 B 선언
    input        Cin,                   		// 초기 carry 입력값 선언
    output [15:0] S,                    		// 16비트 출력값 S 선언
    output        Cout,
    output        G_group,                 	    // 출력 포트 추가
    output        P_group          		        // 최종 carry 출력값 선언
);                 
    wire C16;                             		// A8_1에서 출력되는 P,G group을 통해 계산한 A8_2의 입력 carry 값
    wire G0, G1;                        		// A8_1, A8_2에서 출력되는 Generate 신호그룹
    wire P0, P1;                        		// A8_1, A8_2에서 출력되는 Propagate 신호그룹
    
    assign C16 = G0 | (P0 & Cin);            	// input만으로 A8_2에 들어가는 Carry값 계산
    
    cla8 A8_1(.A(A[7:0]),.B(B[7:0]),.Cin(Cin),.S(S[7:0]),.Cout(),.G_group(G0),.P_group(P0));            	// LSB 8비트 연산
    
    cla8 A8_2(.A(A[15:8]),.B(B[15:8]),.Cin(C16),.S(S[15:8]),.Cout(Cout),.G_group(G1),.P_group(P1));         // MSB 8비트 연산
    
endmodule                                   // 모듈 선언 끝

// -------------------------------------------------------
// 4-bit Multiplier (signed)
// -------------------------------------------------------

module sign_mult4(                          // signed 4비트 곱셈기 모듈 선언
    input  [3:0] A,                     	// 4비트 입력값 A 선언
    input  [3:0] B,                     	// 4비트 입력값 B 선언
    output [7:0] P                      	// 8비트 출력값 P 선언
);
    wire [7:0] out1;                    	// A와 B[0]을 연산한 값을 8비트로 확장한 값
    wire [7:0] out2;                    	// A와 B[1]을 연산한 값을 8비트로 확장한 값
    wire [7:0] out3;                    	// A와 B[2]을 연산한 값을 8비트로 확장한 값
    wire [7:0] out4;                    	// A와 B[3]을 연산한 값을 8비트로 확장한 값
    wire Cin = 0;                       	// 초기 carry 입력값
    wire [7:0] S1;                      	// out1과 out2를 8비트 덧셈기에서 계산한 값
    wire [7:0] S2;                      	// out3와 out4를 8비트 덧셈기에서 계산한 값 
    
    assign out1 = {{4{A[3] & B[0]}}, (A & {4{B[0]}})};                                      // B의 비트가 1일 때만 A[3]로 확장하고 0이면 0으로 확장한다.
                                                                                    		// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    assign out2 = {{3{A[3] & B[1]}}, (A & {4{B[1]}}), 1'b0};                                // B의 비트가 1일 때만 A[3]로 확장하고 0이면 0으로 확장한다.
                                                                                    		// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    assign out3 = {{2{A[3] & B[2]}}, (A & {4{B[2]}}), 2'b0};                                // B의 비트가 1일 때만 A[3]로 확장하고 0이면 0으로 확장한다.
                                                                                    		// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    assign out4 = B[3] ? ({{1{~A[3]}}, (~A), 3'b0} + 8'b00001000) : 8'b0;   	            // B의 비트가 1일 때 A를 3칸 시프트한 값의 2의 보수
                                                                                    		// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    
    cla8 A8_1(.A(out1),.B(out2),.Cin(Cin),.S(S1),.Cout(),.G_group(),.P_group());            // S1을 계산하기 위해 8-bit Adder 이용
    
    cla8 A8_2(.A(out3),.B(out4),.Cin(Cin),.S(S2),.Cout(),.G_group(),.P_group());            // S2을 계산하기 위해 8-bit Adder 이용
    
    cla8 A8_3(.A(S1),.B(S2),.Cin(Cin),.S(P),.Cout(),.G_group(),.P_group());                 // P를 계산하기 위해 8-bit Adder 이용
endmodule                                   // 모듈 선언 끝

// -------------------------------------------------------
// 4-bit Multiplier (unsigned)
// -------------------------------------------------------

module unsign_mult4(                  	    // unsigned 4비트 곱셈기 모듈 선언
    input  [3:0] A,                     	// 4비트 입력값 A 선언
    input  [3:0] B,                     	// 4비트 입력값 B 선언
    output [7:0] P                      	// 8비트 출력값 P 선언
);
    wire [7:0] out1;                    	// A와 B[0]을 연산한 값을 8비트로 확장한 값
    wire [7:0] out2;                    	// A와 B[1]을 연산한 값을 8비트로 확장한 값
    wire [7:0] out3;                    	// A와 B[2]을 연산한 값을 8비트로 확장한 값
    wire [7:0] out4;                    	// A와 B[3]을 연산한 값을 8비트로 확장한 값
    wire Cin = 0;                       	// 초기 carry 입력값
    wire [7:0] S1;                      	// out1과 out2를 8비트 덧셈기에서 계산한 값
    wire [7:0] S2;                      	// out3와 out4를 8비트 덧셈기에서 계산한 값
    
    assign out1 = {4'b0, {A & {4{B[0]}}}};                                          	// B의 비트가 1일 때만 A[3]로 확장하고 0이면 0으로 확장한다.
                                                                                   	     	// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    assign out2 = {3'b0, {A & {4{B[1]}}}, 1'b0};                                    	// B의 비트가 1일 때만 A[3]로 확장하고 0이면 0으로 확장한다.
                                                                                    		// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    assign out3 = {2'b0, {A & {4{B[2]}}}, 2'b0};                                    	// B의 비트가 1일 때만 A[3]로 확장하고 0이면 0으로 확장한다.
                                                                                    		// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    assign out4 = {1'b0, {A & {4{B[3]}}}, 3'b0};                                    	// B의 비트가 1일 때 A를 3칸 시프트한 값의 2의 보수
                                                                                    		// 8비트 계산을 위해 4비트를 8비트로 확장한다.
    
    cla8 A8_1(.A(out1),.B(out2),.Cin(Cin),.S(S1),.Cout(),.G_group(),.P_group());    	// S1을 계산하기 위해 8-bit Adder 이용
    
    cla8 A8_2(.A(out3),.B(out4),.Cin(Cin),.S(S2),.Cout(),.G_group(),.P_group());    	// S2을 계산하기 위해 8-bit Adder 이용
    
    cla8 A8_3(.A(S1),.B(S2),.Cin(Cin),.S(P),.Cout(),.G_group(),.P_group());         	// P를 계산하기 위해 8-bit Adder 이용
endmodule                                   // 모듈 선언 끝

// -------------------------------------------------------
// 4-bit Multiplier (signed*unsigned)
// -------------------------------------------------------

module mix_mult4(                          	// unsigned*signed 4비트 곱셈기 모듈 선언
    input  [3:0] A,                     		// 4비트 입력값 A 선언 (signed)
    input  [3:0] B,                    	    	// 4비트 입력값 B 선언 (unsigned)
    output [7:0] P                      		// 8비트 출력값 P 선언
);
    wire [3:0] A1;                          		// A의 부호에 따라 값이 달라는 값
    wire [7:0] R;                           		// A1와 B의 unsigned 연산의 결과값
    
    assign A1 = (A[3]) ? (~A+1'b1) : A ;    	// A[3]=1일때는 A의 부호 바꿈, A[3]=0일때는 A 그대로 유지
    
    unsign_mult4 um(.A(A1),.B(B),.P(R));    	// A가 양수일때는 그대로 A*B unsigned 연산, A가 음수일때는 A의 부호를 바꾼후 (-A)*B unsigned 연산
    
    assign P = (A[3]) ? (~R+1'b1) : R;      	// A[3]=1일때는 그대로 A*B unsigned 연산, A가 음수일때는 A의 부호를 바꾼후 (-A)*B unsigned 연산후에 R의 부호를 바꿔줌 
endmodule                                   	// 모듈 선언 끝


module mad8(
    input   clk,                            	// input에 clk 선언
    input   rst,                            	// input에 rst 선언
    input	en,                            // input에 en 선언
    input   [7:0]   A,                      	// input에 8비트 A선언
    input   [7:0]   B,                      	// input에 8비트 B선언
    input   [15:0]  C,                      	// input에 16비트 C선언
    output  reg	  busy,               // output에 reg로 busy 선언
    output  reg   [15:0] P               	// output에 reg로 16비트 P선언
);
    wire [3:0] a1,a2,b1,b2;               		// 4비트 a1,a2,b1,b2 선언   (A와 B의 MSB,LSB)
    wire [7:0] c1,c2,c3,c4;                		// 8비트 c1,c2,c3,c4 선언   (a1,a2,b1,b2 연산 결과값)
    wire [15:0] C1,C2,C3,C4;                	// 16비트 C1,C2,C3,C4 선언  (c1,c2,c3,c4 16비트 확장값)
    wire [15:0] add = (count == 0) ? C1:    // count가 0일때 add = C1
                      (count == 1) ? C2:    	// count가 1일때 add = C2
                      (count == 2) ? C3:    	// count가 2일때 add = C3
                      (count == 3) ? C4:    	// count가 3일때 add = C4
                      0;                    		// 다른 경우에는 add = 0
    wire [15:0] S1,S2;                      	// reg 16비트 S1,S2 선언  (P에 넣을 값) 
    reg [1:0] count;                        	// 2비트 count 선언       (clk 횟수 계산)
    reg [15:0] result;                      		// reg 16비트 result 선언 (clk마다의 계산결과값 저장)
    
    assign a1 = A[3:0];                     	// A의 LSB 4비트 선언
    assign a2 = A[7:4];                     	// A의 MSB 4비트 선언
    assign b1 = B[3:0];                     	// B의 LSB 4비트 선언
    assign b2 = B[7:4];                     	// B의 MSB 4비트 선언
        
    unsign_mult4 um(.A(a1),.B(b1),.P(c1));  	// A와 B의 LSB 4비트를 unsigned multi로 연산
    mix_mult4 sm1(.A(a2),.B(b1),.P(c2));    	// A의 MSB 4비트와 B의 LSB 4비트를 mixed multi로 연산 (A는 signed, B는 unsigned)
    mix_mult4 sm2(.A(b2),.B(a1),.P(c3));    	// A의 LSB 4비트와 B의 MSB 4비트를 mixed multi로 연산 (A는 unsigned, B는 signed)
    sign_mult4 sm3(.A(a2),.B(b2),.P(c4));   	// A의 B의 MSB 4비트를 signed multi로 연산
    
    assign C1 = {8'b0, c1[7:0]};                 // c1을 16비트로 만들기 위해 shift
    assign C2 = {{4{c2[7]}}, c2[7:0], 4'b0};    // c2를 16비트로 만들기 위해 shift
    assign C3 = {{4{c3[7]}}, c3[7:0], 4'b0};    // c3를 16비트로 만들기 위해 shift
    assign C4 = {c4[7:0], 8'b0};                 // c4를 16비트로 만들기 위해 shift
    
    cla16 A16_1(.A(result),.B(add),.Cin(1'b0),.S(S1),.Cout(),.G_group(),.P_group());      	// result에 저장된 값과 add(ex.C1,C2,C3,C4)를 16bit 덧셈 수행으로 누적
    cla16 A16_2(.A(C1),.B(C),.Cin(1'b0),.S(S2),.Cout(),.G_group(),.P_group());            	// C1과 C를 더하는 첫번째 연산 실행
    
    
    always @(posedge clk or posedge rst) begin                     // clk, rst가 positive edge 될때마다 update
        if (rst) begin                              	// rst가 1일때 실행
        count <= 0;                              	// rst가 1일때 count = 0
        busy <= 0;                               	// rst가 1일때 busy = 0
        result <= 0;                              	// rst가 1일때 result = 0
        P <= 0;                                   	// rst가 1일때 P = 0
        end                                         
        else if (en||busy) begin                    	// rst이 0, en&busy=1 일때 실행
            case (count)                            	// count값에 따라 실행
                0 :                                 		// count = 0일때 실행, C에 C1를 더하는 작업 실행
                begin   
                    if(en) begin                    		// en이 1일때 실행 (입력이 들어올 때) 
                    busy <= 1;                      	// busy값 1 저장
                    count <= count + 1;             	// count값 1 증가
                    result <= S2;                   	// result에 C + C1 저장
                    P <= result;                    		// C + C1 + C2 + C3 + C4 출력
                    end else                        		// en이 0일때 (입력이 안들어왔을때)
                        busy <= 0;                  	// busy값 0 저장
                end
                1 :                                 		// count = 1일때 실행, result에 C2를 더하는 작업 실행
                begin
                    count <= count + 1;             	// count값 1 증가
                    result <= S1;                   	// result에 C + C1 + C2 저장
                    P <= result;                    		// C + C1 출력
                end
                2 :                                 		// count = 2일때 실행, result에 C3를 더하는 작업 실행
                begin
                    count <= count + 1;             	// count값 1 증가
                    P <= result;                    		// C + C1 + C2 출력
                    result <= S1;                   	// result에 C + C1 + C2 + C3 저장
                end
                3 :                                 		// count = 3일때 실행, result에 C4를 더하는 작업 실행
                begin
                    count <= 0;                     	// count값 0으로 저장
                    P <= result;                    		// C + C1 + C2 + C3 출력
                    result <= S1;                   	// result에 C + C1 + C2 + C3 + C4 저장
                end
          endcase                                   		// case문 종료
         end                                        		// en&busy 값에 대한 if문 선언 종료
       end                                          
                
endmodule                                           	// 모듈 선언 끝


module se8 (                              // 8비트 systolic element 하나를 만드는 모듈
    input               clk,              // 클럭 입력
    input               rst,              // 리셋 입력
    input               en,               // 현재 SE가 연산을 시작할지 정하는 enable 신호
    input               pre_fill,         // weight 값을 미리 채우는 신호
    input   [7:0]       data_from_left,   // 왼쪽 SE에서 들어오는 A 데이터
    input   [15:0]      data_from_top,    // 위쪽 SE에서 들어오는 partial sum 또는 weight 데이터
    output  reg [7:0]   data_to_right,    // 오른쪽 SE로 넘겨줄 A 데이터
    output  reg [15:0]  data_to_bottom,   // 아래쪽 SE로 넘겨줄 partial sum 데이터
    output  reg         busy,             // 현재 SE가 동작 중인지 알려주는 신호
    output              en_to_right       // 오른쪽 SE에게 넘겨줄 enable 신호
);

    reg [7:0] weight;                     // 이 SE 안에 저장될 weight 값
    reg [2:0] pf_count;                   // pre_fill 신호를 몇 클럭 동안 유지할지 관리하는 레지스터

    always @(posedge clk or posedge rst) begin     // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                             // 리셋이 들어오면
            pf_count <= 3'b000;                    // pre_fill 카운터를 0으로 초기화
        end else begin                             // 리셋이 아니면
            pf_count <= {pf_count[1:0], pre_fill}; // pre_fill 값을 shift해서 3클럭 동안 기억
        end
    end

    wire pf_mode;                                  // 현재 weight를 채우는 모드인지 나타내는 신호
    assign pf_mode = pre_fill | pf_count[0] | pf_count[1] | pf_count[2]; // pre_fill이 들어온 뒤 몇 클럭 동안 pf_mode 유지

    always @(posedge clk or posedge rst) begin     // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                             // 리셋이면
            weight <= 8'd0;                        // weight를 0으로 초기화
        end else if (pf_mode) begin                // pre_fill 모드이면
            weight <= data_from_top[7:0];          // 위에서 들어온 값의 하위 8비트를 weight로 저장
        end
    end

    reg [7:0]  hold_A;                             // en이 꺼진 뒤에도 A 값을 잠깐 저장하는 레지스터
    reg [15:0] hold_C;                             // en이 꺼진 뒤에도 C 값을 잠깐 저장하는 레지스터

    always @(posedge clk or posedge rst) begin     // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                             // 리셋이면
            hold_A <= 8'd0;                        // hold_A를 0으로 초기화
            hold_C <= 16'd0;                       // hold_C를 0으로 초기화
        end else if (en) begin                     // en이 1이면
            hold_A <= data_from_left;              // 현재 들어온 A 값을 저장
            hold_C <= data_from_top;               // 현재 들어온 C 값을 저장
        end
    end

    wire [7:0]  mad_A;                             // mad8에 넣을 A 데이터
    wire [15:0] mad_C;                             // mad8에 넣을 C 데이터

    assign mad_A = en ? data_from_left : hold_A;   // en이 1이면 새 A 사용, 아니면 저장해둔 A 사용
    assign mad_C = en ? data_from_top  : hold_C;   // en이 1이면 새 C 사용, 아니면 저장해둔 C 사용

    reg [4:0] en_pipe;                             // en 신호를 지연시키기 위한 shift register

    always @(posedge clk or posedge rst) begin     // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                             // 리셋이면
            en_pipe <= 5'b00000;                   // en_pipe를 0으로 초기화
        end else begin                             // 리셋이 아니면
            en_pipe <= {en_pipe[3:0], en};         // en 신호를 한 칸씩 밀어서 저장
        end
    end

    wire flush_en;                                 // mad8의 마지막 계산을 밀어주는 신호
    wire out_valid;                                // mad8 결과가 유효해지는 시점을 나타내는 신호
    wire mad_en;                                   // mad8에 실제로 넣을 enable 신호

    assign flush_en  = en_pipe[3];                 // en이 들어온 뒤 4클럭 후 flush_en 발생
    assign out_valid = en_pipe[4];                 // en이 들어온 뒤 5클럭 후 결과 유효
    assign mad_en    = en | flush_en;              // 처음 en 또는 flush 시점에 mad8 동작

    wire        mad_busy;                          // mad8이 동작 중인지 나타내는 신호
    wire [15:0] mad_P;                             // mad8에서 나온 계산 결과

    mad8 U_MAD8 (                                  // 8비트 multiply-add 모듈 연결
        .clk  (clk),                               // mad8에 clk 연결
        .rst  (rst),                               // mad8에 rst 연결
        .en   (mad_en),                            // mad8에 enable 연결
        .A    (mad_A),                             // mad8의 A 입력에 mad_A 연결
        .B    (weight),                            // mad8의 B 입력에 저장된 weight 연결
        .C    (mad_C),                             // mad8의 C 입력에 mad_C 연결
        .busy (mad_busy),                          // mad8의 busy 출력 연결
        .P    (mad_P)                              // mad8의 결과 P 출력 연결
    );

    always @(posedge clk or posedge rst) begin     // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                             // 리셋이면
            data_to_right <= 8'd0;                 // 오른쪽으로 보낼 데이터를 0으로 초기화
        end else if (en) begin                     // en이 1이면
            data_to_right <= data_from_left;       // 왼쪽에서 온 A 데이터를 오른쪽으로 전달
        end
    end

    assign en_to_right = out_valid;                // 결과가 유효해지는 타이밍에 오른쪽 SE도 동작하게 함

    reg [15:0] psum_hold;                          // 마지막 partial sum 값을 저장하는 레지스터

    always @(posedge clk or posedge rst) begin     // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                             // 리셋이면
            psum_hold <= 16'd0;                    // psum_hold를 0으로 초기화
        end else if (out_valid) begin              // mad8 결과가 유효하면
            psum_hold <= mad_P;                    // mad8 결과를 저장
        end
    end

    always @(*) begin                              // 입력이 바뀔 때마다 바로 출력 결정
        if (pf_mode) begin                         // pre_fill 모드이면
            data_to_bottom = {8'd0, weight};       // 저장된 weight를 아래쪽으로 전달
        end else if (out_valid) begin              // 계산 결과가 유효하면
            data_to_bottom = mad_P;                // mad8 결과를 아래쪽으로 전달
        end else begin                             // 둘 다 아니면
            data_to_bottom = psum_hold;            // 이전에 저장한 partial sum을 유지해서 전달
        end
    end

    always @(*) begin                              // busy 신호를 조합논리로 계산
        busy = mad_busy | (|en_pipe);              // mad8이 busy이거나 en_pipe에 값이 남아 있으면 busy = 1
    end

endmodule                                         // se8 모듈 끝

module sa8_4x4 (
    input                   clk,            // 클럭 입력
    input                   rst,            // 리셋 입력
    input                   en,             // systolic array 연산 시작 신호
    input                   pre_fill,       // weight를 미리 채우는 신호
    input       [8*4-1:0]   A,              // 4개의 8비트 A 입력 데이터
    input       [8*4-1:0]   B,              // 4개의 8비트 B 입력 데이터
    output  reg [16*4-1:0]  C,              // 4개의 16비트 결과 출력 데이터
    output  reg             busy            // systolic array가 동작 중인지 나타내는 신호
);

    wire [7:0]  w_A    [0:3][0:4];          // SE 사이를 이동하는 A 데이터 선
    wire [15:0] w_P    [0:4][0:3];          // SE 사이를 이동하는 partial sum 데이터 선
    wire        w_en   [0:3][0:4];          // SE 사이를 이동하는 enable 신호
    wire        w_busy [0:3][0:3];          // 각 SE의 busy 신호

    reg [4:0] en1;                          // 1번째 row enable을 지연시키는 레지스터
    reg [4:0] en2;                          // 2번째 row enable을 지연시키는 레지스터
    reg [4:0] en3;                          // 3번째 row enable을 지연시키는 레지스터

    always @(posedge clk or posedge rst) begin   // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                           // 리셋이 들어오면
            en1 <= 5'd0;                         // en1을 0으로 초기화
            en2 <= 5'd0;                         // en2를 0으로 초기화
            en3 <= 5'd0;                         // en3을 0으로 초기화
        end else begin                           // 리셋이 아니면
            en1 <= {en1[3:0], w_en[0][0]};       // 0번째 row의 시작 enable을 지연시킴
            en2 <= {en2[3:0], w_en[1][0]};       // 1번째 row의 시작 enable을 지연시킴
            en3 <= {en3[3:0], w_en[2][0]};       // 2번째 row의 시작 enable을 지연시킴
        end
    end

    assign w_en[0][0] = en;                // 첫 번째 row는 외부 en으로 시작
    assign w_en[1][0] = en1[4];            // 두 번째 row는 첫 번째 row보다 늦게 시작
    assign w_en[2][0] = en2[4];            // 세 번째 row는 두 번째 row보다 늦게 시작
    assign w_en[3][0] = en3[4];            // 네 번째 row는 세 번째 row보다 늦게 시작

    genvar i;                              // generate문에서 사용할 row 변수
    genvar j;                              // generate문에서 사용할 column 변수

    generate                               // 반복적으로 SE들을 생성하는 블록

        for (i = 0; i < 4; i = i + 1) begin : IN_CONN    // 4개의 입력 연결을 반복
            assign w_A[i][0] = A[8*(4-i)-1 -: 8];        // A 입력을 각 row의 가장 왼쪽에 연결
            assign w_P[0][i] = {8'd0, B[8*(4-i)-1 -: 8]}; // B 입력을 16비트로 만들어 가장 위쪽에 연결
        end

        for (i = 0; i < 4; i = i + 1) begin : ROW        // 4개의 row 생성
            for (j = 0; j < 4; j = j + 1) begin : COL    // 각 row마다 4개의 column 생성

                se8 U_SE (                               // se8 모듈 하나 생성
                    .clk            (clk),               // se8에 clk 연결
                    .rst            (rst),               // se8에 rst 연결
                    .en             (w_en[i][j]),        // 현재 SE의 enable 입력 연결
                    .pre_fill       (pre_fill),          // weight prefill 신호 연결
                    .data_from_left (w_A[i][j]),         // 왼쪽에서 들어오는 A 데이터 연결
                    .data_from_top  (w_P[i][j]),         // 위에서 들어오는 partial sum 또는 B 데이터 연결
                    .data_to_right  (w_A[i][j+1]),       // 오른쪽 SE로 A 데이터 전달
                    .data_to_bottom (w_P[i+1][j]),       // 아래쪽 SE로 partial sum 전달
                    .busy           (w_busy[i][j]),      // 현재 SE의 busy 신호 연결
                    .en_to_right    (w_en[i][j+1])       // 오른쪽 SE로 enable 신호 전달
                );

            end
        end

    endgenerate                            // generate문 종료

    always @(*) begin                      // 입력이 바뀔 때마다 C 출력 결정
        if (rst) begin                     // 리셋이면
            C = 64'd0;                     // 출력 C를 0으로 초기화
        end else begin                     // 리셋이 아니면
            C = {w_P[4][0], w_P[4][1], w_P[4][2], w_P[4][3]}; // 맨 아래로 나온 결과 4개를 C로 묶어서 출력
        end
    end

    always @(*) begin                      // busy 신호를 조합논리로 계산
        if (rst) begin                     // 리셋이면
            busy = 1'b0;                   // busy를 0으로 초기화
        end else begin                     // 리셋이 아니면
            busy = |{                      // 16개의 SE 중 하나라도 busy이면 전체 busy도 1
                w_busy[0][0], w_busy[0][1], w_busy[0][2], w_busy[0][3],
                w_busy[1][0], w_busy[1][1], w_busy[1][2], w_busy[1][3],
                w_busy[2][0], w_busy[2][1], w_busy[2][2], w_busy[2][3],
                w_busy[3][0], w_busy[3][1], w_busy[3][2], w_busy[3][3]
            };
        end
    end

endmodule                                  // sa8_4x4 모듈 끝

module ctrl (                              // 전체 연산 흐름을 제어하는 controller 모듈

    input               clk,               // 클럭 입력
    input               rst,               // 리셋 입력
    input               run,               // 연산 시작 신호
    output  reg [2:0]   state,             // 현재 FSM 상태 출력

    output  reg         re_A,              // A 메모리 read enable
    output  reg [5:0]   addr_A,            // A 메모리 주소
    input       [7:0]   data_A,            // A 메모리에서 읽은 데이터

    output  reg         re_B,              // B 메모리 read enable
    output  reg [5:0]   addr_B,            // B 메모리 주소
    input       [7:0]   data_B,            // B 메모리에서 읽은 데이터

    output  reg         we_C,              // C 메모리 write enable
    output  reg [5:0]   addr_C,            // C 메모리 주소
    output  reg [15:0]  data_C,            // C 메모리에 쓸 데이터

    output  reg         sa_en,             // systolic array enable 신호
    output  reg         sa_prefill,        // systolic array에 weight를 미리 넣는 신호
    input               sa_busy,           // systolic array가 동작 중인지 알려주는 신호
    output  reg [31:0]  sa_data_A,         // systolic array에 넣을 A 데이터 4개
    output  reg [31:0]  sa_data_B,         // systolic array에 넣을 B 데이터 4개
    input       [63:0]  sa_data_C,         // systolic array에서 나온 결과 4개

    output  reg [15:0]  acc_data_P,        // 누산기에 넣을 기존 partial sum
    output  reg [15:0]  acc_data_C,        // 누산기에 넣을 새 계산 결과
    input       [15:0]  acc_out_C          // 누산기에서 나온 덧셈 결과
);

    localparam  IDLE     = 3'b000,         // 대기 상태
                WHT_LOAD = 3'b001,         // B weight를 읽는 상태
                ACT_LOAD = 3'b010,         // A activation을 읽는 상태
                COMP     = 3'b011,         // systolic array로 계산하는 상태
                ACCUM    = 3'b100,         // partial sum을 더하는 상태
                WRITE    = 3'b101;         // 최종 결과를 C 메모리에 쓰는 상태

    localparam  TILE_SIZE       = 'd4,     // tile 크기 4x4
                MAX_TILE_ROW    = 'd2,     // row 방향 tile 개수
                MAX_TILE_COL    = 'd2,     // column 방향 tile 개수
                MAX_TILE_HIDDEN = 'd2;     // hidden 방향 tile 개수

    localparam  PH_READ    = 1'b0,         // 메모리에서 읽는 phase
                PH_PREFILL = 1'b1;         // SA에 weight를 채우는 phase

    reg [7:0]   buf_A  [0:TILE_SIZE-1][0:TILE_SIZE-1];     // A tile을 저장하는 버퍼
    reg [7:0]   buf_B  [0:TILE_SIZE-1][0:TILE_SIZE-1];     // B tile을 저장하는 버퍼
    reg [15:0]  buf_C  [0:TILE_SIZE-1][0:TILE_SIZE-1];     // 두 번째 partial result 저장 버퍼
    reg [15:0]  buf_P0 [0:TILE_SIZE-1][0:TILE_SIZE-1];     // 첫 번째 partial sum 저장 버퍼
    reg [15:0]  buf_P1 [0:TILE_SIZE-1][0:TILE_SIZE-1];     // 추가 partial sum용 버퍼

    reg        phase;                         // WHT_LOAD에서 read/prefill 구분용
    reg        acc_phase;                     // ACCUM에서 입력/저장 단계를 구분

    reg [1:0]  ti;                            // 현재 row tile index
    reg [1:0]  tj;                            // 현재 column tile index
    reg [1:0]  tk;                            // 현재 hidden tile index

    reg [4:0]  read_cnt;                      // 16개 데이터를 읽기 위한 카운터
    reg [4:0]  write_cnt;                     // 16개 데이터를 쓰기 위한 카운터
    reg [2:0]  prefill_cnt;                   // weight prefill 횟수 카운터
    reg [2:0]  row_cnt;                       // SA에 넣을 A row 번호
    reg [4:0]  acc_cnt;                       // 16개 partial sum을 더하기 위한 카운터

    reg        rd_valid_d1;                   // read valid 1클럭 지연 신호
    reg        rd_valid_d2;                   // read valid 2클럭 지연 신호
    reg [3:0]  rd_idx_d1;                     // read index 1클럭 지연값
    reg [3:0]  rd_idx_d2;                     // read index 2클럭 지연값

    reg        comp_started;                  // 현재 row 계산을 시작했는지 표시
    reg        wait_busy_high;                // sa_busy가 1이 되는 것을 기다리는 표시

    wire [2:0] tile_i_base;                   // 현재 A/C tile의 row 시작 위치
    wire [2:0] tile_j_base;                   // 현재 B/C tile의 column 시작 위치
    wire [2:0] tile_k_base;                   // 현재 A/B tile의 hidden 시작 위치

    assign tile_i_base = {ti[0], 2'b00};      // ti에 4를 곱한 값
    assign tile_j_base = {tj[0], 2'b00};      // tj에 4를 곱한 값
    assign tile_k_base = {tk[0], 2'b00};      // tk에 4를 곱한 값

    wire [2:0] rd_local_r;                    // 읽을 때 tile 내부 row 위치
    wire [2:0] rd_local_c;                    // 읽을 때 tile 내부 column 위치
    wire [2:0] wr_local_r;                    // 쓸 때 tile 내부 row 위치
    wire [2:0] wr_local_c;                    // 쓸 때 tile 내부 column 위치

    assign rd_local_r = {1'b0, read_cnt[3:2]};    // read_cnt로 내부 row 계산
    assign rd_local_c = {1'b0, read_cnt[1:0]};    // read_cnt로 내부 column 계산
    assign wr_local_r = {1'b0, write_cnt[3:2]};   // write_cnt로 내부 row 계산
    assign wr_local_c = {1'b0, write_cnt[1:0]};   // write_cnt로 내부 column 계산

    wire [2:0] mem_a_r;                       // A 메모리의 실제 row
    wire [2:0] mem_a_c;                       // A 메모리의 실제 column
    wire [2:0] mem_b_r;                       // B 메모리의 실제 row
    wire [2:0] mem_b_c;                       // B 메모리의 실제 column
    wire [2:0] mem_c_r;                       // C 메모리의 실제 row
    wire [2:0] mem_c_c;                       // C 메모리의 실제 column

    assign mem_a_r = tile_i_base + rd_local_r;    // A의 row 주소 계산
    assign mem_a_c = tile_k_base + rd_local_c;    // A의 column 주소 계산

    assign mem_b_r = tile_k_base + rd_local_r;    // B의 row 주소 계산
    assign mem_b_c = tile_j_base + rd_local_c;    // B의 column 주소 계산

    assign mem_c_r = tile_i_base + wr_local_r;    // C의 row 주소 계산
    assign mem_c_c = tile_j_base + wr_local_c;    // C의 column 주소 계산

    wire [5:0] next_addr_A;                   // 다음 A 메모리 주소
    wire [5:0] next_addr_B;                   // 다음 B 메모리 주소
    wire [5:0] next_addr_C;                   // 다음 C 메모리 주소

    assign next_addr_A = {mem_a_r, 3'b000} + {3'b000, mem_a_c};   // A 주소 = row*8 + col
    assign next_addr_B = {mem_b_r, 3'b000} + {3'b000, mem_b_c};   // B 주소 = row*8 + col
    assign next_addr_C = {mem_c_r, 3'b000} + {3'b000, mem_c_c};   // C 주소 = row*8 + col

    wire [15:0] sa_c0;                        // SA 결과 중 첫 번째 값
    wire [15:0] sa_c1;                        // SA 결과 중 두 번째 값
    wire [15:0] sa_c2;                        // SA 결과 중 세 번째 값
    wire [15:0] sa_c3;                        // SA 결과 중 네 번째 값

    assign sa_c0 = sa_data_C[63:48];          // sa_data_C에서 첫 번째 결과 분리
    assign sa_c1 = sa_data_C[47:32];          // sa_data_C에서 두 번째 결과 분리
    assign sa_c2 = sa_data_C[31:16];          // sa_data_C에서 세 번째 결과 분리
    assign sa_c3 = sa_data_C[15:0];           // sa_data_C에서 네 번째 결과 분리

    wire [4:0] acc_prev;                      // 이전 acc count 값
    assign acc_prev = acc_cnt - 5'd1;         // acc_cnt보다 1 작은 값

    integer init_r;                           // 초기화용 row 변수
    integer init_c;                           // 초기화용 column 변수

    always @(posedge clk or posedge rst) begin    // clk 또는 rst의 positive edge에서 실행
        if (rst) begin                            // 리셋이 들어오면
            state       <= IDLE;                  // 상태를 IDLE로 초기화

            re_A        <= 1'b0;                  // A read 꺼줌
            addr_A      <= 6'd0;                  // A 주소 초기화
            re_B        <= 1'b0;                  // B read 꺼줌
            addr_B      <= 6'd0;                  // B 주소 초기화

            we_C        <= 1'b0;                  // C write 꺼줌
            addr_C      <= 6'd0;                  // C 주소 초기화
            data_C      <= 16'd0;                 // C 데이터 초기화

            sa_en       <= 1'b0;                  // SA enable 초기화
            sa_prefill  <= 1'b0;                  // SA prefill 초기화
            sa_data_A   <= 32'd0;                 // SA A 입력 초기화
            sa_data_B   <= 32'd0;                 // SA B 입력 초기화

            acc_data_P  <= 16'd0;                 // 누산기 P 입력 초기화
            acc_data_C  <= 16'd0;                 // 누산기 C 입력 초기화

            phase       <= PH_READ;               // phase를 read로 초기화
            acc_phase   <= 1'b0;                  // acc phase 초기화

            ti          <= 2'd0;                  // row tile index 초기화
            tj          <= 2'd0;                  // column tile index 초기화
            tk          <= 2'd0;                  // hidden tile index 초기화

            read_cnt    <= 5'd0;                  // read counter 초기화
            write_cnt   <= 5'd0;                  // write counter 초기화
            prefill_cnt <= 3'd0;                  // prefill counter 초기화
            row_cnt     <= 3'd0;                  // row counter 초기화
            acc_cnt     <= 5'd0;                  // accumulation counter 초기화

            rd_valid_d1 <= 1'b0;                  // read valid d1 초기화
            rd_valid_d2 <= 1'b0;                  // read valid d2 초기화
            rd_idx_d1   <= 4'd0;                  // read index d1 초기화
            rd_idx_d2   <= 4'd0;                  // read index d2 초기화

            comp_started   <= 1'b0;               // 계산 시작 표시 초기화
            wait_busy_high <= 1'b0;               // busy 대기 표시 초기화

            for (init_r = 0; init_r < 4; init_r = init_r + 1) begin       // row 0~3 반복
                for (init_c = 0; init_c < 4; init_c = init_c + 1) begin   // column 0~3 반복
                    buf_A[init_r][init_c]  <= 8'd0;      // A 버퍼 초기화
                    buf_B[init_r][init_c]  <= 8'd0;      // B 버퍼 초기화
                    buf_C[init_r][init_c]  <= 16'd0;     // C 버퍼 초기화
                    buf_P0[init_r][init_c] <= 16'd0;     // P0 버퍼 초기화
                    buf_P1[init_r][init_c] <= 16'd0;     // P1 버퍼 초기화
                end
            end

        end else begin                            // 리셋이 아니면
            re_A       <= 1'b0;                   // 기본적으로 A read는 꺼둠
            re_B       <= 1'b0;                   // 기본적으로 B read는 꺼둠
            we_C       <= 1'b0;                   // 기본적으로 C write는 꺼둠
            sa_en      <= 1'b0;                   // 기본적으로 SA enable은 꺼둠
            sa_prefill <= 1'b0;                   // 기본적으로 prefill은 꺼둠

            case (state)                          // 현재 상태에 따라 동작 선택

                IDLE: begin                       // 대기 상태
                    addr_A      <= 6'd0;          // A 주소 초기화
                    addr_B      <= 6'd0;          // B 주소 초기화
                    addr_C      <= 6'd0;          // C 주소 초기화
                    data_C      <= 16'd0;         // C 데이터 초기화

                    sa_data_A   <= 32'd0;         // SA A 입력 초기화
                    sa_data_B   <= 32'd0;         // SA B 입력 초기화

                    acc_data_P  <= 16'd0;         // 누산기 P 입력 초기화
                    acc_data_C  <= 16'd0;         // 누산기 C 입력 초기화

                    phase       <= PH_READ;       // phase를 read로 설정
                    acc_phase   <= 1'b0;          // acc phase 초기화

                    ti          <= 2'd0;          // row tile 초기화
                    tj          <= 2'd0;          // column tile 초기화
                    tk          <= 2'd0;          // hidden tile 초기화

                    read_cnt    <= 5'd0;          // read counter 초기화
                    write_cnt   <= 5'd0;          // write counter 초기화
                    prefill_cnt <= 3'd0;          // prefill counter 초기화
                    row_cnt     <= 3'd0;          // row counter 초기화
                    acc_cnt     <= 5'd0;          // acc counter 초기화

                    rd_valid_d1 <= 1'b0;          // read valid d1 초기화
                    rd_valid_d2 <= 1'b0;          // read valid d2 초기화
                    rd_idx_d1   <= 4'd0;          // read index d1 초기화
                    rd_idx_d2   <= 4'd0;          // read index d2 초기화

                    comp_started   <= 1'b0;       // 계산 시작 표시 초기화
                    wait_busy_high <= 1'b0;       // busy 대기 표시 초기화

                    if (run) begin                // run이 1이면
                        state <= WHT_LOAD;        // B weight를 읽는 상태로 이동
                    end
                end

                WHT_LOAD: begin                   // B tile을 읽고 SA에 weight로 넣는 상태
                    if (phase == PH_READ) begin   // read phase이면

                        if (rd_valid_d2) begin    // 2클럭 전에 요청한 데이터가 유효하면
                            buf_B[rd_idx_d2[3:2]][rd_idx_d2[1:0]] <= data_B; // data_B를 B 버퍼에 저장
                        end

                        rd_valid_d2 <= rd_valid_d1;   // d1 valid를 d2로 넘김
                        rd_idx_d2   <= rd_idx_d1;     // d1 index를 d2로 넘김

                        if (read_cnt < 5'd16) begin   // 16개를 아직 다 안 읽었으면
                            re_B        <= 1'b1;      // B 메모리 read 켜기
                            addr_B      <= next_addr_B; // B 메모리 주소 출력
                            rd_valid_d1 <= 1'b1;      // read 요청 표시
                            rd_idx_d1   <= read_cnt[3:0]; // 현재 read index 저장
                            read_cnt    <= read_cnt + 5'd1; // read counter 증가
                        end else begin                // 16개 read 요청이 끝났으면
                            rd_valid_d1 <= 1'b0;      // 더 이상 read 요청 없음
                            rd_idx_d1   <= 4'd0;      // index 초기화

                            if (!rd_valid_d1 && !rd_valid_d2) begin // 남은 read 데이터까지 다 받았으면
                                read_cnt    <= 5'd0;  // read counter 초기화
                                phase       <= PH_PREFILL; // prefill phase로 이동
                                prefill_cnt <= 3'd0;  // prefill counter 초기화
                            end
                        end

                    end else begin                     // prefill phase이면
                        if (prefill_cnt < 3'd4) begin  // 4번 동안 B row를 넣음

                            sa_prefill <= (prefill_cnt == 3'd0); // 첫 번째 prefill에서만 시작 신호 줌

                            case (prefill_cnt[1:0])    // prefill 순서에 따라 B row 선택
                                2'd0: begin             // 첫 번째 prefill
                                    sa_data_B <= {buf_B[3][0], buf_B[3][1], buf_B[3][2], buf_B[3][3]}; // B의 3번 row 입력
                                end

                                2'd1: begin             // 두 번째 prefill
                                    sa_data_B <= {buf_B[2][0], buf_B[2][1], buf_B[2][2], buf_B[2][3]}; // B의 2번 row 입력
                                end

                                2'd2: begin             // 세 번째 prefill
                                    sa_data_B <= {buf_B[1][0], buf_B[1][1], buf_B[1][2], buf_B[1][3]}; // B의 1번 row 입력
                                end

                                default: begin          // 네 번째 prefill
                                    sa_data_B <= {buf_B[0][0], buf_B[0][1], buf_B[0][2], buf_B[0][3]}; // B의 0번 row 입력
                                end
                            endcase

                            prefill_cnt <= prefill_cnt + 3'd1; // prefill counter 증가

                        end else begin                 // prefill 4번이 끝나면
                            sa_prefill  <= 1'b0;       // prefill 끄기
                            sa_data_B   <= 32'd0;      // SA B 입력 초기화
                            phase       <= PH_READ;    // phase를 read로 되돌림
                            prefill_cnt <= 3'd0;       // prefill counter 초기화
                            read_cnt    <= 5'd0;       // read counter 초기화

                            rd_valid_d1 <= 1'b0;       // read valid 초기화
                            rd_valid_d2 <= 1'b0;       // read valid 초기화
                            rd_idx_d1   <= 4'd0;       // read index 초기화
                            rd_idx_d2   <= 4'd0;       // read index 초기화

                            state       <= ACT_LOAD;   // A를 읽는 상태로 이동
                        end
                    end
                end

                ACT_LOAD: begin                        // A tile을 읽는 상태
                    if (rd_valid_d2) begin             // 2클럭 전에 요청한 데이터가 유효하면
                        buf_A[rd_idx_d2[3:2]][rd_idx_d2[1:0]] <= data_A; // data_A를 A 버퍼에 저장
                    end

                    rd_valid_d2 <= rd_valid_d1;        // d1 valid를 d2로 넘김
                    rd_idx_d2   <= rd_idx_d1;          // d1 index를 d2로 넘김

                    if (read_cnt < 5'd16) begin        // A 데이터를 16개 다 읽지 않았으면
                        re_A        <= 1'b1;           // A 메모리 read 켜기
                        addr_A      <= next_addr_A;    // A 메모리 주소 출력
                        rd_valid_d1 <= 1'b1;           // read 요청 표시
                        rd_idx_d1   <= read_cnt[3:0];  // 현재 index 저장
                        read_cnt    <= read_cnt + 5'd1; // read counter 증가
                    end else begin                     // 16개 read 요청이 끝났으면
                        rd_valid_d1 <= 1'b0;           // read 요청 끄기
                        rd_idx_d1   <= 4'd0;           // index 초기화

                        if (!rd_valid_d1 && !rd_valid_d2) begin // 남은 데이터까지 다 받았으면
                            read_cnt    <= 5'd0;       // read counter 초기화
                            row_cnt     <= 3'd0;       // row counter 초기화

                            comp_started   <= 1'b0;    // 계산 시작 표시 초기화
                            wait_busy_high <= 1'b0;    // busy 대기 표시 초기화

                            state <= COMP;             // 계산 상태로 이동
                        end
                    end
                end

                COMP: begin                            // systolic array 계산 상태
                    sa_data_B <= 32'd0;                // 계산 중에는 B 입력을 0으로 유지

                    if (!comp_started) begin           // 아직 현재 row 계산을 시작 안 했으면
                        sa_data_A <= {                 // A 한 row를 32비트로 묶어서 SA에 입력
                            buf_A[row_cnt][0],         // 현재 row의 0번째 A
                            buf_A[row_cnt][1],         // 현재 row의 1번째 A
                            buf_A[row_cnt][2],         // 현재 row의 2번째 A
                            buf_A[row_cnt][3]          // 현재 row의 3번째 A
                        };

                        sa_en          <= 1'b1;        // SA 연산 시작
                        comp_started   <= 1'b1;        // 계산 시작했다고 표시
                        wait_busy_high <= 1'b1;        // busy가 올라가길 기다림

                    end else begin                     // 이미 계산을 시작했으면
                        sa_en <= 1'b0;                 // SA enable은 한 클럭만 줌

                        if (wait_busy_high) begin      // busy가 1이 되길 기다리는 중이면
                            if (sa_busy) begin         // SA가 busy 상태가 되면
                                wait_busy_high <= 1'b0; // 이제 busy가 내려가길 기다림
                            end
                        end else begin                 // busy가 내려가길 기다리는 중이면
                            if (!sa_busy) begin        // SA 계산이 끝났으면
                                if (tk == 2'd0) begin  // 첫 번째 hidden tile 결과이면
                                    buf_P0[row_cnt][0] <= sa_c0; // 결과 0을 P0에 저장
                                    buf_P0[row_cnt][1] <= sa_c1; // 결과 1을 P0에 저장
                                    buf_P0[row_cnt][2] <= sa_c2; // 결과 2를 P0에 저장
                                    buf_P0[row_cnt][3] <= sa_c3; // 결과 3을 P0에 저장
                                end else begin         // 두 번째 hidden tile 결과이면
                                    buf_C[row_cnt][0] <= sa_c0;  // 결과 0을 C 버퍼에 저장
                                    buf_C[row_cnt][1] <= sa_c1;  // 결과 1을 C 버퍼에 저장
                                    buf_C[row_cnt][2] <= sa_c2;  // 결과 2를 C 버퍼에 저장
                                    buf_C[row_cnt][3] <= sa_c3;  // 결과 3을 C 버퍼에 저장
                                end

                                if (row_cnt == 3'd3) begin      // 4개 row 계산이 모두 끝났으면
                                    row_cnt <= 3'd0;             // row counter 초기화

                                    if (tk == 2'd0) begin        // 첫 번째 hidden tile이 끝났으면
                                        tk        <= 2'd1;       // 다음 hidden tile로 이동
                                        phase     <= PH_READ;    // 다시 read phase로 설정
                                        read_cnt  <= 5'd0;       // read counter 초기화

                                        rd_valid_d1 <= 1'b0;     // read valid 초기화
                                        rd_valid_d2 <= 1'b0;     // read valid 초기화
                                        rd_idx_d1   <= 4'd0;     // read index 초기화
                                        rd_idx_d2   <= 4'd0;     // read index 초기화

                                        state <= WHT_LOAD;       // 다음 B tile을 읽으러 이동
                                    end else begin               // 두 번째 hidden tile까지 끝났으면
                                        acc_cnt   <= 5'd0;       // acc counter 초기화
                                        acc_phase <= 1'b0;       // acc phase 초기화
                                        state     <= ACCUM;      // 누산 상태로 이동
                                    end

                                    comp_started   <= 1'b0;      // 계산 시작 표시 초기화
                                    wait_busy_high <= 1'b0;      // busy 대기 표시 초기화

                                end else begin                   // 아직 남은 row가 있으면
                                    row_cnt <= row_cnt + 3'd1;   // 다음 row로 이동

                                    comp_started   <= 1'b0;      // 다음 row 계산 준비
                                    wait_busy_high <= 1'b0;      // busy 대기 표시 초기화
                                end
                            end
                        end
                    end
                end

                ACCUM: begin                            // partial sum을 더하는 상태
                    if (!acc_phase) begin               // 첫 번째 phase이면
                        acc_data_P <= buf_P0[acc_cnt[3:2]][acc_cnt[1:0]]; // 기존 partial sum을 누산기에 넣음
                        acc_data_C <= buf_C [acc_cnt[3:2]][acc_cnt[1:0]]; // 새 결과를 누산기에 넣음
                        acc_phase  <= 1'b1;             // 다음 phase로 이동
                    end else begin                      // 두 번째 phase이면
                        buf_P0[acc_cnt[3:2]][acc_cnt[1:0]] <= acc_out_C; // 더한 결과를 P0에 저장
                        acc_phase <= 1'b0;              // 다시 첫 번째 phase로 돌아감

                        if (acc_cnt == 5'd15) begin     // 16개를 모두 더했으면
                            acc_cnt   <= 5'd0;          // acc counter 초기화
                            write_cnt <= 5'd0;          // write counter 초기화
                            state     <= WRITE;         // write 상태로 이동
                        end else begin                  // 아직 남은 값이 있으면
                            acc_cnt <= acc_cnt + 5'd1;  // 다음 값으로 이동
                        end
                    end
                end

                WRITE: begin                            // 최종 결과를 C 메모리에 쓰는 상태
                    if (write_cnt < 5'd16) begin        // 16개를 아직 다 안 썼으면
                        we_C      <= 1'b1;              // C 메모리 write 켜기
                        addr_C    <= next_addr_C;       // C 메모리 주소 출력
                        data_C    <= buf_P0[write_cnt[3:2]][write_cnt[1:0]]; // 저장할 결과 출력
                        write_cnt <= write_cnt + 5'd1;  // write counter 증가
                    end else begin                      // 16개 결과를 다 썼으면
                        we_C      <= 1'b0;              // C write 끄기
                        addr_C    <= 6'd0;              // C 주소 초기화
                        data_C    <= 16'd0;             // C 데이터 초기화
                        write_cnt <= 5'd0;              // write counter 초기화

                        tk        <= 2'd0;              // hidden tile index 초기화
                        phase     <= PH_READ;           // phase를 read로 설정
                        read_cnt  <= 5'd0;              // read counter 초기화

                        rd_valid_d1 <= 1'b0;            // read valid 초기화
                        rd_valid_d2 <= 1'b0;            // read valid 초기화
                        rd_idx_d1   <= 4'd0;            // read index 초기화
                        rd_idx_d2   <= 4'd0;            // read index 초기화

                        if (tj < MAX_TILE_COL - 1) begin    // 다음 column tile이 남아 있으면
                            tj    <= tj + 2'd1;             // 다음 column tile로 이동
                            state <= WHT_LOAD;              // 다시 B 읽기부터 시작
                        end else if (ti < MAX_TILE_ROW - 1) begin // 다음 row tile이 남아 있으면
                            ti    <= ti + 2'd1;             // 다음 row tile로 이동
                            tj    <= 2'd0;                  // column tile은 처음으로
                            state <= WHT_LOAD;              // 다시 B 읽기부터 시작
                        end else begin                      // 모든 tile 계산이 끝났으면
                            state <= IDLE;                  // IDLE 상태로 돌아감
                        end
                    end
                end

                default: begin                       // 예외 상태이면
                    state <= IDLE;                   // 안전하게 IDLE로 이동
                end
            endcase                                  // FSM case문 끝
        end
    end

endmodule                                           // ctrl 모듈 끝

module top (                                // 전체 회로를 묶어주는 최상위 모듈
    input               clk,                // 클럭 입력
    input               rst,                // 리셋 입력
    input               run,                // 연산 시작 신호
    output  reg [2:0]   state,              // 현재 controller 상태 출력
    
    output  reg         re_A,               // A 메모리 read enable 출력
    output  reg [5:0]   addr_A,             // A 메모리 주소 출력
    input       [7:0]   data_A,             // A 메모리에서 읽어온 데이터
    
    output  reg         re_B,               // B 메모리 read enable 출력
    output  reg [5:0]   addr_B,             // B 메모리 주소 출력
    input       [7:0]   data_B,             // B 메모리에서 읽어온 데이터
    
    output  reg         we_C,               // C 메모리 write enable 출력
    output  reg [5:0]   addr_C,             // C 메모리 주소 출력
    output  reg [15:0]  data_C              // C 메모리에 저장할 데이터 출력
);

    wire    [2:0]   state_;                 // ctrl에서 나온 state 값을 받는 wire
    wire            re_A_, re_B_, we_C_;    // ctrl에서 나온 메모리 제어 신호를 받는 wire
    wire    [5:0]   addr_A_, addr_B_, addr_C_; // ctrl에서 나온 메모리 주소를 받는 wire
    wire    [15:0]  data_C_;                // ctrl에서 나온 C 저장 데이터를 받는 wire
    
    wire            sa_en, sa_prefill, sa_busy; // systolic array 제어 신호들
    wire    [31:0]  sa_data_A, sa_data_B;   // systolic array에 들어갈 A, B 데이터
    wire    [63:0]  sa_data_C;              // systolic array에서 나온 결과 데이터

    wire    [15:0]  acc_data_C;             // 누산기에 들어갈 새 계산 결과
    wire    [15:0]  acc_data_P;             // 누산기에 들어갈 기존 partial sum
    wire    [15:0]  acc_out_C;              // 누산기에서 나온 덧셈 결과

    always @ (*) begin                      // ctrl 출력값을 top 출력값으로 연결하는 조합논리
        state = state_;                     // 내부 state_를 외부 state로 전달
        re_A = re_A_;                       // 내부 re_A_를 외부 re_A로 전달
        re_B = re_B_;                       // 내부 re_B_를 외부 re_B로 전달
        we_C = we_C_;                       // 내부 we_C_를 외부 we_C로 전달
        addr_A = addr_A_;                   // 내부 addr_A_를 외부 addr_A로 전달
        addr_B = addr_B_;                   // 내부 addr_B_를 외부 addr_B로 전달
        addr_C = addr_C_;                   // 내부 addr_C_를 외부 addr_C로 전달
        data_C = data_C_;                   // 내부 data_C_를 외부 data_C로 전달
    end
    
    ctrl        U_ctrl      (               // controller 모듈 인스턴스 생성
        .clk(clk),                          // ctrl에 clk 연결
        .rst(rst),                          // ctrl에 rst 연결
        .run(run),                          // ctrl에 run 연결
        .state(state_),                     // ctrl의 state 출력을 state_에 연결

        .re_A(re_A_),                       // ctrl의 A read enable 출력 연결
        .addr_A(addr_A_),                   // ctrl의 A 주소 출력 연결
        .data_A(data_A),                    // A 메모리에서 들어온 data_A 연결

        .re_B(re_B_),                       // ctrl의 B read enable 출력 연결
        .addr_B(addr_B_),                   // ctrl의 B 주소 출력 연결
        .data_B(data_B),                    // B 메모리에서 들어온 data_B 연결

        .we_C(we_C_),                       // ctrl의 C write enable 출력 연결
        .addr_C(addr_C_),                   // ctrl의 C 주소 출력 연결
        .data_C(data_C_),                   // ctrl의 C 데이터 출력 연결

        .sa_en(sa_en),                      // systolic array enable 신호 연결
        .sa_prefill(sa_prefill),            // systolic array prefill 신호 연결
        .sa_busy(sa_busy),                  // systolic array busy 신호 연결

        .sa_data_A(sa_data_A),              // systolic array에 넣을 A 데이터 연결
        .sa_data_B(sa_data_B),              // systolic array에 넣을 B 데이터 연결
        .sa_data_C(sa_data_C),              // systolic array에서 나온 결과 연결

        .acc_data_P(acc_data_P),            // 누산기에 넣을 partial sum 연결
        .acc_data_C(acc_data_C),            // 누산기에 넣을 새 결과 연결
        .acc_out_C(acc_out_C)               // 누산기 결과를 ctrl로 다시 전달
    );

    sa8_4x4     U_sa        (               // 4x4 systolic array 모듈 인스턴스 생성
        .clk(clk),                          // SA에 clk 연결
        .rst(rst),                          // SA에 rst 연결
        .en(sa_en),                         // SA enable 신호 연결
        .pre_fill(sa_prefill),              // SA weight prefill 신호 연결
        .busy(sa_busy),                     // SA busy 출력 연결
        .A(sa_data_A),                      // SA에 입력할 A 데이터 연결
        .B(sa_data_B),                      // SA에 입력할 B 데이터 연결
        .C(sa_data_C)                       // SA에서 나온 C 결과 연결
    );
                                
    cla16 U_CLA16 (                         // 16비트 덧셈기 모듈 인스턴스 생성
        .A       (acc_data_P),              // 기존 partial sum 입력
        .B       (acc_data_C),              // 새로 계산된 partial result 입력
        .Cin     (1'b0),                    // carry input은 0으로 고정
        .S       (acc_out_C),               // 덧셈 결과 출력
        .Cout    (),                        // carry out은 사용하지 않음
        .G_group (),                        // group generate는 사용하지 않음
        .P_group ()                         // group propagate는 사용하지 않음
    );

endmodule                                   // top 모듈 끝
// Behavioral memory 
module mem_behavior # (
    parameter firmware = "",   // memory 초기화에 사용할 파일 이름
    parameter bitline = 16,    // memory data bit width
    parameter bitaddr = 8,     // memory address bit width
    parameter binary = 1       // 1이면 readmemb, 0이면 readmemh 사용
) (
    input                   clk,    // clock 신호
    input                   en,     // memory enable
    input                   we,     // write enable, 1이면 write
    input  [bitaddr-1:0]    addr,   // memory address
    input  [bitline-1:0]    din,    // memory에 쓸 data
    output [bitline-1:0]    dout    // memory에서 읽은 data
);

    reg                 test;       // write 확인용 debug register
    reg [bitline-1:0]   dout_;      // 실제 output data 저장 register
    reg [bitline-1:0]   memory [2**bitaddr - 1:0]; // memory array

    assign #1 dout = dout_;         // read output에 1ns delay 부여

    integer mi;                     // memory 초기화용 반복 변수

    initial begin
        // firmware 파일이 있으면 해당 파일로 memory 초기화
        if (firmware != "") begin
            if (binary)
                $readmemb(firmware, memory); // binary file 읽기
            else
                $readmemh(firmware, memory); // hex file 읽기
        end else begin
            // firmware 파일이 없으면 memory를 0으로 초기화
            for (mi = 0; mi < 2**bitaddr; mi = mi + 1) begin
                memory[mi] = {bitline{1'b0}};
            end
        end

        dout_ = {bitline{1'b0}};    // output 초기화
        test  = 1'b1;               // debug용 test 초기값
    end
 
    wire [bitline-1:0] memory_debug; // 현재 address의 memory 값 확인용
    assign memory_debug = memory[addr];
    
    always @ (posedge clk) begin
        // en=1, we=1이면 memory에 din을 write
        if (we && en)
            memory[addr] <= din;

        // en=1, we=0이면 memory에서 값을 read
        if (~we && en)
            dout_ <= memory[addr];

        // write가 제대로 되었는지 확인하기 위한 debug logic
        if (we && en)     
            test <= (memory[addr] == din);
    end

endmodule

module project (
    input               clk,          // clock 신호
    input               rst,          // reset 신호, 1이면 초기화
    input               run,          // 연산 시작 신호
    input               batch_mode,   // 0: base 8-batch, 1: extra 16-batch
    output  reg         done,         // 전체 연산 완료 신호
    output  reg [3:0]   state,        // project FSM 현재 상태

    output              re_X,         // X memory read enable
    output      [6:0]   addr_X,       // X memory address
    input       [7:0]   data_X,       // X memory에서 읽은 data

    output              re_W1,        // W1T memory read enable
    output      [5:0]   addr_W1,      // W1T memory address
    input       [7:0]   data_W1,      // W1T memory에서 읽은 data

    output              re_W2,        // W2T memory read enable
    output      [5:0]   addr_W2,      // W2T memory address
    input       [7:0]   data_W2,      // W2T memory에서 읽은 data

    output              we_Y,         // Y memory write enable
    output      [6:0]   addr_Y,       // Y memory address
    output      [15:0]  data_Y        // Y memory에 쓸 data
);

    // project FSM state 정의
    localparam S_IDLE      = 4'd0;     // 대기 상태
    localparam S_FC1_RST   = 4'd1;     // FC1용 matmul reset
    localparam S_FC1_RUN   = 4'd2;     // FC1 matmul 시작
    localparam S_FC1_WAIT  = 4'd3;     // FC1 matmul 완료 대기
    localparam S_NORM_RELU = 4'd4;     // Norm과 ReLU 수행
    localparam S_FC2_RST   = 4'd5;     // FC2용 matmul reset
    localparam S_FC2_RUN   = 4'd6;     // FC2 matmul 시작
    localparam S_FC2_WAIT  = 4'd7;     // FC2 matmul 완료 대기
    localparam S_NEXT      = 4'd8;     // extra block 처리 여부 결정
    localparam S_DONE      = 4'd9;     // 전체 연산 완료

    localparam [15:0] MATMUL_WAIT = 16'd3000; // matmul이 끝날 때까지 기다리는 cycle 수

    reg         block_idx;             // extra에서 0: 앞 8 rows, 1: 뒤 8 rows
    reg [6:0]   norm_cnt;              // Norm/ReLU 처리 index counter
    reg [15:0]  wait_cnt;              // FC1/FC2 wait counter

    reg [15:0]  X1_buf [0:127];        // FC1 결과 X1 저장 buffer

    wire [2:0]  mat_state;             // 내부 matmul engine state

    wire        mat_re_A;              // matmul A memory read enable
    wire [5:0]  mat_addr_A;            // matmul A memory address
    wire [7:0]  mat_data_A;            // matmul A input data

    wire        mat_re_B;              // matmul B memory read enable
    wire [5:0]  mat_addr_B;            // matmul B memory address
    wire [7:0]  mat_data_B;            // matmul B input data

    wire        mat_we_C;              // matmul C output write enable
    wire [5:0]  mat_addr_C;            // matmul C output address
    wire [15:0] mat_data_C;            // matmul C output data

    wire        mat_rst;               // matmul engine reset
    wire        mat_run;               // matmul engine run

    wire        fc1_phase;             // 현재 FC1 수행 중인지 표시
    wire        fc2_phase;             // 현재 FC2 수행 중인지 표시

    wire [6:0]  mat_global_addr_A;     // block_idx 포함한 A global address
    wire [6:0]  mat_global_addr_C;     // block_idx 포함한 C global address
    wire [6:0]  norm_index;            // Norm/ReLU에서 사용할 X1/X3 address

    wire signed [15:0] norm_src;       // X1_buf에서 읽은 16-bit X1 값
    wire signed [15:0] norm_shift16;   // X1을 32로 나눈 결과
    wire [7:0]  norm_x2;               // Norm 결과 8-bit X2
    wire [7:0]  norm_relu;             // ReLU 결과 8-bit X3

    wire        x3_we;                 // X3 memory write enable
    wire        x3_en;                 // X3 memory enable
    wire [6:0]  x3_addr;               // X3 memory address
    wire [7:0]  x3_din;                // X3 memory write data
    wire [7:0]  x3_dout;               // X3 memory read data

    integer i;                         // reset 시 buffer 초기화용 반복 변수

    // FC1 관련 state이면 fc1_phase = 1
    assign fc1_phase = (state == S_FC1_RST)  ||
                       (state == S_FC1_RUN)  ||
                       (state == S_FC1_WAIT);

    // FC2 관련 state이면 fc2_phase = 1
    assign fc2_phase = (state == S_FC2_RST)  ||
                       (state == S_FC2_RUN)  ||
                       (state == S_FC2_WAIT);

    // 전체 reset이거나 FC1/FC2 시작 전이면 matmul engine reset
    assign mat_rst = rst ||
                     (state == S_FC1_RST) ||
                     (state == S_FC2_RST);

    // FC1_RUN 또는 FC2_RUN에서 matmul engine 실행
    assign mat_run = (state == S_FC1_RUN) ||
                     (state == S_FC2_RUN);

    // matmul의 6-bit address 앞에 block_idx를 붙여 7-bit address 생성
    assign mat_global_addr_A = {block_idx, mat_addr_A};
    assign mat_global_addr_C = {block_idx, mat_addr_C};

    // FC1일 때만 X memory를 읽음
    assign re_X   = (fc1_phase) ? mat_re_A : 1'b0;

    // X address는 block_idx가 포함된 global address 사용
    assign addr_X = mat_global_addr_A;

    // FC1일 때만 W1T memory를 읽음
    assign re_W1   = (fc1_phase) ? mat_re_B : 1'b0;

    // W1T는 항상 8x8 weight라서 6-bit address 사용
    assign addr_W1 = mat_addr_B;

    // FC2일 때만 W2T memory를 읽음
    assign re_W2   = (fc2_phase) ? mat_re_B : 1'b0;

    // W2T도 항상 8x8 weight라서 6-bit address 사용
    assign addr_W2 = mat_addr_B;

    // FC1이면 A 입력은 X, FC2이면 A 입력은 X3
    assign mat_data_A = (fc1_phase) ? data_X : x3_dout;

    // FC1이면 B 입력은 W1T, FC2이면 B 입력은 W2T
    assign mat_data_B = (fc1_phase) ? data_W1 : data_W2;

    // FC2 결과만 최종 Y memory에 write
    assign we_Y   = (fc2_phase) ? mat_we_C : 1'b0;

    // Y address는 block_idx가 포함된 global address 사용
    assign addr_Y = mat_global_addr_C;

    // Y data는 matmul output C 사용
    assign data_Y = mat_data_C;

    // Norm/ReLU에서 사용할 index 생성
    assign norm_index   = {block_idx, norm_cnt[5:0]};

    // X1_buf에서 FC1 결과 읽기
    assign norm_src     = X1_buf[norm_index];

    // X1 / 32 수행, arithmetic right shift
    assign norm_shift16 = norm_src >>> 5;

    // 16-bit 결과에서 하위 8-bit를 X2로 사용
    assign norm_x2      = norm_shift16[7:0];

    // ReLU 수행, 음수이면 0 아니면 그대로
    assign norm_relu    = (norm_x2[7]) ? 8'd0 : norm_x2;

    // Norm/ReLU state에서 X3 memory에 write
    assign x3_we   = (state == S_NORM_RELU);

    // X3 memory는 write할 때 또는 FC2에서 읽을 때 enable
    assign x3_en   = x3_we | (fc2_phase & mat_re_A);

    // write 때는 norm_index, read 때는 mat_global_addr_A 사용
    assign x3_addr = x3_we ? norm_index : mat_global_addr_A;

    // X3 memory에 쓸 data는 ReLU 결과
    assign x3_din  = norm_relu;

    // ReLU 결과 X3를 저장하는 내부 memory
    mem_behavior #(
        .firmware (""),                 // 초기화 파일 없음
        .bitline  (8),                  // X3는 8-bit
        .bitaddr  (7),                  // 128개 address
        .binary   (0)                   // hex 형식
    ) U_mem_X3 (
        .clk  (clk),                    // clock 연결
        .en   (x3_en),                  // memory enable
        .we   (x3_we),                  // write enable
        .addr (x3_addr),                // X3 memory address
        .din  (x3_din),                 // write data
        .dout (x3_dout)                 // read data
    );

    // FC1과 FC2에 재사용되는 8x8 matrix multiplication engine
    top U_matmul (
        .clk    (clk),                  // clock 연결
        .rst    (mat_rst),              // matmul reset
        .run    (mat_run),              // matmul run
        .state  (mat_state),            // matmul 내부 state

        .re_A   (mat_re_A),             // A memory read enable
        .addr_A (mat_addr_A),           // A memory address
        .data_A (mat_data_A),           // A input data

        .re_B   (mat_re_B),             // B memory read enable
        .addr_B (mat_addr_B),           // B memory address
        .data_B (mat_data_B),           // B input data

        .we_C   (mat_we_C),             // C output write enable
        .addr_C (mat_addr_C),           // C output address
        .data_C (mat_data_C)            // C output data
    );

    // project 전체 FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin                  // reset이면 모든 값 초기화
            state     <= S_IDLE;        // IDLE 상태로 이동
            done      <= 1'b0;          // done 내림
            block_idx <= 1'b0;          // 첫 번째 block부터 시작
            norm_cnt  <= 7'd0;          // Norm counter 초기화
            wait_cnt  <= 16'd0;         // wait counter 초기화

            // X1_buf 전체 초기화
            for (i = 0; i < 128; i = i + 1) begin
                X1_buf[i] <= 16'd0;
            end

        end else begin                  // reset이 아니면 FSM 동작

            // FC1 결과가 valid하면 X1_buf에 저장
            if (fc1_phase && mat_we_C) begin
                X1_buf[mat_global_addr_C] <= mat_data_C;
            end

            case (state)

                S_IDLE: begin           // run을 기다리는 상태
                    done      <= 1'b0;  // done 내림
                    block_idx <= 1'b0;  // 첫 block으로 설정
                    norm_cnt  <= 7'd0;  // Norm counter 초기화
                    wait_cnt  <= 16'd0; // wait counter 초기화

                    if (run) begin      // run이 들어오면 FC1 시작
                        state <= S_FC1_RST;
                    end
                end

                S_FC1_RST: begin        // FC1 전에 matmul reset
                    done     <= 1'b0;   // done 내림
                    norm_cnt <= 7'd0;   // Norm counter 초기화
                    wait_cnt <= 16'd0;  // wait counter 초기화
                    state    <= S_FC1_RUN; // 다음 state로 이동
                end

                S_FC1_RUN: begin        // FC1 matmul 시작
                    wait_cnt <= 16'd0;  // wait counter 초기화
                    state    <= S_FC1_WAIT; // FC1 완료 대기
                end

                S_FC1_WAIT: begin       // FC1이 끝날 때까지 기다림
                    if (wait_cnt < MATMUL_WAIT) begin
                        wait_cnt <= wait_cnt + 16'd1; // wait counter 증가
                    end else begin
                        wait_cnt <= 16'd0; // wait counter 초기화
                        norm_cnt <= 7'd0;  // Norm counter 초기화
                        state    <= S_NORM_RELU; // Norm/ReLU 수행
                    end
                end

                S_NORM_RELU: begin      // X1에 Norm과 ReLU 적용
                    if (norm_cnt == 7'd63) begin
                        norm_cnt <= 7'd0; // 64개 처리 완료
                        state    <= S_FC2_RST; // FC2 준비
                    end else begin
                        norm_cnt <= norm_cnt + 7'd1; // 다음 element 처리
                    end
                end

                S_FC2_RST: begin        // FC2 전에 matmul reset
                    wait_cnt <= 16'd0;  // wait counter 초기화
                    state    <= S_FC2_RUN; // FC2 시작
                end

                S_FC2_RUN: begin        // FC2 matmul 시작
                    wait_cnt <= 16'd0;  // wait counter 초기화
                    state    <= S_FC2_WAIT; // FC2 완료 대기
                end

                S_FC2_WAIT: begin       // FC2가 끝날 때까지 기다림
                    if (wait_cnt < MATMUL_WAIT) begin
                        wait_cnt <= wait_cnt + 16'd1; // wait counter 증가
                    end else begin
                        wait_cnt <= 16'd0; // wait counter 초기화
                        state    <= S_NEXT; // 다음 block 확인
                    end
                end

                S_NEXT: begin           // extra block을 더 처리할지 결정
                    if (batch_mode && block_idx == 1'b0) begin
                        block_idx <= 1'b1; // extra의 두 번째 block 선택
                        state     <= S_FC1_RST; // 다음 block FC1 시작
                    end else begin
                        state <= S_DONE; // 모든 block 완료
                    end
                end

                S_DONE: begin           // 전체 연산 완료 상태
                    done <= 1'b1;       // done 올림

                    if (run) begin      // run이 다시 들어오면 재시작
                        done      <= 1'b0;  // done 내림
                        block_idx <= 1'b0;  // 첫 block부터 다시 시작
                        norm_cnt  <= 7'd0;  // Norm counter 초기화
                        wait_cnt  <= 16'd0; // wait counter 초기화
                        state     <= S_FC1_RST; // FC1부터 다시 시작
                    end
                end

                default: begin          // 예외 상태 처리
                    state <= S_IDLE;    // IDLE로 복귀
                end

            endcase
        end
    end

endmodule
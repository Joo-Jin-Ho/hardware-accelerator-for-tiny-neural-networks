# Hardware Accelerator for Tiny Neural Networks
Hardware accelerator design for efficient inference on tiny neural networks.

구체적인 개발과정과 Waveform 등은 report.pdf로 첨부하였습니다.

Tiny Neural Network 하드웨어 가속기 설계 (Verilog) Tiny Neural Network(TNN)의 주요 연산을 Verilog HDL을 사용하여 하드웨어로 구현하고, 최종적으로 추론(Inference) 과정을 가속하는 시스템을 설계하는 것을 목표로 합니다.

설계는 기본적인 연산 유닛부터 시작하여 점차 복잡한 모듈을 통합하는 Bottom-up 방식으로 진행되었습니다.

# 🚀 프로젝트 개요
최종적으로 구현된 TNN 가속기는 아래와 같은 구조를 가집니다. 외부 메모리에 저장된 입력 데이터(X)와 가중치(W1, W2)를 읽어와 두 개의 완전 연결 계층(Fully Connected Layer), 정규화(Normalization), ReLU 활성화 함수 연산을 순차적으로 수행하고, 최종 결과를 다시 메모리에 저장합니다.
<img width="1224" height="226" alt="image" src="https://github.com/user-attachments/assets/695bbcd9-be7a-491d-b5b1-f2a71919e9db" />

# 특징

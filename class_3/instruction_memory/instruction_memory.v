`timescale 1ns / 1ps

module instruction_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 256  // 模拟 256 个字的内存空间
)(
    input  wire [31:0] addr, // PC 输入地址 (例如 0, 4, 8...)
    output wire [31:0] rd    // Read Data (读出的指令)
);

    // 1. 定义存储器数组
    reg [WIDTH-1:0] ram [0:DEPTH-1];

    // 2. 初始化：加载机器码文件
    initial begin
        // "memfile.dat" 必须在同一个文件夹下
        // $readmemh 读取十六进制数据
        $readmemh("memfile.dat", ram);
    end

    // 3. 读取逻辑 (组合逻辑，地址变数据立刻变)
    // MIPS 是字对齐的，输入地址 4 对应数组索引 1
    assign rd = ram[addr[31:2]];

endmodule
module rsp (Q, Y);
input [2:0] Q;
output [2:0] Y;
reg [2:0] Y;
always @(Q)
case (Q)
3'b111: Y = 3'b001;
3'b110: Y = 3'b010;
3'b101: Y = 3'b100;
3'b100: Y = 3'b100;
3'b011: Y = 3'b010;
3'b010: Y = 3'b010;
3'b001: Y = 3'b001;
3'b000: Y = 3'b001;
endcase
endmodule

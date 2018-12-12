module score2Hex(scoreClk,Score, ones, tens);
input scoreClk;
input [6:0] Score;
output reg [3:0]ones;
output reg [3:0]tens;

always @ (posedge scoreClk)
begin
	ones<=Score%10;
	tens<=Score/10;
end
endmodule
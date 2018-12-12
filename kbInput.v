//This module came from Lucy and Michaela
////////////////////////////////////////////////////////////////// key inputs to control Pacman
module kbInput(KB_clk, key, direction, reset);
input KB_clk;
input [3:0]key;
output reg [2:0]direction;
output reg reset = 0; 

always @(KB_clk)
begin
	if(key[1] == 1'b1 & key[0] == 1'b0)
		direction = 3'd1;//right
	else if(key[0] == 1'b1 & key[1] == 1'b0)
		direction = 3'd2;//left
	else if(key[3] == 1'b1 & key[2] == 1'b0)
		direction = 3'd3;//up
	else if (key[2] == 1'b1 & key[3] == 1'b0)
		direction = 3'd4;//down
	else
		direction = 3'd0;//stationary
end
endmodule
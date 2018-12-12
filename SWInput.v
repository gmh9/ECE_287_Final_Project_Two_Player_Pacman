//Based off module kbInput
/////////////////////////////////////////////////////////////// switch inputs to control Ghost
module SWInput(SW_clk, switch, GhostDirection, reset);
input SW_clk;
input [3:0]switch;
output reg [2:0]GhostDirection;
output reg reset = 0;

always @ (SW_clk)
begin
	if(switch[1] ==1'b1)
		GhostDirection = 3'd1;//right
	else if(switch[0] == 1'b1)
		GhostDirection = 3'd2; //left
	else if(switch[3] == 1'b1)
		GhostDirection = 3'd3;//up
	else if (switch[2] == 1'b1)
		GhostDirection = 3'd4;//down
	else
		GhostDirection = 3'd0;//stationary
end
endmodule

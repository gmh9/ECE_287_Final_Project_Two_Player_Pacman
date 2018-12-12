/////////////////////////////////////////////////////////////////// update clk to lower snake speed
module updateCLK(clk, update);
input clk;
output reg [14:0]update;
reg[21:0]count;

always @(posedge clk)
begin
	count <= count + 1;
	if(count == 2500000)
	begin
		update <= ~update;
		count <= 0;
	end
end
endmodule

module HEX(clk, in, out);
	input clk;
	input [3:0]in;
	output reg [6:0]out;
	always @ (posedge clk)
	begin
	out[0] <= ~(~in[2] & ~in[0]|~in[3] & in[1]|in[2] & in[1]|in[3] & ~in[0]|~in[3] & in[2] & in[0]|in[3] & ~in[2] & ~in[1]);
	out[1] <= ~(~in[2] & ~in[0]|~in[3] & ~in[2]|~in[3] & ~in[1] & ~in[0]|~in[3] & in[1] & in[0]|in[3] & ~in[1] & in[0]);
	out[2] <= ~(~in[3] & in[2]|~in[1] & in[0]|in[3] & ~in[2]|~in[3] & ~in[2] & ~in[1]|~in[3] & ~in[2] & in[0]);
	out[3] <= ~(~in[3] & ~in[2] & in[1]|in[2] & ~in[1] & in[0]|in[3] & ~in[1] & ~in[0]|~in[2] & in[1] & in[0]|~in[2] & ~in[1] & ~in[0]|in[2] & in[1] & ~in[0]);
	out[4] <= ~(in[3] & in[2]|in[1] & ~in[0]|~in[2] & ~in[0]|in[3] & in[1] & in[0]);
	out[5] <= ~(~in[1] & ~in[0] | in[3] & ~in[2] | in[3] & in[1] | ~in[3] & in[2] & ~in[1] | in[2] & in[1] & ~in[0]);
	out[6] <= ~(in[3] & ~in[2] | in[1] & ~in[0] | in[3] & in[0] | ~in[3] & in[2] & ~in[1] | ~in[3] & ~in[2] & in[1]);
	end
endmodule

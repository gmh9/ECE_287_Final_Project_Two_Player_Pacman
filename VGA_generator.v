/////////////////////////////////////////////////////////////////// VGA_generator to display using VGA
module VGA_generator(VGA_clk, VGA_Hsync, VGA_Vsync, DisplayArea, xPixel, yPixel, blank_n);
input VGA_clk;
output VGA_Hsync, VGA_Vsync, blank_n;
output reg DisplayArea;
output reg [9:0] xPixel;
output reg [9:0] yPixel;

reg HSync;
reg VSync;

integer HFront = 640;//640
integer hSync = 655;//655
integer HBack = 747;//747
integer maxH = 793;//793

integer VFront = 480;//480
integer vSync = 490;//490
integer VBack = 492;//492
integer maxV = 525;//525

always @(posedge VGA_clk)
begin		
	if(xPixel == maxH)
	begin
		xPixel <= 0;
		if(yPixel === maxV)
			yPixel <= 0;
		else
			yPixel <= yPixel +1;
	end
	else
	begin
		xPixel <= xPixel + 1;
	end
	DisplayArea <= ((xPixel < HFront) && (yPixel < VFront));
	HSync <= ((xPixel >= hSync) && (xPixel < HBack));
	VSync <= ((yPixel >= vSync) && (yPixel < VBack));
end

assign VGA_Vsync = ~VSync;
assign VGA_Hsync = ~HSync;
assign blank_n = DisplayArea;

endmodule
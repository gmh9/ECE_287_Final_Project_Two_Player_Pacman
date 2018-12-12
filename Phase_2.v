module Phase_2(clk, rst, WaitScreenButton, StartGameButton, key, switch, DAC_clk, VGA_R, VGA_G, VGA_B, VGA_Hsync, 
					VGA_Vsync, blank_n, KB_clk, data, HEX1, HEX2, HEX3, HEX4);
					
input clk, rst, WaitScreenButton, StartGameButton;
input KB_clk, data;
input [3:0]key;
input [3:0]switch;
reg [6:0]pacmanScore;
reg [6:0]GhostScore;
reg [43:0]blockEn;
reg [2:0]fruitEn;
reg [43:0]block;
reg [8:0]t;
reg GameOver;

wire [2:0]direction;
wire [2:0]GhostDirection;
wire [43:0]collision;
wire [2:0]fruitCollisionPacman;
wire [2:0]fruitCollisionGhost;
wire PlayerCollision;
wire reset;

output reg [7:0]VGA_R;
output reg [7:0]VGA_G;
output reg [7:0]VGA_B;

output VGA_Hsync;
output VGA_Vsync;
output DAC_clk;
output blank_n;

wire [9:0]xPixel;
wire [9:0]yPixel;

wire R;
wire G;
wire B;

wire update;
wire VGA_clk;
wire displayArea;

wire pacman;
wire ghost;
reg border;
reg game_over;
reg win_game;
reg [10:0]x,y; //the top left point of the pacman
reg [10:0]x_ghost,y_ghost; //the top left of the ghost

wire [3:0]ones;
wire [3:0]tens;
wire [3:0]onesG;
wire [3:0]tensG;
output [6:0]HEX1;
output [6:0]HEX2;
output [6:0]HEX3;
output [6:0]HEX4;

//import modules
kbInput keyboard(KB_clk, key, direction, reset); //the "keyboard", aka the buttons
SWInput switches(KB_clk, switch, GhostDirection, reset); //the switches to control Ghost
updateCLK clk_updateCLK(clk, update);
clk_reduce reduce(clk, VGA_clk);
VGA_generator generator(VGA_clk, VGA_Hsync, VGA_Vsync, DisplayArea, xPixel, yPixel, blank_n);
collisions collide(KB_clk,x,y,x_ghost,y_ghost, reset, blockEn, fruitEn, collision, fruitCollisionPacman, fruitCollisionGhost, PlayerCollision);
score2Hex(clk,pacmanScore, ones, tens);
score2Hex(clk,GhostScore, onesG, tensG);
HEX(clk,ones,HEX1);
HEX(clk,tens,HEX2);
HEX(clk,onesG,HEX3);
HEX(clk,tensG,HEX4);


assign DAC_clk = VGA_clk; //DON'T DELETE. this allows the clock on the board to sync with the vga (allowing things to shop up on the monitor)

assign pacman = (xPixel >= x && xPixel <= x+50 && yPixel >= y && yPixel <= y +50); // sets the size of pacman
assign ghost   = (xPixel >= x_ghost && xPixel <= x_ghost+50 && yPixel >= y_ghost && yPixel <= y_ghost + 50); // sets the size of the ghost

parameter StartScreen = 4'd0,
			 Maze1Wait= 4'd1,
			 Maze1=4'd2,
			 Maze1Winner=4'd3,
			 Maze2Wait=4'd4,
			 Maze2=4'd5,
			 Maze2Winner=4'd6;
			 
reg [3:0]S;
reg [3:0]NS;

			 
always @ (posedge clk or negedge rst)
begin
	if(rst==1'b0)
		S<=StartScreen;
	else
		S<=NS;
end


always @ (*)
begin
	case(S)
		StartScreen:begin
			if(WaitScreenButton==1'b0)
				NS=Maze1Wait;
			else
				NS=StartScreen;
			VGA_R=8'd0;
			VGA_G=8'd0;
			VGA_B=8'd0;
			if (xPixel>=0 && xPixel<=640 && yPixel>=0 && yPixel<=35)//TopBar
		begin
			VGA_R = 8'b00000000;
			VGA_G = 8'b00000000;
			VGA_B = 8'b11111111;
		end
		if(xPixel>0 && xPixel<640 && yPixel>445 && yPixel<480)//BottomBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>0 && xPixel<35 && yPixel>0 && yPixel<480)//LeftBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>605 && xPixel<640 && yPixel>0 && yPixel<480)//RightBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			
			///////////////////////////////////////////////////////////////Maze 1
					//Drawing Solid shape "Top Box"
			if(xPixel>105 && xPixel<535 && yPixel>105 && yPixel<205)
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			
			
			//Drawing Solid shape "Bottom Box"
			if(xPixel>105 && xPixel<535 && yPixel>275 && yPixel<375)
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			if((xPixel>215 && xPixel<225 && yPixel>215 && yPixel<225)||(xPixel>185 && xPixel<215 && yPixel>205 && yPixel<215)
			||(xPixel>175 && xPixel<185 && yPixel>215 && yPixel<235)||(xPixel>185 && xPixel<215 && yPixel>235 && yPixel<245)
			||(xPixel>215 && xPixel<225 && yPixel>245 && yPixel<265)||(xPixel>185 && xPixel<215 && yPixel>265 && yPixel<275)
			||(xPixel>175 && xPixel<185 && yPixel>255 && yPixel<265))
			begin //S
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b11111111;
			end
			if((xPixel>235 && xPixel<285 && yPixel>205 && yPixel<215)||(xPixel>255 && xPixel<265 && yPixel>205 && yPixel<275))
			begin //T
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b11111111;
			end
			if((xPixel>295 && xPixel<305 && yPixel>225 && yPixel<275)||(xPixel>295 && xPixel<345 && yPixel>245 && yPixel<255)
			||(xPixel>305 && xPixel<315 && yPixel>215 && yPixel<225)||(xPixel>315 && xPixel<325 && yPixel>205 && yPixel<215)
			||(xPixel>325 && xPixel<335 && yPixel>215 && yPixel<225)||(xPixel>335 && xPixel<345 && yPixel>225 && yPixel<275))
			begin //A
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b11111111;
			end
			if((xPixel>355 && xPixel<395 && yPixel>205 && yPixel<215)||(xPixel>355 && xPixel<365 && yPixel>205 && yPixel<275)
			||(xPixel>395 && xPixel<405 && yPixel>215 && yPixel<235)||(xPixel>355 && xPixel<395 && yPixel>235 && yPixel<245)
			||(xPixel>375 && xPixel<385 && yPixel>245 && yPixel<255)||(xPixel>385 && xPixel<395 && yPixel>255 && yPixel<265)
			||(xPixel>395 && xPixel<405 && yPixel>265 && yPixel<275))
			begin //R
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b11111111;
			end
			if((xPixel>415 && xPixel<465 && yPixel>205 && yPixel<215)||(xPixel>435 && xPixel<445 && yPixel>205 && yPixel<275))
			begin //T
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b11111111;
			end	

			end
		Maze1Wait:begin
			if(StartGameButton==1'b0)
				NS=Maze1;
			else
				NS=Maze1Wait;
		VGA_R = 8'd0;
		VGA_G = 8'd0; 
		VGA_B = 8'd0;
		if(blockEn[0]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[1]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[2]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[3]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[4]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[5]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[6]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[7]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[8]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[9]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end	
		if(blockEn[10]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[11]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[12]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[13]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[14]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[15]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[16]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[17]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[18]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[19]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[20]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[21]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[22]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[23]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[24]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[25]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[26]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[27]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[28]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[29]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[30]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[31]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[32]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[33]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[34]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[35]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[36]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[37]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[38]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[39]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[40]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[41]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[42]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[43]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
			
		if(xPixel >= x && xPixel <= x+50 && yPixel >= y && yPixel <= y +50)//pacman
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b00000000;
			end
		if(xPixel >= x_ghost && xPixel <= x_ghost+50 && yPixel >= y_ghost && yPixel <= y_ghost + 50)//ghost
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if (xPixel>=0 && xPixel<=640 && yPixel>=0 && yPixel<=35)//TopBar
		begin
			VGA_R = 8'b00000000;
			VGA_G = 8'b00000000;
			VGA_B = 8'b11111111;
		end
		if(xPixel>0 && xPixel<640 && yPixel>445 && yPixel<480)//BottomBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>0 && xPixel<35 && yPixel>0 && yPixel<480)//LeftBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>605 && xPixel<640 && yPixel>0 && yPixel<480)//RightBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			
			///////////////////////////////////////////////////////////////Maze 1
					//Drawing Solid shape "Top Box"
			if(xPixel>105 && xPixel<535 && yPixel>105 && yPixel<205)
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			
			
			//Drawing Solid shape "Bottom Box"
			if(xPixel>105 && xPixel<535 && yPixel>275 && yPixel<375)
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			end
			
		Maze1:
		begin
		if(blockEn==40'd0 || GameOver==1'b1)
			NS=Maze1Winner;
		else if(WaitScreenButton==1'b0)
			NS=Maze1Wait;
		else
			NS=Maze1;
		VGA_R = 8'd0;
		VGA_G = 8'd0; 
		VGA_B = 8'd0;
		
		if(fruitEn[0]==1'b1 && xPixel>280 && xPixel<300 && yPixel>230 && yPixel<250)
		begin
			VGA_R=8'b11111111;
			VGA_G=8'd0;
			VGA_B=8'd0;
		end
		
		if(blockEn[0]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[1]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[2]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[3]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[4]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[5]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[6]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[7]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[8]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[9]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end	
		if(blockEn[10]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[11]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[12]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[13]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[14]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[15]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[16]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[17]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[18]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[19]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[20]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[21]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[22]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[23]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[24]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[25]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[26]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[27]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[28]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[29]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[30]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[31]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[32]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[33]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[34]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[35]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[36]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[37]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[38]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[39]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
			
		if(xPixel >= x && xPixel <= x+50 && yPixel >= y && yPixel <= y +50)//pacman
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b00000000;
			end
		if(xPixel >= x_ghost && xPixel <= x_ghost+50 && yPixel >= y_ghost && yPixel <= y_ghost + 50)//ghost
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if (xPixel>=0 && xPixel<=640 && yPixel>=0 && yPixel<=35)//TopBar
		begin
			VGA_R = 8'b00000000;
			VGA_G = 8'b00000000;
			VGA_B = 8'b11111111;
		end
		if(xPixel>0 && xPixel<640 && yPixel>445 && yPixel<480)//BottomBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>0 && xPixel<35 && yPixel>0 && yPixel<480)//LeftBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>605 && xPixel<640 && yPixel>0 && yPixel<480)//RightBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			
			///////////////////////////////////////////////////////////////Maze 1
					//Drawing Solid shape "Top Box"
			if(xPixel>105 && xPixel<535 && yPixel>105 && yPixel<205)
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
			
			
			//Drawing Solid shape "Bottom Box"
			if(xPixel>105 && xPixel<535 && yPixel>275 && yPixel<375)
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		end
		Maze1Winner:begin
			if(WaitScreenButton==1'b0)
				NS=Maze2;
			else
				NS=Maze1Winner;
			VGA_R=8'b00000000;
			VGA_G=8'b00000000;
			VGA_B=8'b00000000;
			if(pacmanScore>GhostScore)
			begin
			if(xPixel>50 && xPixel<150 && yPixel>190 && yPixel<290)
			begin//square
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'd0;
				end
			if((xPixel>170 && xPixel<190 && yPixel>170 && yPixel<290)||(xPixel>190 && xPixel<210&& yPixel>290 && yPixel<310)
			||(xPixel>210 && xPixel<230 && yPixel>230 && yPixel<290)||(xPixel>230 && xPixel<250 && yPixel>290 && yPixel<310)
			||(xPixel>250 && xPixel<270 && yPixel>170 && yPixel<290))
			begin//W
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if(xPixel>290 && xPixel<310 && yPixel>170 && yPixel<310)
			begin//I
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>330 && xPixel<350 && yPixel>170 && yPixel<310)||(xPixel>350 && xPixel<370 && yPixel>210 && yPixel<230)
			||(xPixel>370 && xPixel<390 && yPixel>230 && yPixel<250)||(xPixel>390 && xPixel<410 && yPixel>250 && yPixel<270)
			||(xPixel>410 && xPixel<430 && yPixel>170 && yPixel<310))
			begin//N
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>530 && xPixel<550 && yPixel>190 && yPixel<210)||(xPixel>470 && xPixel<530 && yPixel>170 && yPixel<190)
			||(xPixel>450 && xPixel<470 && yPixel>190 && yPixel<230)||(xPixel>470 && xPixel<530 && yPixel>230 && yPixel<250)
			||(xPixel>530 && xPixel<550 && yPixel>250 && yPixel<290)||(xPixel>470 && xPixel<530 && yPixel>290 && yPixel<310)
			||(xPixel>450 && xPixel<460 && yPixel>270 && yPixel<290))
			begin//S
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end			
			if((xPixel>570 && xPixel<590 && yPixel>170 && yPixel<270)||(xPixel>570 && xPixel<590 && yPixel>290 && yPixel<310))
			begin//!
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
		end
		else if(pacmanScore<GhostScore)
			begin
			if(xPixel>50 && xPixel<150 && yPixel>190 && yPixel<290)
			begin//square
				VGA_R=8'b11111111;
				VGA_G=8'b00000000;
				VGA_B=8'b11111111;
				end
			if((xPixel>170 && xPixel<190 && yPixel>170 && yPixel<290)||(xPixel>190 && xPixel<210&& yPixel>290 && yPixel<310)
			||(xPixel>210 && xPixel<230 && yPixel>230 && yPixel<290)||(xPixel>230 && xPixel<250 && yPixel>290 && yPixel<310)
			||(xPixel>250 && xPixel<270 && yPixel>170 && yPixel<290))
			begin//W
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if(xPixel>290 && xPixel<310 && yPixel>170 && yPixel<310)
			begin//I
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>330 && xPixel<350 && yPixel>170 && yPixel<310)||(xPixel>350 && xPixel<370 && yPixel>210 && yPixel<230)
			||(xPixel>370 && xPixel<390 && yPixel>230 && yPixel<250)||(xPixel>390 && xPixel<410 && yPixel>250 && yPixel<270)
			||(xPixel>410 && xPixel<430 && yPixel>170 && yPixel<310))
			begin//N
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>530 && xPixel<550 && yPixel>190 && yPixel<210)||(xPixel>470 && xPixel<530 && yPixel>170 && yPixel<190)
			||(xPixel>450 && xPixel<470 && yPixel>190 && yPixel<230)||(xPixel>470 && xPixel<530 && yPixel>230 && yPixel<250)
			||(xPixel>530 && xPixel<550 && yPixel>250 && yPixel<290)||(xPixel>470 && xPixel<530 && yPixel>290 && yPixel<310)
			||(xPixel>450 && xPixel<460 && yPixel>270 && yPixel<290))
			begin//S
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end			
			if((xPixel>570 && xPixel<590 && yPixel>170 && yPixel<270)||(xPixel>570 && xPixel<590 && yPixel>290 && yPixel<310))
			begin//!
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
		end
		else
			begin
				if((xPixel>170 && xPixel<270 && yPixel>170 && yPixel<190) || (xPixel>210 && xPixel<230 && yPixel>170 && yPixel<310))
				begin//T
					VGA_R=8'b11111111;
					VGA_G=8'b11111111;
					VGA_B=8'b11111111;
				end				
				if(xPixel>290 && xPixel<310 && yPixel>170 && yPixel<310)
				begin//I
					VGA_R=8'b11111111;
					VGA_G=8'b11111111;
					VGA_B=8'b11111111;
				end
				if((xPixel>330 && xPixel<350 && yPixel>170 && yPixel<310) || (xPixel>330 && xPixel<430 && yPixel>170 && yPixel<190)
				||(xPixel>330 && xPixel<410 && yPixel>230 && yPixel<250) || (xPixel>330 && xPixel<430 && yPixel>290 && yPixel<310))
				begin//E
					VGA_R=8'b11111111;
					VGA_G=8'b11111111;
					VGA_B=8'b11111111;
				end
			end
		end
		Maze2Wait:begin
			if(StartGameButton==1'b0)
				NS=Maze2;
			else
				NS=Maze2Wait;
				
		VGA_R = 8'd0;
		VGA_G = 8'd0; 
		VGA_B = 8'd0;
		
		if(blockEn[0]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[1]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[2]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[3]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[4]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[5]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[6]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[7]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[8]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[9]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end	
		if(blockEn[10]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[11]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[12]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[13]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[14]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[15]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[16]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[17]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[18]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[19]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[20]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[21]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[22]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[23]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[24]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[25]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[26]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[27]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[28]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[29]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[30]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[31]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[32]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[33]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[34]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[35]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[36]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[37]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[38]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[39]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[40]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[41]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[42]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[43]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
			
		if(xPixel >= x && xPixel <= x+50 && yPixel >= y && yPixel <= y +50)//pacman
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b00000000;
			end
		if(xPixel >= x_ghost && xPixel <= x_ghost+50 && yPixel >= y_ghost && yPixel <= y_ghost + 50)//ghost
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if (xPixel>=0 && xPixel<=640 && yPixel>=0 && yPixel<=35)//TopBar
		begin
			VGA_R = 8'b00000000;
			VGA_G = 8'b00000000;
			VGA_B = 8'b11111111;
		end
		if(xPixel>0 && xPixel<640 && yPixel>445 && yPixel<480)//BottomBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>0 && xPixel<35 && yPixel>0 && yPixel<480)//LeftBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>605 && xPixel<640 && yPixel>0 && yPixel<480)//RightBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
	////////////////////////////////////////////////////////////////Maze 2
		//Drawing Solid shape "Upper Left Box"
	if(xPixel>105 && xPixel<285 && yPixel>105 && yPixel<205)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end
	
		//Drawing Solid shape "Upper Right Box"
	if(xPixel>355 && xPixel<535 && yPixel>105 && yPixel<205)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end
	
		//Drawing Solid shape "Lower Left Box"
	if(xPixel>105 && xPixel<285 && yPixel>275 && yPixel<375)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end
	
		//Drawing Solid shape "Lower Right Box"
	if(xPixel>355 && xPixel<535 && yPixel>275 && yPixel<375)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end			
	end
		Maze2:
		begin
		if(blockEn==40'd0 || GameOver==1'b1)
			NS=Maze2Winner;
		else if(WaitScreenButton==1'b0)
			NS=Maze2Wait;
		else
			NS=Maze2;
			
		VGA_R = 8'd0;
		VGA_G = 8'd0; 
		VGA_B = 8'd0;
		
		if(fruitEn[0]==1'b1 && xPixel>280 && xPixel<300 && yPixel>230 && yPixel<250)
		begin
			VGA_R=8'b11111111;
			VGA_G=8'd0;
			VGA_B=8'd0;
		end
		if(fruitEn[1]==1'b1 && xPixel>60 && xPixel<80 && yPixel>60 && yPixel<80)
		begin
			VGA_R=8'b11111111;
			VGA_G=8'd0;
			VGA_B=8'd0;
		end
		if(fruitEn[2]==1'b1 && xPixel>280 && xPixel<300 && yPixel>400 && yPixel<420)
		begin
			VGA_R=8'b11111111;
			VGA_G=8'd0;
			VGA_B=8'd0;
		end
		
		if(blockEn[0]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[1]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[2]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[3]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[4]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[5]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[6]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[7]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[8]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[9]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end	
		if(blockEn[10]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[11]==1'b1 && xPixel>=560 && xPixel<=580 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[12]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[13]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[14]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[15]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[16]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[17]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[18]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[19]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[20]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[21]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=400 && yPixel<=420)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[22]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[23]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[24]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[25]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[26]==1'b1 && xPixel>=60 && xPixel<=80 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[27]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[28]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[29]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[30]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=60 && yPixel<=80)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[31]==1'b1 && xPixel>=100 && xPixel<=120 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[32]==1'b1 && xPixel>=150 && xPixel<=170 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[33]==1'b1 && xPixel>=200 && xPixel<=220 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[34]==1'b1 && xPixel>=250 && xPixel<=270 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[35]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[36]==1'b1 && xPixel>=350 && xPixel<=370 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[37]==1'b1 && xPixel>=400 && xPixel<=420 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[38]==1'b1 && xPixel>=450 && xPixel<=470 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[39]==1'b1 && xPixel>=500 && xPixel<=520 && yPixel>=230 && yPixel<=250)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[40]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=120 && yPixel<=140)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[41]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=170 && yPixel<=190)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[42]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=290 && yPixel<=310)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
		if(blockEn[43]==1'b1 && xPixel>=310 && xPixel<=330 && yPixel>=340 && yPixel<=360)
			begin
			VGA_R = 8'b11111111;
			VGA_G = 8'b11111111;
			VGA_B = 8'b11111111;
			end
			
		if(xPixel >= x && xPixel <= x+50 && yPixel >= y && yPixel <= y +50)//pacman
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b11111111;
				VGA_B = 8'b00000000;
			end
		if(xPixel >= x_ghost && xPixel <= x_ghost+50 && yPixel >= y_ghost && yPixel <= y_ghost + 50)//ghost
			begin
				VGA_R = 8'b11111111;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if (xPixel>=0 && xPixel<=640 && yPixel>=0 && yPixel<=35)//TopBar
		begin
			VGA_R = 8'b00000000;
			VGA_G = 8'b00000000;
			VGA_B = 8'b11111111;
		end
		if(xPixel>0 && xPixel<640 && yPixel>445 && yPixel<480)//BottomBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>0 && xPixel<35 && yPixel>0 && yPixel<480)//LeftBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
		if(xPixel>605 && xPixel<640 && yPixel>0 && yPixel<480)//RightBar
			begin
				VGA_R = 8'b00000000;
				VGA_G = 8'b00000000;
				VGA_B = 8'b11111111;
			end
	////////////////////////////////////////////////////////////////Maze 2
		//Drawing Solid shape "Upper Left Box"
	if(xPixel>105 && xPixel<285 && yPixel>105 && yPixel<205)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end
	
		//Drawing Solid shape "Upper Right Box"
	if(xPixel>355 && xPixel<535 && yPixel>105 && yPixel<205)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end
	
		//Drawing Solid shape "Lower Left Box"
	if(xPixel>105 && xPixel<285 && yPixel>275 && yPixel<375)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end
	
		//Drawing Solid shape "Lower Right Box"
	if(xPixel>355 && xPixel<535 && yPixel>275 && yPixel<375)
	begin
		VGA_R = 8'b00000000;
		VGA_G = 8'b00000000;
		VGA_B = 8'b11111111;
	end			
	end
	Maze2Winner:begin
		if(rst==1'b0)
			NS=StartScreen;
		else
			NS=Maze2Winner;
		VGA_R=8'b00000000;
		VGA_G=8'b00000000;
		VGA_B=8'b00000000;
			if(pacmanScore>GhostScore)
			begin
			if(xPixel>50 && xPixel<150 && yPixel>190 && yPixel<290)
			begin//square
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'd0;
				end
			if((xPixel>170 && xPixel<190 && yPixel>170 && yPixel<290)||(xPixel>190 && xPixel<210&& yPixel>290 && yPixel<310)
			||(xPixel>210 && xPixel<230 && yPixel>230 && yPixel<290)||(xPixel>230 && xPixel<250 && yPixel>290 && yPixel<310)
			||(xPixel>250 && xPixel<270 && yPixel>170 && yPixel<290))
			begin//W
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if(xPixel>290 && xPixel<310 && yPixel>170 && yPixel<310)
			begin//I
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>330 && xPixel<350 && yPixel>170 && yPixel<310)||(xPixel>350 && xPixel<370 && yPixel>210 && yPixel<230)
			||(xPixel>370 && xPixel<390 && yPixel>230 && yPixel<250)||(xPixel>390 && xPixel<410 && yPixel>250 && yPixel<270)
			||(xPixel>410 && xPixel<430 && yPixel>170 && yPixel<310))
			begin//N
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>530 && xPixel<550 && yPixel>190 && yPixel<210)||(xPixel>470 && xPixel<530 && yPixel>170 && yPixel<190)
			||(xPixel>450 && xPixel<470 && yPixel>190 && yPixel<230)||(xPixel>470 && xPixel<530 && yPixel>230 && yPixel<250)
			||(xPixel>530 && xPixel<550 && yPixel>250 && yPixel<290)||(xPixel>470 && xPixel<530 && yPixel>290 && yPixel<310)
			||(xPixel>450 && xPixel<460 && yPixel>270 && yPixel<290))
			begin//S
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end			
			if((xPixel>570 && xPixel<590 && yPixel>170 && yPixel<270)||(xPixel>570 && xPixel<590 && yPixel>290 && yPixel<310))
			begin//!
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
		end
		else if(pacmanScore<GhostScore)
			begin
			if(xPixel>50 && xPixel<150 && yPixel>190 && yPixel<290)
			begin//square
				VGA_R=8'b11111111;
				VGA_G=8'b00000000;
				VGA_B=8'b11111111;
				end
			if((xPixel>170 && xPixel<190 && yPixel>170 && yPixel<290)||(xPixel>190 && xPixel<210&& yPixel>290 && yPixel<310)
			||(xPixel>210 && xPixel<230 && yPixel>230 && yPixel<290)||(xPixel>230 && xPixel<250 && yPixel>290 && yPixel<310)
			||(xPixel>250 && xPixel<270 && yPixel>170 && yPixel<290))
			begin//W
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if(xPixel>290 && xPixel<310 && yPixel>170 && yPixel<310)
			begin//I
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>330 && xPixel<350 && yPixel>170 && yPixel<310)||(xPixel>350 && xPixel<370 && yPixel>210 && yPixel<230)
			||(xPixel>370 && xPixel<390 && yPixel>230 && yPixel<250)||(xPixel>390 && xPixel<410 && yPixel>250 && yPixel<270)
			||(xPixel>410 && xPixel<430 && yPixel>170 && yPixel<310))
			begin//N
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
			if((xPixel>530 && xPixel<550 && yPixel>190 && yPixel<210)||(xPixel>470 && xPixel<530 && yPixel>170 && yPixel<190)
			||(xPixel>450 && xPixel<470 && yPixel>190 && yPixel<230)||(xPixel>470 && xPixel<530 && yPixel>230 && yPixel<250)
			||(xPixel>530 && xPixel<550 && yPixel>250 && yPixel<290)||(xPixel>470 && xPixel<530 && yPixel>290 && yPixel<310)
			||(xPixel>450 && xPixel<460 && yPixel>270 && yPixel<290))
			begin//S
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end			
			if((xPixel>570 && xPixel<590 && yPixel>170 && yPixel<270)||(xPixel>570 && xPixel<590 && yPixel>290 && yPixel<310))
			begin//!
				VGA_R=8'b11111111;
				VGA_G=8'b11111111;
				VGA_B=8'b11111111;
			end
		end
		else
			begin
				if((xPixel>170 && xPixel<270 && yPixel>170 && yPixel<190) || (xPixel>210 && xPixel<230 && yPixel>170 && yPixel<310))
				begin//T
					VGA_R=8'b11111111;
					VGA_G=8'b11111111;
					VGA_B=8'b11111111;
				end				
				if(xPixel>290 && xPixel<310 && yPixel>170 && yPixel<310)
				begin//I
					VGA_R=8'b11111111;
					VGA_G=8'b11111111;
					VGA_B=8'b11111111;
				end
				if((xPixel>330 && xPixel<350 && yPixel>170 && yPixel<310) || (xPixel>330 && xPixel<430 && yPixel>170 && yPixel<190)
				||(xPixel>330 && xPixel<410 && yPixel>230 && yPixel<250) || (xPixel>330 && xPixel<430 && yPixel>290 && yPixel<310))
				begin//E
					VGA_R=8'b11111111;
					VGA_G=8'b11111111;
					VGA_B=8'b11111111;
				end
			end
	end

endcase
end

always @(posedge update)
begin

case(S)
	StartScreen:begin
			t <= 8'd0;
			x <= 11'd45; 
			y <= 11'd45;
			x_ghost <= 11'd545;
			y_ghost <= 11'd385;
			pacmanScore<=7'd0;
			GhostScore<=7'd0;
			blockEn<=44'b00001111111111111111111111111111111111111111;
			fruitEn[2:0]<=3'd0;
			GameOver<=1'b0;
			end
	Maze1Wait:begin
			t <= 8'd0;
			x <= 11'd45; 
			y <= 11'd45;
			x_ghost <= 11'd545;
			y_ghost <= 11'd385;
			pacmanScore<=7'd0;
			GhostScore<=7'd0;
			blockEn<=44'b00001111111111111111111111111111111111111111;
			fruitEn[2:0]<=3'd0;
			GameOver<=1'b0;
			end
	Maze1:begin
			t <= t + 9'd1;
			case(GhostDirection)
				3'd1: if(x_ghost<=545)
						begin
						x_ghost <= x_ghost + 11'd10; //left at a speed of "10"
						if(x_ghost>=55 && x_ghost<=525 && y_ghost>=65 && y_ghost<=195)
						x_ghost<=x_ghost;
						if(x_ghost>=55 && x_ghost<=525 && y_ghost>=230 && y_ghost<=365)
						x_ghost<=x_ghost;
						end
				3'd2: if(x_ghost>=45)
						begin
						x_ghost <= x_ghost - 11'd10; //right at a speed of "10"
						if(x_ghost>=65 && x_ghost<=535 && y_ghost>=65 && y_ghost<=195)
						x_ghost<=x_ghost;
						if(x_ghost>=65 && x_ghost<=535 && y_ghost>=230 && y_ghost<=365)
						x_ghost<=x_ghost;
						end
				3'd3: if(y_ghost>=45)
						begin
						y_ghost <= y_ghost - 11'd10; //up at a speed of "10"
						if(x_ghost>=65 && x_ghost<=525 && y_ghost>=65 && y_ghost<=205)
						y_ghost<=y_ghost;
						if(x_ghost>=65 && x_ghost<=525 && y_ghost>=235 && y_ghost<=375)
						y_ghost<=y_ghost;
						end
				3'd4: if(y_ghost<=385)
						begin
						y_ghost <= y_ghost + 11'd10; //down at a speed of "10"
						if(x_ghost>=65 && x_ghost<=525 && y_ghost>=55 && y_ghost<=195)
						y_ghost<=y_ghost;
						if(x_ghost>=65 && x_ghost<=525 && y_ghost>=225 && y_ghost<=365)
						y_ghost<=y_ghost;
						end
				default:
				begin
					x_ghost <= x_ghost; //stationary
					y_ghost <= y_ghost;
				end
		endcase
		case(direction)
			3'd1: if(x<=545)
					begin
					x <= x + 11'd10; //right at a speed of "10"
					if(x>=55 && x<=525 && y>=65 && y<=195)
					x<=x;
					if(x>=55 && x<=525 && y>=230 && y<=365)
					x<=x;
					end
			3'd2: if(x>=45)
					begin
					x <= x - 11'd10; //left at a speed of "10"
					if(x>=65 && x<=535 && y>=65 && y<=195)
					x<=x;
					if(x>=65 && x<=535 && y>=230 && y<=365)
					x<=x;
					end
			3'd3: if(y>=45)
					begin
					y <= y - 11'd10; //up at a speed of "10"
					if(x>=65 && x<=525 && y>=65 && y<=205)
					y<=y;
					if(x>=65 && x<=525 && y>=235 && y<=375)
					y<=y;
					end
			3'd4: if(y<=385)
					begin
					y <= y + 11'd10; //down at a speed of "10"
					if(x>=65 && x<=525 && y>=55 && y<=195)
					y<=y;
					if(x>=65 && x<=525 && y>=225 && y<=365)
					y<=y;
					end
			default: 
			begin
				x <= x;	//stationary
				y <= y;
			end
		endcase
		
		if(t == 9'd150)
			fruitEn[0]=1'b1;
		if(fruitCollisionPacman[0]==1'b1)
		begin
			pacmanScore<=pacmanScore+7'd5;
			fruitEn[0]<=1'b0;
		end
		if(fruitCollisionGhost[0]==1'b1)
		begin
			GhostScore<=GhostScore+7'd5;
			fruitEn[0]<=1'b0;
		end

		if(collision[0]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[0]<=1'b0;
		end
		else if(collision[1]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[1]<=1'b0;
		end
		else if(collision[2]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[2]<=1'b0;
		end
		else if(collision[3]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[3]<=1'b0;
		end
		else if(collision[4]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[4]<=1'b0;
		end
		else if(collision[5]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[5]<=1'b0;
		end
		else if(collision[6]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[6]<=1'b0;
		end
		else if(collision[7]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[7]<=1'b0;
		end
		else if(collision[8]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[8]<=1'b0;
		end	
		else if(collision[9]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[9]<=1'b0;
		end
		else if(collision[10]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[10]<=1'b0;
		end
		else if(collision[11]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[11]<=1'b0;
		end
		else if(collision[12]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[12]<=1'b0;
		end
		else if(collision[13]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[13]<=1'b0;
		end
		else if(collision[14]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[14]<=1'b0;
		end
		else if(collision[15]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[15]<=1'b0;
		end
		else if(collision[16]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[16]<=1'b0;
		end
		else if(collision[17]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[17]<=1'b0;
		end
		else if(collision[18]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[18]<=1'b0;
		end
		else if(collision[19]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[19]<=1'b0;
		end
		else if(collision[20]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[20]<=1'b0;
		end
		else if(collision[21]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[21]<=1'b0;
		end
		else if(collision[22]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[22]<=1'b0;
		end
		else if(collision[23]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[23]<=1'b0;
		end
		else if(collision[24]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[24]<=1'b0;
		end
		else if(collision[25]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[25]<=1'b0;
		end
		else if(collision[26]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[26]<=1'b0;
		end
		else if(collision[27]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[27]<=1'b0;
		end
		else if(collision[28]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[28]<=1'b0;
		end
		else if(collision[29]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[29]<=1'b0;
		end
		else if(collision[30]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[30]<=1'b0;
		end
		else if(collision[31]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[31]<=1'b0;
		end
		else if(collision[32]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[32]<=1'b0;
		end
		else if(collision[33]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[33]<=1'b0;
		end
		else if(collision[34]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[34]<=1'b0;
		end
		else if(collision[35]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[35]<=1'b0;
		end
		else if(collision[36]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[36]<=1'b0;
		end
		else if(collision[37]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[37]<=1'b0;
		end
		else if(collision[38]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[38]<=1'b0;
		end
		else if(collision[39]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[39]<=1'b0;
		end
		
		if(PlayerCollision==1'b1)
		begin
			GhostScore<=GhostScore+7'd40;
			GameOver<=1'b1;
		end
	end
	
	Maze1Winner:begin
			t <= 9'd0;
			x <= 11'd45; 
			y <= 11'd45;
			x_ghost <= 11'd545;
			y_ghost <= 11'd385;
			blockEn<=44'b11111111111111111111111111111111111111111111;
			fruitEn[2:0]<=3'd0;
			GameOver<=1'b0;
			end
			
	Maze2Wait:begin
			t <= 9'd0;
			x <= 11'd45; 
			y <= 11'd45;
			x_ghost <= 11'd545;
			y_ghost <= 11'd385;
			pacmanScore<=7'd0;
			GhostScore<=7'd0;
			blockEn<=44'b11111111111111111111111111111111111111111111;
			fruitEn[2:0]<=3'd0;
			GameOver=1'b0;
			end
	
	Maze2:begin
			t <= t + 9'd1;
			case(GhostDirection)
				3'd1: if(x_ghost<=545)
						begin
						x_ghost <= x_ghost + 11'd10; //right at a speed of "10"
						if(x_ghost>=55 && x_ghost<=275 && y_ghost>=65 && y_ghost<=195)//Upper left box
						x_ghost<=x_ghost;
						if(x_ghost>=305 && x_ghost<=525 && y_ghost>=65 && y_ghost<=195)//Upper right box
						x_ghost<=x_ghost;
						if(x_ghost>=55 && x_ghost<=275 && y_ghost>=235 && y_ghost<=365)//Bottom left box
						x_ghost<=x_ghost;
						if(x_ghost>=305 && x_ghost<=525 && y_ghost>=235 && y_ghost<=365)//Bottom right box
						x_ghost<=x_ghost;
						end				
				3'd2: if(x_ghost>=45)
						begin
						x_ghost <= x_ghost - 11'd10; //left at a speed of "10"
						if(x_ghost>=65 && x_ghost<=285 && y_ghost>=65 && y_ghost<=195)//Upper left box
						x_ghost<=x_ghost;
						if(x_ghost>=315 && x_ghost<=535 && y_ghost>=65 && y_ghost<=195)//Upper right box
						x_ghost<=x_ghost;
						if(x_ghost>=65 && x_ghost<=285 && y_ghost>=235 && y_ghost<=365)//Bottom left box
						x_ghost<=x_ghost;
						if(x_ghost>=315 && x_ghost<=535 && y_ghost>=235 && y_ghost<=365)//Bottom right box
						x_ghost<=x_ghost;
						end
				3'd3: if(y_ghost>=45)
						begin
						y_ghost <= y_ghost - 11'd10; //up at a speed of "10"
						if(x_ghost>=65 && x_ghost<=275 && y_ghost>=65 && y_ghost<=205)//Upper left box
						y_ghost<=y_ghost;
						if(x_ghost>=315 && x_ghost<=535 && y_ghost>=65 && y_ghost<=205)//Upper right box
						y_ghost<=y_ghost;
						if(x_ghost>=65 && x_ghost<=275 && y_ghost>=235 && y_ghost<=375)//Bottom left box
						y_ghost<=y_ghost;
						if(x_ghost>=315 && x_ghost<=535 && y_ghost>=235 && y_ghost<=375)//Bottom right box
						y_ghost<=y_ghost;
						end
				3'd4: if(y_ghost<=385)
						begin
						y_ghost <= y_ghost + 11'd10; //down at a speed of "10"
						if(x_ghost>=65 && x_ghost<=275 && y_ghost>=55 && y_ghost<=195)//Upper left box
						y_ghost<=y_ghost;
						if(x_ghost>=315 && x_ghost<=535 && y_ghost>=55 && y_ghost<=195)//Upper right box
						y_ghost<=y_ghost;						
						if(x_ghost>=65 && x_ghost<=275 && y_ghost>=225 && y_ghost<=365)//Bottom left box
						y_ghost<=y_ghost;
						if(x_ghost>=315 && x_ghost<=535 && y_ghost>=225 && y_ghost<=365)//Bottom right box
						y_ghost<=y_ghost;
						end
				default:
				begin
					x_ghost <= x_ghost; //stationary
					y_ghost <= y_ghost;
				end
		endcase
		case(direction)
			3'd1: if(x<=545)
					begin
					x <= x + 11'd10; //right at a speed of "10"
					if(x>=55 && x<=275 && y>=65 && y<=195)//Upper left box
					x<=x;
					if(x>=305 && x<=525 && y>=65 && y<=195)//Upper right box
					x<=x;
					if(x>=55 && x<=275 && y>=235 && y<=365)//Bottom left box
					x<=x;
					if(x>=305 && x<=525 && y>=235 && y<=365)//Bottom right box
					x<=x;
					end	
			3'd2: if(x>=45)
					begin
					x <= x - 11'd10; //left at a speed of "10"
					if(x>=65 && x<=285 && y>=65 && y<=195)//Upper left box
					x<=x;
					if(x>=315 && x<=535 && y>=65 && y<=195)//Upper right box
					x<=x;
					if(x>=65 && x<=285 && y>=235 && y<=365)//Bottom left box
					x<=x;
					if(x>=315 && x<=535 && y>=235 && y<=365)//Bottom right box
					x<=x;
					end
				3'd3: if(y>=45)
						begin
						y <= y - 11'd10; //up at a speed of "10"
						if(x>=65 && x<=275 && y>=65 && y<=205)//Upper left box
						y<=y;
						if(x>=315 && x<=535 && y>=65 && y<=205)//Upper right box
						y<=y;
						if(x>=65 && x<=275 && y>=235 && y<=375)//Bottom left box
						y<=y;
						if(x>=315 && x<=535 && y>=235 && y<=375)//Bottom right box
						y<=y;
						end
			3'd4: if(y<=385)
					begin
					y <= y + 11'd10; //down at a speed of "10"
					if(x>=65 && x<=275 && y>=55 && y<=195)//Upper left box
					y<=y;
					if(x>=315 && x<=535 && y>=55 && y<=195)//Upper right box
					y<=y;						
					if(x>=65 && x<=275 && y>=225 && y<=365)//Bottom left box
					y<=y;
					if(x>=315 && x<=535 && y>=225 && y<=365)//Bottom right box
					y<=y;
					end
			default: 
			begin
				x <= x;	//stationary
				y <= y;
			end
		endcase
		
		if(t == 9'd100)
			fruitEn[0]=1'b1;
		if(fruitCollisionPacman[0]==1'b1)
		begin
			pacmanScore<=pacmanScore+7'd5;
			fruitEn[0]<=1'b0;
		end
		if(fruitCollisionGhost[0]==1'b1)
		begin
			GhostScore<=GhostScore+7'd5;
			fruitEn[0]<=1'b0;
		end
		
		if(t == 9'd200)
			fruitEn[1]=1'b1;
		if(fruitCollisionPacman[1]==1'b1)
		begin
			pacmanScore<=pacmanScore+7'd5;
			fruitEn[1]<=1'b0;
		end
		if(fruitCollisionGhost[1]==1'b1)
		begin
			GhostScore<=GhostScore+7'd5;
			fruitEn[1]<=1'b0;
		end
		
		if(t == 9'd300)
			fruitEn[2]=1'b1;
		if(fruitCollisionPacman[2]==1'b1)
		begin
			pacmanScore<=pacmanScore+7'd5;
			fruitEn[2]<=1'b0;
		end
		if(fruitCollisionGhost[2]==1'b1)
		begin
			GhostScore<=GhostScore+7'd5;
			fruitEn[2]<=1'b0;
		end
		
		if(collision[0]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[0]<=1'b0;
		end
		else if(collision[1]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[1]<=1'b0;
		end
		else if(collision[2]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[2]<=1'b0;
		end
		else if(collision[3]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[3]<=1'b0;
		end
		else if(collision[4]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[4]<=1'b0;
		end
		else if(collision[5]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[5]<=1'b0;
		end
		else if(collision[6]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[6]<=1'b0;
		end
		else if(collision[7]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[7]<=1'b0;
		end
		else if(collision[8]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[8]<=1'b0;
		end	
		else if(collision[9]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[9]<=1'b0;
		end
		else if(collision[10]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[10]<=1'b0;
		end
		else if(collision[11]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[11]<=1'b0;
		end
		else if(collision[12]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[12]<=1'b0;
		end
		else if(collision[13]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[13]<=1'b0;
		end
		else if(collision[14]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[14]<=1'b0;
		end
		else if(collision[15]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[15]<=1'b0;
		end
		else if(collision[16]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[16]<=1'b0;
		end
		else if(collision[17]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[17]<=1'b0;
		end
		else if(collision[18]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[18]<=1'b0;
		end
		else if(collision[19]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[19]<=1'b0;
		end
		else if(collision[20]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[20]<=1'b0;
		end
		else if(collision[21]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[21]<=1'b0;
		end
		else if(collision[22]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[22]<=1'b0;
		end
		else if(collision[23]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[23]<=1'b0;
		end
		else if(collision[24]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[24]<=1'b0;
		end
		else if(collision[25]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[25]<=1'b0;
		end
		else if(collision[26]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[26]<=1'b0;
		end
		else if(collision[27]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[27]<=1'b0;
		end
		else if(collision[28]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[28]<=1'b0;
		end
		else if(collision[29]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[29]<=1'b0;
		end
		else if(collision[30]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[30]<=1'b0;
		end
		else if(collision[31]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[31]<=1'b0;
		end
		else if(collision[32]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[32]<=1'b0;
		end
		else if(collision[33]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[33]<=1'b0;
		end
		else if(collision[34]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[34]<=1'b0;
		end
		else if(collision[35]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[35]<=1'b0;
		end
		else if(collision[36]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[36]<=1'b0;
		end
		else if(collision[37]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[37]<=1'b0;
		end
		else if(collision[38]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[38]<=1'b0;
		end
		else if(collision[39]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[39]<=1'b0;
		end
		else if(collision[40]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[40]<=1'b0;
		end
		else if(collision[41]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[41]<=1'b0;
		end
		else if(collision[42]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[42]<=1'b0;
		end
		else if(collision[43]==1'b1)
		begin	
			pacmanScore<=pacmanScore+7'd1;
			blockEn[43]<=1'b0;
		end
		
		if(PlayerCollision==1'b1)
		begin
			GhostScore<=GhostScore+7'd44;
			GameOver<=1'b1;
		end
	end
	Maze2Winner:begin
			t <= 8'd0;
			x <= 11'd45; 
			y <= 11'd45;
			x_ghost <= 11'd545;
			y_ghost <= 11'd385;
			blockEn<=44'b11111111111111111111111111111111111111111111;
			fruitEn[2:0]<=3'd0;
			GameOver<=1'b0;
			end
endcase
end

	
endmodule
















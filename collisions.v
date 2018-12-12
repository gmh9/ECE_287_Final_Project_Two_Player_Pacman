///////////////////////////////////////////////////////////// Determines if a collision has occured
module collisions(collClk,x,y,x_ghost,y_ghost, rst, blockEn, fruitEn, collision, fruitCollisionPacman, fruitCollisionGhost, PlayerCollision);
input collClk;
input [43:0]blockEn;
input [2:0]fruitEn;
input [10:0]x;
input[10:0]y;
input [10:0]x_ghost;
input [10:0]y_ghost;
output [43:0]collision;
output [2:0]fruitCollisionPacman;
output [2:0]fruitCollisionGhost;
output PlayerCollision;
reg [43:0]collision;
reg [2:0]fruitCollisionPacman;
reg [2:0]fruitCollisionGhost;
reg PlayerCollision;
output reg rst = 0;

always @ (collClk)
begin
if(x+50>280 && x+50<300 && y>195 && y<235 && fruitEn[0]==1'b1)
	begin
	fruitCollisionPacman[0]=1'b1;
	end		
else if(x>280 && x<300 && y>195 && y<235 && fruitEn[0]==1'b1)
	begin
	fruitCollisionPacman[0]=1'b1;
	end
else if(x>275 && x<295 && y>230 && y<250 && fruitEn[0]==1'b1)
	begin
	fruitCollisionPacman[0]=1'b1;
	end
else if(x>275 && x<295 && y+50>230 && y+50<250 && fruitEn[0]==1'b1)
	begin
	fruitCollisionPacman[0]=1'b1;
	end	
else
	begin
		fruitCollisionPacman[0]=1'b0;
	end
	

if(x>60 && x<80 && y>25 && y<65 && fruitEn[1]==1'b1)
	begin
	fruitCollisionPacman[1]=1'b1;
	end		
else if(x>25 && x<65 && y>60 && y<80 && fruitEn[1]==1'b1)
	begin
	fruitCollisionPacman[1]=1'b1;
	end
else
	begin
		fruitCollisionPacman[1]=1'b0;
	end
	
if(x+50>280 && x+50<300 && y>365 && y<405 && fruitEn[2]==1'b1)
	begin
	fruitCollisionPacman[2]=1'b1;
	end		
else if(x>280 && x<300 && y>365 && y<405 && fruitEn[2]==1'b1)
	begin
	fruitCollisionPacman[2]=1'b1;
	end
else
	begin
		fruitCollisionPacman[2]=1'b0;
	end

if(x_ghost+50>280 && x_ghost+50<300 && y_ghost>195 && y_ghost<235 && fruitEn[0]==1'b1)
	begin
	fruitCollisionGhost[0]=1'b1;
	end		
else if(x_ghost>280 && x_ghost<300 && y_ghost>195 && y_ghost<235 && fruitEn[0]==1'b1)
	begin
	fruitCollisionGhost[0]=1'b1;
	end
else if(x_ghost>275 && x_ghost<295 && y_ghost>230 && y_ghost<250 && fruitEn[0]==1'b1)
	begin
	fruitCollisionGhost[0]=1'b1;
	end
else if(x_ghost>275 && x_ghost<295 && y_ghost+50>230 && y_ghost+50<250 && fruitEn[0]==1'b1)
	begin
	fruitCollisionGhost[0]=1'b1;
	end	
else
	begin
		fruitCollisionGhost[0]=1'b0;
	end
	

if(x_ghost>60 && x_ghost<80 && y_ghost>25 && y_ghost<65 && fruitEn[1]==1'b1)
	begin
	fruitCollisionGhost[1]=1'b1;
	end		
else if(x_ghost>25 && x_ghost<65 && y_ghost>60 && y_ghost<80 && fruitEn[1]==1'b1)
	begin
	fruitCollisionGhost[1]=1'b1;
	end
else
	begin
		fruitCollisionGhost[1]=1'b0;
	end
	
if(x_ghost+50>280 && x_ghost+50<300 && y_ghost>365 && y_ghost<405 && fruitEn[2]==1'b1)
	begin
	fruitCollisionGhost[2]=1'b1;
	end		
else if(x_ghost>280 && x_ghost<300 && y_ghost>365 && y_ghost<405 && fruitEn[2]==1'b1)
	begin
	fruitCollisionGhost[2]=1'b1;
	end
else
	begin
		fruitCollisionGhost[2]=1'b0;
	end

	
if(x+50>310 && x+50<330 && y>25 && y<65 && blockEn[0]==1'b1)
	collision[0]=1'b1;
else if(x>310 && x<330 && y>25 && y<65 && blockEn[0]==1'b1)
	collision[0]=1'b1;
else if(x>275 && x<305 && y>60 && y<80 && blockEn[0]==1'b1)
	collision[0]=1'b1;
else
	collision[0]=1'b0;
	
if(x+50>350 && x+50<370 && y>25 && y<65 && blockEn[1]==1'b1)
	collision[1]=1'b1;
else if(x>350 && x<370 && y>25 && y<65 && blockEn[1]==1'b1)
	collision[1]=1'b1;
else
	collision[1]=1'b0;

if(x+50>400 && x+50<420 && y>25 && y<65 && blockEn[2]==1'b1)
	collision[2]=1'b1;
else if(x>400 && x<420 && y>25 && y<65 && blockEn[2]==1'b1)
	collision[2]=1'b1;
else
	collision[2]=1'b0;
	
if(x+50>450 && x+50<470 && y>25 && y<65 && blockEn[3]==1'b1)
	collision[3]=1'b1;
else if(x>450 && x<470 && y>25 && y<65 && blockEn[3]==1'b1)
	collision[3]=1'b1;
else
	collision[3]=1'b0;
	
if(x+50>500 && x+50<520 && y>25 && y<65 && blockEn[4]==1'b1)
	collision[4]=1'b1;
else if(x>500 && x<520 && y>25 && y<65 && blockEn[4]==1'b1)
	collision[4]=1'b1;
else
	collision[4]=1'b0;
	
if(x+50>560 && x+50<580 && y>25 && y<65 && blockEn[5]==1'b1)//******Upper Right Corner
	collision[5]=1'b1;
else if(x>525 && x<565 && y>60 && y<80 && blockEn[5]==1'b1) 
	collision[5]=1'b1;
else
	collision[5]=1'b0;

if(x>525 && x<565 && y+50>120 && y+50<140 && blockEn[6]==1'b1)
	collision[6]=1'b1;
else if(x>525 && x<565 && y>120 && y<140 && blockEn[6]==1'b1)
	collision[6]=1'b1;
else
	collision[6]=1'b0;
	
if(x>525 && x<565 && y+50>170 && y+50<190 && blockEn[7]==1'b1)
	collision[7]=1'b1;
else if(x>525 && x<565 && y>170 && y<190 && blockEn[7]==1'b1)
	collision[7]=1'b1;
else
	collision[7]=1'b0;
	
if(x>525 && x<565 && y+50>230 && y+50<250 && blockEn[8]==1'b1)
	collision[8]=1'b1;
else if(x>525 && x<565 && y>230 && y<250 && blockEn[8]==1'b1)
	collision[8]=1'b1;
else if(x+50>560 && x+50<580 && y>195 && y<225 && blockEn[8]==1'b1)
	collision[8]=1'b1;
else
	collision[8]=1'b0;
	
if(x>525 && x<565 && y+50>290 && y+50<310 && blockEn[9]==1'b1)
	collision[9]=1'b1;
else if(x>525 && x<565 && y>290 && y<310 && blockEn[9]==1'b1)
	collision[9]=1'b1;
else
	collision[9]=1'b0;
	
if(x>525 && x<565 && y+50>340 && y+50<360 && blockEn[10]==1'b1)
	collision[10]=1'b1;
else if(x>525 && x<565 && y>340 && y<360 && blockEn[10]==1'b1)
	collision[10]=1'b1;
else
	collision[10]=1'b0;
	
if(x+50>560 && x+50<580 && y>365 && y<405 && blockEn[11]==1'b1) //****Bottom Right Corner
	collision[11]=1'b1;
else if(x>525 && x<565 && y+50>400 && y+50<420 && blockEn[11]==1'b1)
	collision[11]=1'b1;
else
	collision[11]=1'b0;

if(x+50>500 && x+50<520 && y>365 && y<405 && blockEn[12]==1'b1) 
	collision[12]=1'b1;
else if(x>500 && x<520 && y>365 && y<405 && blockEn[12]==1'b1)
	collision[12]=1'b1;
else
	collision[12]=1'b0;

if(x+50>450 && x+50<470 && y>365 && y<405 && blockEn[13]==1'b1) 
	collision[13]=1'b1;
else if(x>450 && x<470 && y>365 && y<405 && blockEn[13]==1'b1)
	collision[13]=1'b1;
else
	collision[13]=1'b0;
	
if(x+50>400 && x+50<420 && y>365 && y<405 && blockEn[14]==1'b1) 
	collision[14]=1'b1;
else if(x>400 && x<420 && y>365 && y<405 && blockEn[14]==1'b1)
	collision[14]=1'b1;
else
	collision[14]=1'b0;
	
if(x+50>350 && x+50<370 && y>365 && y<405 && blockEn[15]==1'b1) 
	collision[15]=1'b1;
else if(x>350 && x<370 && y>365 && y<405 && blockEn[15]==1'b1)
	collision[15]=1'b1;
else
	collision[15]=1'b0;
	
if(x+50>310 && x+50<330 && y>365 && y<405 && blockEn[16]==1'b1) 
	collision[16]=1'b1;
else if(x>310 && x<330 && y>365 && y<405 && blockEn[16]==1'b1)
	collision[16]=1'b1;
else if(x>275 && x<305 && y+50>400 && y+50<420 && blockEn[16]==1'b1)
	collision[16]=1'b1;
else
	collision[16]=1'b0;

if(x+50>250 && x+50<270 && y>365 && y<405 && blockEn[17]==1'b1) 
	collision[17]=1'b1;
else if(x>250 && x<270 && y>365 && y<405 && blockEn[17]==1'b1)
	collision[17]=1'b1;
else
	collision[17]=1'b0;
	
if(x+50>200 && x+50<220 && y>365 && y<405 && blockEn[18]==1'b1) 
	collision[18]=1'b1;
else if(x>200 && x<220 && y>365 && y<405 && blockEn[18]==1'b1)
	collision[18]=1'b1;
else
	collision[18]=1'b0;
	
if(x+50>150 && x+50<170 && y>365 && y<405 && blockEn[19]==1'b1) 
	collision[19]=1'b1;
else if(x>150 && x<170 && y>365 && y<405 && blockEn[19]==1'b1)
	collision[19]=1'b1;
else
	collision[19]=1'b0;
	
if(x+50>100 && x+50<120 && y>365 && y<405 && blockEn[20]==1'b1) 
	collision[20]=1'b1;
else if(x>100 && x<120 && y>365 && y<405 && blockEn[20]==1'b1)
	collision[20]=1'b1;
else
	collision[20]=1'b0;
	
if(x>60 && x<80 && y>365 && y<405 && blockEn[21]==1'b1) //****Bottom left corner
	collision[21]=1'b1;
else if(x>25 && x<65 && y+50>400 && y+50<420 && blockEn[21])
	collision[21]=1'b1;
else
	collision[21]=1'b0;
	
if(x>25 && x<65 && y+50>340 && y+50<360 && blockEn[22]==1'b1) 
	collision[22]=1'b1;
else if(x>25 && x<65 && y>340 && y<360 && blockEn[22]==1'b1)
	collision[22]=1'b1;
else
	collision[22]=1'b0;

if(x>25 && x<65 && y+50>290 && y+50<310 && blockEn[23]==1'b1) 
	collision[23]=1'b1;
else if(x>25 && x<65 && y>290 && y<310 && blockEn[23]==1'b1)
	collision[23]=1'b1;
else
	collision[23]=1'b0;
	
if(x>25 && x<65 && y+50>230 && y+50<250 && blockEn[24]==1'b1)
	collision[24]=1'b1;
else if(x>25 && x<65 && y>230 && y<250 && blockEn[24]==1'b1)
	collision[24]=1'b1;
else if(x>60 && x<80 && y>195 && y<225 && blockEn[24]==1'b1)
	collision[24]=1'b1;
else
	collision[24]=1'b0;
	
if(x>25 && x<65 && y+50>170 && y+50<190 && blockEn[25]==1'b1) 
	collision[25]=1'b1;
else if(x>25 && x<65 && y>170 && y<190 && blockEn[25]==1'b1)
	collision[25]=1'b1;
else
	collision[25]=1'b0;
	
if(x>25 && x<65 && y+50>120 && y+50<140 && blockEn[26]==1'b1) 
	collision[26]=1'b1;
else if(x>25 && x<65 && y>120 && y<140 && blockEn[26]==1'b1)
	collision[26]=1'b1;
else
	collision[26]=1'b0;
	
if(x+50>100 && x+50<120 && y>25 && y<65 && blockEn[27]==1'b1) 
	collision[27]=1'b1;
else if(x+50>100 && x+50<120 && y>25 && y<65 && blockEn[27]==1'b1)
	collision[27]=1'b1;
else
	collision[27]=1'b0;

if(x+50>150 && x+50<170 && y>25 && y<65 && blockEn[28]==1'b1) 
	collision[28]=1'b1;
else if(x>150 && x<170 && y>25 && y<65 && blockEn[28]==1'b1)
	collision[28]=1'b1;
else
	collision[28]=1'b0;
	
if(x+50>200 && x+50<220 && y>25 && y<65 && blockEn[29]==1'b1) 
	collision[29]=1'b1;
else if(x>200 && x<220 && y>25 && y<65 && blockEn[29]==1'b1)
	collision[29]=1'b1;
else
	collision[29]=1'b0;

if(x+50>250 && x+50<270 && y>25 && y<65 && blockEn[30]==1'b1) 
	collision[30]=1'b1;
else if(x>250 && x<270 && y>25 && y<65 && blockEn[30]==1'b1)
	collision[30]=1'b1;
else
	collision[30]=1'b0;
	
if(x+50>100 && x+50<120 && y>195 && y<235 && blockEn[31]==1'b1) 
	collision[31]=1'b1;
else if(x>100 && x<120 && y>195 && y<235 && blockEn[31]==1'b1)
	collision[31]=1'b1;
else
	collision[31]=1'b0;
	
if(x+50>150 && x+50<170 && y>195 && y<235 && blockEn[32]==1'b1) 
	collision[32]=1'b1;
else if(x>150 && x<170 && y>195 && y<235 && blockEn[32]==1'b1)
	collision[32]=1'b1;
else
	collision[32]=1'b0;
	
if(x+50>200 && x+50<220 && y>195 && y<235 && blockEn[33]==1'b1) 
	collision[33]=1'b1;
else if(x>200 && x<220 && y>195 && y<235 && blockEn[33]==1'b1)
	collision[33]=1'b1;
else
	collision[33]=1'b0;
	
if(x+50>250 && x+50<270 && y>195 && y<235 && blockEn[34]==1'b1) 
	collision[34]=1'b1;
else if(x>250 && x<270 && y>195 && y<235 && blockEn[34]==1'b1)
	collision[34]=1'b1;
else
	collision[34]=1'b0;
	
if(x+50>310 && x+50<330 && y>195 && y<235 && blockEn[35]==1'b1) 
	collision[35]=1'b1;
else if(x>310 && x<330 && y>195 && y<235 && blockEn[35]==1'b1)
	collision[35]=1'b1;
else if(x>275 && x<315 && y+50>230 && y+50<250 && blockEn[36]==1'b1)
	collision[35]=1'b1;
else if(x>275 && x<315 && y>230 && y<250 && blockEn[36]==1'b1)
	collision[35]=1'b1;
else
	collision[35]=1'b0;
	
if(x+50>350 && x+50<370 && y>195 && y<235 && blockEn[36]==1'b1) 
	collision[36]=1'b1;
else if(x>350 && x<370 && y>195 && y<235 && blockEn[36]==1'b1)
	collision[36]=1'b1;
else
	collision[36]=1'b0;
	
if(x+50>400 && x+50<420 && y>195 && y<235 && blockEn[37]==1'b1) 
	collision[37]=1'b1;
else if(x>400 && x<420 && y>195 && y<235 && blockEn[37]==1'b1)
	collision[37]=1'b1;
else
	collision[37]=1'b0;
	
if(x+50>450 && x+50<470 && y>195 && y<235 && blockEn[38]==1'b1) 
	collision[38]=1'b1;
else if(x>450 && x<470 && y>195 && y<235 && blockEn[38]==1'b1)
	collision[38]=1'b1;
else
	collision[38]=1'b0;
	
if(x+50>500 && x+50<520 && y>195 && y<235 && blockEn[39]==1'b1) 
	collision[39]=1'b1;
else if(x>500 && x<520 && y>195 && y<235 && blockEn[39]==1'b1)
	collision[39]=1'b1;
else
	collision[39]=1'b0;
	
if(x>275 && x<315 && y+50>120 && y+50<140 && blockEn[40]==1'b1) 
	collision[40]=1'b1;
else if(x>275 && x<315 && y>120 && y<140 && blockEn[40]==1'b1)
	collision[40]=1'b1;
else
	collision[40]=1'b0;
	
if(x>275 && x<315 && y+50>170 && y+50<190 && blockEn[41]==1'b1) 
	collision[41]=1'b1;
else if(x>275 && x<315 && y>170 && y<190 && blockEn[41]==1'b1)
	collision[41]=1'b1;
else
	collision[41]=1'b0;
	
if(x>275 && x<315 && y+50>290 && y+50<310 && blockEn[42]==1'b1) 
	collision[42]=1'b1;
else if(x>275 && x<315 && y>290 && y<310 && blockEn[42]==1'b1)
	collision[42]=1'b1;
else
	collision[42]=1'b0;
	
if(x>275 && x<315 && y+50>340 && y+50<360 && blockEn[43]==1'b1) 
	collision[43]=1'b1;
else if(x>275 && x<315 && y>340 && y<360 && blockEn[43]==1'b1)
	collision[43]=1'b1;
else
	collision[43]=1'b0;
	
	
if(x_ghost+50>x && x_ghost+50<x+50 && y_ghost>y-30 && y_ghost+50<y+80) //right side of ghost touches left side of pacman
	PlayerCollision=1'b1;
else if(x_ghost>x && x_ghost<x+50 && y_ghost>y-30 && y_ghost+50<y+80) //left side of ghost touches right side of pacman
	PlayerCollision=1'b1;
else if(y_ghost>y && y_ghost<y+50 && x_ghost>x-30 && x_ghost+50<x+80) //top of ghost touches bottom of pacman
	PlayerCollision=1'b1;
else if(y_ghost+50>y && y_ghost+50<y+50 && x_ghost>x-30 && x_ghost+50<x+80) //bottom of ghost touches bottom of pacman
	PlayerCollision=1'b1;
else
	PlayerCollision=1'b0;
end
endmodule
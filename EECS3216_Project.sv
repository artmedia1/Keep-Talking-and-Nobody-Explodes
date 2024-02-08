module EECS3216_Project(input MAX10_CLK1_50, input KEY1, output [9:0] LEDR, 
								output [6:0] HEX0, HEX1, HEX2, HEX3, 
								output	rdyLight, speedOneLight, speedTwoLight, speedThreeLight);
enum {rdy, win, lose, speed_one, speed_two, speed_three} State, NextState;

reg [31:0] counter;
reg [31:0] D = 32'd50000000;
integer lightPattern = 0;
integer gameSpeed = 1;
reg pressed = 0;
reg toggle = 1;
reg blink = 1;
	initial begin
		State = rdy;
		NextState = rdy;
		HEX3 <= 7'b1111111;
		HEX2 <= 7'b1111111;
		HEX1 <= 7'b1111111;
		HEX0 <= 7'b1111111;
	end

	always_ff@(posedge MAX10_CLK1_50)begin
		State <= NextState;
		
		

//		case (lightPattern % 10)
//			'd1: HEX1 <= 7'b1111001;
//			'd2: HEX1 <= 7'b0100100;
//			'd3: HEX1 <= 7'b0110000;
//			'd4: HEX1 <= 7'b0011001;
//			'd5: HEX1 <= 7'b0010010;
//			'd6: HEX1 <= 7'b0000010;
//			'd7: HEX1 <= 7'b1111000;
//			'd8: HEX1 <= 7'b0000000;
//			'd9: HEX1 <= 7'b0011000;
//			default: HEX0 <= 7'b1000000; //sets oneSec to 0
//		endcase
		
		pressed <= 0;
		
		if(KEY1)
			toggle <= 1;
		
				
		if(!KEY1 && toggle == 1)begin 
			toggle <= 0;
			if(lightPattern != 4) begin//IDK MY LEDs ARE LIKE ONE DIGIT OFF
				gameSpeed <= 0;			//If the LED is not on SW5, then gameSpeed set to 0
			end
			else begin
				lightPattern <= 0;
				if(State != speed_three)
					blink = 1;
				gameSpeed <= gameSpeed + 1;
			end	
		end	
			
		if(State == rdy) begin
			rdyLight <= 0;
			speedOneLight <= 1;
			speedTwoLight <= 1;
			speedThreeLight <= 1;
			D = 32'd25000000;
	   end
		else if(State == speed_one) begin
			rdyLight <= 1;
			speedOneLight <= 0;
			speedTwoLight <= 1;
			speedThreeLight <= 1;
			D = 32'd50000000;
	   end
		else if(State == speed_two) begin
			rdyLight <= 1;
			speedOneLight <= 1;
			speedTwoLight <= 0;
			speedThreeLight <= 1;
			D = 32'd25000000;
	   end
		else if(State == speed_three) begin
			rdyLight <= 1;
			speedOneLight <= 1;
			speedTwoLight <= 1;
			speedThreeLight <= 0;
			D = 32'd12500000;
	   end
		else if (State == lose) begin //spells lose
			HEX3 <= 7'b1000111;
			HEX2 <= 7'b1000000;
			HEX1 <= 7'b0010010;
			HEX0 <= 7'b0000110;	
		end
		else if (State == win) begin //spells yay
			HEX2 <= 7'b0010001;
			HEX1 <= 7'b0001000;
			HEX0 <= 7'b0010001;	
		end		
		
		
		counter++;
		
		
		
		if(counter >= (D - 1))begin
			counter <= 0;
			
//			case (gameSpeed % 10)
//				'd1: HEX0 <= 7'b1111001;
//				'd2: HEX0 <= 7'b0100100;
//				'd3: HEX0 <= 7'b0110000;
//				'd4: HEX0 <= 7'b0011001;
//				'd5: HEX0 <= 7'b0010010;
//				'd6: HEX0 <= 7'b0000010;
//				'd7: HEX0 <= 7'b1111000;
//				'd8: HEX0 <= 7'b0000000;
//				'd9: HEX0 <= 7'b0011000;
//				default: HEX0 <= 7'b1000000; //sets oneSec to 0
//			endcase
			
			if(State == rdy && blink == 1) begin	
				if(lightPattern < 8) begin		//blinks SW5
					LEDR[5] <= ~LEDR[5];
					lightPattern <= lightPattern + 1;
				end
				else begin
					blink <= 0;
					LEDR[5] <= 0;
					lightPattern <= 9;
				end
			end
			else if (State != lose && State != win) begin //rotates the lights between LEDR 0-9
				
				if (lightPattern == 9) begin
					LEDR[0] <= 0;
					LEDR[9] <= 1;
					lightPattern <= 8;
					end
				else if(lightPattern < 9 && lightPattern > 4) begin
					LEDR[lightPattern + 1] <= 0;
					LEDR[lightPattern] <= 1;
					lightPattern <= lightPattern - 1;
					end
				else if (lightPattern == 4)begin
					LEDR[lightPattern + 1] <= 0;
					LEDR[4] <= 1;
					lightPattern <= lightPattern - 1;
					end
				else if (lightPattern < 4 && lightPattern > 0)begin
					LEDR[lightPattern + 1] <= 0;
					LEDR[lightPattern] <= 1;
					lightPattern <= lightPattern - 1;
					end
				else begin
					LEDR[0] <= 1;
					LEDR[1] <= 0;
					lightPattern <= 9;
					end		
			end
		end
	end
	
	always @(gameSpeed or blink)begin //NextState logic
			
		case (State)
			rdy: begin
					if(blink)
						NextState <= rdy;
					else
						if(gameSpeed == 1)
							NextState <= speed_one;
						else if(gameSpeed == 2)
							NextState <= speed_two;
						else if(gameSpeed == 3)
							NextState <= speed_three;
					end
			speed_one:
					if(gameSpeed == 0)
						NextState <= lose;
					else if(gameSpeed == 2)
						NextState <= rdy;
					else
						NextState <= speed_one;
			speed_two:
					if(gameSpeed == 0)
						NextState <= lose;
					else if (gameSpeed == 3)
						NextState <= rdy;
					else
						NextState <= speed_two;
			speed_three:
					if(gameSpeed == 0)
						NextState <= lose;
					else if (gameSpeed == 4)
						NextState <= win;	
					else NextState <= speed_three;
		endcase
	
	end
	
endmodule 	
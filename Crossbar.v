module Crossbar
(
	clk,
	master_req, master_addr, master_cmd, master_wdata, master_rdata, master_ack,
	slave_ack, slave_addr, slave_rdata, slave_wdata, slave_cmd
);

	input clk;
	input[1:0] master_req;
	input[1:0] master_cmd;
	input[1:0] slave_ack;
	input[31:0] master_addr [1:0];
	input[31:0] master_wdata [1:0];
	input[31:0] slave_rdata [1:0];
	
	output reg[1:0] master_ack;
	output reg[1:0] slave_cmd;
	output reg[31:0] master_rdata[1:0];
	output reg[31:0] slave_addr[1:0];
	output reg[31:0] slave_wdata[1:0];
	
	integer pc = 0;
	integer pc2 = 0;
	integer rr = 0;
	reg[31:0] addr_0;
	reg[31:0] addr_1;
	reg cmd_0;
	reg cmd_1;
	reg[31:0] data_0;
	reg[31:0] data_1;
	reg ack_0;
	reg ack_1;
	reg m;
	reg s;
	
	always @(posedge clk)
	begin
		rr = (rr + 1) % 2;
		case (pc)
			0: begin
				if (master_req[0] == 1 && master_req[1] == 1)
				begin
					if (master_addr[0] == master_addr[1])
					begin
						if (master_addr[0][31] == 0)
							s = 0;
						else if (master_addr[0][31] == 1)
							s = 1;
						if (rr == 0)
						begin
							m = 0;
							addr_0 <= master_addr[0];
							cmd_0 <= master_cmd[0];
							if (master_cmd[0] == 1)
							begin
								data_0 <= master_wdata[0];
								pc2 = 300;
							end
							else
								pc2 = 301;
						end
						else
						begin
							m = 1;
							addr_0 <= master_addr[1];
							cmd_0 <= master_cmd[1];
							if (master_cmd[1] == 1)
							begin
								data_0 <= master_wdata[1];
								pc2 = 300;
							end
							else
								pc2 = 301;
						end
					end
					else begin
						if (master_addr[0][31] == 0)
						begin
							m = 0;
							addr_0 <= master_addr[0];
							cmd_0 <= master_cmd[0];
							if (master_cmd[0] == 1)
								data_0 <= master_wdata[0];
							addr_1 <= master_addr[1];
							cmd_1 <= master_cmd[1];
							if (master_cmd[1] == 1)
								data_1 <= master_wdata[1];
						end
						else
						begin
							m = 1;
							addr_0 <= master_addr[1];
							cmd_0 <= master_cmd[1];
							if (master_cmd[1] == 1)
								data_0 <= master_wdata[1];
							addr_1 <= master_addr[0];
							cmd_1 <= master_cmd[0];
							if (master_cmd[0] == 1)
								data_0 <= master_wdata[0];
						end
						pc2 = 200;
					end
				end
				else if (master_req[0] == 1)
				begin
					m = 0;
					addr_0 <= master_addr[0];
					cmd_0 <= master_cmd[0];
					if (master_addr[0][31] == 0)
						s = 0;
					else if (master_addr[0][31] == 1)
						s = 1;
					if (master_cmd[0] == 1)
					begin
						data_0 <= master_wdata[0];
						pc2 = 100;
					end
					else 
						pc2 = 101;
				end
				else if (master_req[1] == 1)
				begin
					m = 1;
					addr_0 <= master_addr[1];
					cmd_0 <= master_cmd[1];
					if (master_addr[1][31] == 0)
						s = 0;
					else if (master_addr[1][31] == 1)
						s = 1;
					if (master_cmd[1] == 1)
					begin
						data_0 <= master_wdata[1];
						pc2 = 100;
					end
					else 
						pc2 = 101;
				end
			end
			10: begin
				ack_0 <= slave_ack[s];
				if (slave_ack[s] == 1)
				begin
					if (cmd_0 == 1)
					begin
						pc2 = 110;
					end
					else if (cmd_0 == 0)
					begin
						pc2 = 111;
					end
				end	
			end
			11: begin
				master_rdata[m] <= slave_rdata[s];
				pc2 = 0;
			end
			20: begin
				ack_0 <= slave_ack[0];
				ack_1 <= slave_ack[1];
				if (slave_ack[0] == 1 && slave_ack[1] == 1)
					if (cmd_0 == 1 && cmd_1 == 1)
						pc2 = 220;
					else if (cmd_0 == 1 && cmd_1 == 0)
						pc2 = 221;
					else if (cmd_0 == 0 && cmd_1 == 1)
						pc2 = 222;
					else if (cmd_0 == 0 && cmd_1 == 0)
						pc2 = 223;
			end
			21: begin
				if (m == 0)
					master_rdata[1] <= slave_rdata[1];
				else
					master_rdata[0] <= slave_rdata[1];
				pc2 = 0;
			end
			22: begin
				if (m == 0)
					master_rdata[0] <= slave_rdata[0];
				else
					master_rdata[1] <= slave_rdata[0];
				pc2 = 0;
			end
			23: begin
				if (m == 0)
				begin
					master_rdata[0] <= slave_rdata[0];
					master_rdata[1] <= slave_rdata[1];
				end
				else
				begin
					master_rdata[0] <= slave_rdata[1];
					master_rdata[1] <= slave_rdata[0];
				end
				pc2 = 0;
			end
			30: begin
				ack_0 <= slave_ack[s];
				if (slave_ack[s] == 1)
				begin
					if (cmd_0 == 1)
					begin
						pc2 = 310;
					end
					else if (cmd_0 == 0)
					begin
						pc2 = 311;
					end
				end
			end
			31: begin
				master_rdata[m] <= slave_rdata[s];
				//m = (m + 1) % 2;
				pc2 = 32;
			end
			32: begin
				m = (m + 1) % 2;
				addr_0 <= master_addr[m];
				cmd_0 <= master_cmd[m];
				if (master_cmd[m] == 1)
				begin
					data_0 <= master_wdata[m];
					pc2 = 320;
				end
				else
					pc2 = 321;
			end
			33: begin
				ack_0 <= slave_ack[s];
				if (slave_ack[s] == 1)
				begin
					if (cmd_0 == 1)
					begin
						pc2 = 330;
					end
					else if (cmd_0 == 0)
					begin
						pc2 = 331;
					end
				end
			end
			34: begin
				master_rdata[m] <= slave_rdata[s];
				pc2 = 0;
			end
		endcase
	end
	
	always @(negedge clk)
	begin
		case (pc2)
			100: begin
				slave_addr[s] <= addr_0;
				slave_cmd[s] <= cmd_0;
				slave_wdata[s] <= data_0;
				pc = 10;
			end
			101: begin
				slave_addr[s] <= addr_0;
				slave_cmd[s] <= cmd_0;
				pc = 10;
			end
			110: begin
				master_ack[m] <= ack_0;
				pc = 0;
			end
			111: begin
				master_ack[m] <= ack_0;
				pc = 11;
			end
			200: begin
				slave_addr[0] <= addr_0;
				slave_cmd[0] <= cmd_0;
				if (cmd_0 == 1)
					slave_wdata[0] <= data_0;
				slave_addr[1] <= addr_1;
				slave_cmd[1] <= cmd_1;
				if (cmd_1 == 1)
					slave_wdata[1] <= data_1;
				pc = 20;
			end
			220: begin
				if (m == 0)
				begin
					master_ack[0] <= slave_ack[0];
					master_ack[1] <= slave_ack[1]; 
				end
				else
				begin
					master_ack[0] <= slave_ack[1];
					master_ack[1] <= slave_ack[0];
				end
				pc = 0;
			end
			221: begin
				if (m == 0)
				begin
					master_ack[0] <= slave_ack[0];
					master_ack[1] <= slave_ack[1];
				end
				else
				begin
					master_ack[0] <= slave_ack[1];
					master_ack[1] <= slave_ack[0];
				end
				pc = 21;
			end
			222: begin
				if (m == 0)
				begin
					master_ack[0] <= slave_ack[0];
					master_ack[1] <= slave_ack[1];
				end
				else
				begin
					master_ack[0] <= slave_ack[1];
					master_ack[1] <= slave_ack[0];
				end
				pc = 22;
			end
			223: begin
				if (m == 0)
				begin
					master_ack[0] <= slave_ack[0];
					master_ack[1] <= slave_ack[1];
				end
				else
				begin
					master_ack[0] <= slave_ack[1];
					master_ack[1] <= slave_ack[0];
				end
				pc = 23;
			end
			300: begin
				slave_addr[s] <= addr_0;
				slave_cmd[s] <= cmd_0;
				slave_wdata[s] <= data_0;
				pc = 30;
			end
			301: begin
				slave_addr[s] <= addr_0;
				slave_cmd[s] <= cmd_0;
				pc = 30;
			end
			310: begin
				master_ack[m] <= ack_0;
				//m = (m + 1) % 2;
				pc = 32;
			end
			311: begin
				master_ack[m] <= ack_0;
				pc = 31;
			end
			320: begin
				slave_addr[s] <= addr_0;
				slave_cmd[s] <= cmd_0;
				slave_wdata[s] <= data_0;
				pc = 33;
			end
			321: begin
				slave_addr[s] <= addr_0;
				slave_cmd[s] <= cmd_0;
				pc = 33;
			end
			330: begin
				master_ack[m] <= ack_0;
				pc = 0;
			end
			331: begin
				master_ack[m] <= ack_0;
				pc = 34;
			end
		endcase
	end
	
endmodule
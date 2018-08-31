module Crossbar
(
	clk,
	master_req, master_addr, master_cmd, master_wdata, master_rdata, master_ack,
	slave_ack, slave_addr, slave_wdata, slave_rdata, slave_cmd
);
	
	parameter count = 2;

	input clk;
	input master_req [count - 1:0];
	input master_cmd [count - 1:0];
	input slave_ack [count - 1:0];
	input[31:0] master_addr [count - 1:0];
	input[31:0] master_wdata [count - 1:0];
	input[31:0] slave_rdata [count - 1:0];
	
	output reg master_ack [count - 1:0];
	output reg slave_cmd [count - 1:0];
	output reg[31:0] slave_addr[count - 1:0];
	output reg[31:0] master_rdata [count - 1:0];
	output reg[31:0] slave_wdata [count - 1:0];
	
	integer i;
	integer t, n;
	integer rr = 0;
	integer state[count - 1:0];
	
	reg busy[count - 1:0];
	
	initial
	begin
		for (i = 0; i < count; i = i + 1)
		begin
			state[i] = 0;
			busy[i] = 0;
		end
	end
	
	always @(posedge clk)
	begin
		rr = (rr + 1) % count;
		for (i = 0; i < count; i = i + 1)
		begin
			t = (rr + i) % count;
			n = master_addr[t][31:32 - $clog2(count)];
			case (state[t])
				0: begin
					if (master_req[t] == 1)
					begin
						if (busy[n] == 0)
						begin
							busy[n] = 1;
							slave_addr[n] <= master_addr[t];
							slave_cmd[n] <= master_cmd[t];
							if (master_cmd[t] == 1)
							begin
								slave_wdata[n] <= master_wdata[t];
								state[t] = 2;
							end
							else
								state[t] = 3;
						end
						else
							state[t] = 1;
					end
				end
				1: begin
					if (busy[n] == 0)
					begin
						busy[n] = 1;
						slave_addr[n] <= master_addr[t];
						slave_cmd[n] <= master_cmd[t];
						if (master_cmd[t] == 1)
						begin
							slave_wdata[n] <= master_wdata[t];
							state[t] = 2;
						end
						else
							state[t] = 3;
					end
				end
				2: begin
					if (slave_ack[n] == 1)
					begin
						master_ack[t] <= slave_ack[n];
						state[t] = 0;
						busy[n] = 0;
					end
				end
				3: begin
					if (slave_ack[n] == 1)
					begin
						master_ack[t] <= slave_ack[n];
						state[t] = 4;
					end
				end
				4: begin
					master_rdata[t] <= slave_rdata[n];
					state[t] = 0;
					busy[n] = 0;
				end
			endcase
		end
	end
	
	
endmodule
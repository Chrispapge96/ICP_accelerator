----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/28/2022 08:24:25 PM
-- Design Name: 
-- Module Name: Controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controller is
  port(
  		clk:		in  std_logic;
  		rst:		in  std_logic;
		IN_read : 	in  std_logic;
		IN_load: 	in  std_logic;
		IN_matrix:	in  std_logic_vector(3 downto 0);
		web: 		out std_logic_vector(1 downto 0);
		addr_ram:	out std_logic_vector(7 downto 0);
		cnt_enable: out std_logic;
		addr_In:	out std_logic_vector(3 downto 0);
		addr_rom:	out std_logic_vector(3 downto 0);
		cnt:		out std_logic_vector(5 downto 0);
		rst_sumReg:	out std_logic;
		load_enable: out std_logic

		);

end Controller;

architecture Behavioral of Controller is
 
	type state_of_operation is (IDLE,OP,LOAD,SAVE,LINE_UPDATE,FINISHED);
	signal state_cur, state_next: 		state_of_operation;

	signal addr_in,addr_in_n:		std_logic_vector(3 downto 0);
	signal addr_ram_r_n,addr_ram_r,addr_ram_w_n,addr_ram_w :	std_logic_vector(7 downto 0);
	signal cnt_r,cnt_n : 				std_logic_vector(5 downto 0);


	begin

	seq: process(clk,rst,state_next,loading_next) is begin
		if rising_edge(clk) then
			if rst = '1' then
				state_cur<=IDLE;
				--loading_cur<=WAIT_LOAD;
				cnt_r<=(others=>'0');
				addr_ram_r<=addr_ram_r_n;
				addr_ram_w<=addr_ram_w_n;
			else
				state_cur<=state_next;
				loading_cur<=loading_next;
				cnt_r<=cnt_n;
				addr_ram_r<=addr_ram_r_n;
				addr_ram_w<=addr_ram_w_n;
				-- goes to MAC unit sumReg_c<=sumReg_n;
			end if;
		end if;
	end process;

	RAM_MUX: process(addr_ram_r,addr_ram_w,web) is begin
		if web(1)='0' then
			addr_ram<=addr_ram_r;
		else
			addr_ram<=addr_ram_w;
		end if;
	end process;

	Rotation_of_states: process() is begin
		if state_cur=IDLE then
			if IN_read='1' then
					state_next<=READ;
			else
				if IN_load='1' then
					state_next<=LOAD;
				end if;
			end if;
		elsif state_cur=READ then
			if cnt_r="1111" then
				state_next<=IDLE;
			else
				state_next<=state_cur;
			end if;
		elsif state_cur=LOAD then
			state_next<=OP;
		elsif state_cur=OP then
			if cnt_r(1 downto 0)="11" then
				if cnt_n(3 downto 0)="1111" then
					state_next<=SAVE;
				else
					state_next<=LINE_UPDATE;
				end if;
			else
				state_next<=state_cur;
			end if;
		elsif state_cur=LINE_UPDATE then
			state_next<=OP;
		elsif state_cur=SAVE then
			if cnt_r=63 then
				state_next<=FINISHED;
			else
				state_next<=OP;
			end if;
		elsif state_cur=FINISHED then
			state_next<=IDLE;
		end if;
	end process;


	Operation_of_each_state: process(state_cur,loading_cur,addr_ram_r) is begin
	rst_sumReg<='0';
	addr_in_n<=addr_in;
		case state_cur is
			when IDLE =>
			  load_enable<='0';
				cnt_n<=(others=>'0');
				addr_in<="0000";
				addr_rom<="0000";
				web<="00";
				-- goes to MAC unit sumReg_n<=(others=>'0'); 
				addr_ram_r_n <= IN_matrix & "0000";
				finished<='0';
			when READ =>
				addr_ram_r_n<=addr_ram_r + '1';
				cnt_n<=cnt_r+1;
				web<="01";
			when LOAD =>
				load_enable<=1;
			when OP =>
				load_enable<=0;
				cnt_n<=cnt_r+1;
				web<="00";
			  addr_in_n<=addr_in + '1';

			when LINE_UPDATE =>
			 	web<="10"
			 	addr_ram_w_n<=addr_ram_w + '1';
			 	rst_sumReg<='1';
			 	addr_IN<=addr_in -"100"; --------------------------- ROW reseting (I dont know if it works)

			when SAVE =>
			 	web<="10"
			 	addr_in_n<=addr_in + '1';
				addr_ram_w_n<=addr_ram_w + '1';
			 	rst_sumReg<='1';
			when FINISHED =>
			 	finished<='1';
		end case;
	end process;

	addr_rom<=cnt_r(3 downto 0);
	addr_In<=addr_in;








end Behavioral;

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
		finished:   out std_logic;
		web         : out std_logic_vector(1 downto 0);
		addr_ram:	out std_logic_vector(7 downto 0);
		addr_in:	out std_logic_vector(3 downto 0);
		addr_rom:	out std_logic_vector(3 downto 0);
		rst_sumReg:	out std_logic
		);

end Controller;

architecture Behavioral of Controller is
 
	type state_of_operation is (IDLE,OP,LOAD,SAVE,LINE_UPDATE,FINISH, READ);
	type state_of_loading is (WAIT_LOAD,FETCH);
	
	
	signal addr_ram_w  : std_logic_vector(7 downto 0);
	signal addr_ram_r  : std_logic_vector(7 downto 0);
	signal cnt_enable  : std_logic;
	
	signal state_cur, state_next: 		state_of_operation;
	signal loading_cur,loading_next : 	state_of_loading;

	signal sumReg_c,sumReg_n : 			std_logic_vector(15 downto 0);	
	signal cnt_r,cnt_n : 				std_logic_vector(5 downto 0);


	begin

	seq: process(clk,rst,state_next,loading_next) is begin
		if rising_edge(clk) then
			if rst = '1' then
				state_cur<=IDlE;
				loading_cur<=WAIT_LOAD;
			else
				state_cur<=state_next;
				loading_cur<=loading_next;
				-- goes to MAC unit sumReg_c<=sumReg_n;
			end if;
		end if;
	end process;


	Operation_of_each_state: process(IN_matrix) is begin
	state_next<=state_cur;
	loading_next<=loading_cur;
		case state_cur is
			when IDLE =>
				rst_sumReg<='1';
				-- goes to Input unit input_reg_next(255 downto 0)<=(others=>'0');
				cnt_n<= (others => '0');
				addr_in<="0000";
				addr_rom<="0000";
				web<="00";
				-- goes to MAC unit sumReg_n<=(others=>'0'); 
				addr_ram_r <= IN_matrix & "0000";
				finished <= '0';
				if IN_read='1' then
					state_next<= READ;
				else
					state_next<=state_cur;
					if IN_load='1' then
					state_next<=LOAD;
					end if;
				end if;
			 when others =>
								
		end case;
	end process;

end Behavioral;

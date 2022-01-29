----------------------------------------------------------------------------------
-- Company: GROUP 7
-- Engineer: ALEC GUERIN & CHRISTOS PAPADOPOULOS
-- 
-- Create Date: 01/28/2022 07:07:07 PM
-- Design Name: 
-- Module Name: TOP_Accelerator - Structural
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TOP_Accelerator is
--  Port ( );
end TOP_Accelerator;

architecture Structural of TOP_Accelerator is

component Controller is
	port(
		clk:		in std_logic;
		rst:		in std_logic;
		IN_read : 	in std_logic;
		IN_load: 	in std_logic;
		web: 		out std_logic_vector(1 downto 0);
		addr_ram_w:	out std_logic_vector(7 downto 0);
		addr_ram_r:	out std_logic_vector(7 downto 0);
		cnt_enable: out std_logic;
		addr_in:	out std_logic_vector(3 downto 0);
		addr_rom:	out std_logic_vector(3 downto 0);
		cnt:		out std_logic_vector(5 downto 0);

		)

begin


end Structural;

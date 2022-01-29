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
	Port (
		clk        : in  std_logic;                       -- Clock signal
		reset      : in  std_logic;                       -- Reset signal
		IN_read    : in  std_logic;                       -- Read signal
		IN_load    : in  std_logic;                       -- Start loading data signal
		IN_data_in : in  std_logic_vector(255 downto 0);   -- Input data to set
		IN_matrix_sel : in std_logic_vector(3 downto 0);  -- Result matrix index
		OUT_data_out : out std_logic_vector(15 downto 0);  -- Output data
		finish     : out std_logic
	);
end TOP_Accelerator;

architecture Structural of TOP_Accelerator is

---- COMPONENT ----

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
		cnt:		out std_logic_vector(5 downto 0)
		);
end component;

---- SIGNAL DEFINITIONS --


begin
	OUT_data_out <= (others => '0');
	finish <= '0';

end Structural;

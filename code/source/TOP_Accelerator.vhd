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
		rst      : in  std_logic;                       -- Reset signal
		IN_read    : in  std_logic;                       -- Read signal
		IN_load    : in  std_logic;                       -- Start loading data signal
		IN_data_in : in  std_logic_vector(255 downto 0);   -- Input data to set
		IN_matrix : in std_logic_vector(3 downto 0);  -- Result matrix index
		OUT_data_out : out std_logic_vector(15 downto 0);  -- Output data
		finish     : out std_logic
	);
end TOP_Accelerator;

architecture Structural of TOP_Accelerator is

---- COMPONENT ----

component Controller is
	port(
            clk           :	in std_logic;
            rst           :	in std_logic;
            IN_read       : in std_logic;
            IN_load       : in std_logic;
            IN_matrix     :	in  std_logic_vector(3 downto 0);
            web           : out std_logic_vector(1 downto 0);
            addr_ram      :	out std_logic_vector(7 downto 0);
            addr_In       :	out std_logic_vector(3 downto 0);
            addr_rom      :	out std_logic_vector(3 downto 0);
            rst_sumReg    :	out std_logic;
            load_enable   : out std_logic;
            finish        : out std_logic
            
		);
end component;

component ROM is
     Port ( 
            clk         : in std_logic;
            enable_ROM  : in std_logic;
            addr_ROM    : in std_logic_vector (3 downto 0); 
            dataROM     : out std_logic_vector (11 downto 0)
        );
end component;

---- SIGNAL DEFINITIONS --
signal web: std_logic_vector(1 downto 0);
signal addr_ram: std_logic_vector(7 downto 0);
signal	addr_In: std_logic_vector(3 downto 0);
signal	addr_rom: std_logic_vector(3 downto 0);
signal	rst_sumReg: std_logic;
signal  load_enable: std_logic;
signal  enable_ROM: std_logic;
signal  dataROM:    std_logic_vector(11 downto 0);


begin
--	OUT_data_out <= (others => '0');
--	finish <= '0';
    enable_ROM<='1'; -- Not sure if we need this, but to be sure i have it prepared
	
	contr: Controller
	port map (
            clk=>clk,
            rst=>rst,
            IN_load=>IN_load,
            IN_read=>IN_read,
            IN_matrix=>IN_matrix,
            web=>web,
            addr_ram=>addr_ram,
            addr_In=>addr_In,
            addr_rom=>addr_rom,
            rst_sumReg=>rst_sumReg,
            load_enable=>load_enable,
            finish=>finish
	);
	
	 rom_mem: ROM
	 port map (
             clk=>clk,
             enable_ROM=>enable_ROM,
             addr_ROM=>addr_rom,
             dataROM=>dataROM	 
	 );
	

end Structural;

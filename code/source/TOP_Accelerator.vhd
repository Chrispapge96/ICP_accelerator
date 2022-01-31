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
		OUT_data_out : out std_logic_vector(16 downto 0);  -- Output data
		finish     : out std_logic
	);
end TOP_Accelerator;

architecture Structural of TOP_Accelerator is
---- CONSTANTS ----

---- COMPONENT ----
component Controller is port(
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
end component;

component MAC is port(
	clk         : in std_logic; -- Clock signal
	reset       : in std_logic; -- Reset signal
	init_mac    : in std_logic; -- Reset the accumulation
	dataROM     : in std_logic_vector (13 downto 0);    -- 2 7bits words from ROM
	in_data     : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
	dataRAM     : out std_logic_vector (16 downto 0)    -- 16bit result
	);
end component;

component Input_Matrix is
generic(WORD_LENGTH : integer := 16);
port(
	clk         : in std_logic;
	rst         : in std_logic;
	load_enable : in std_logic;
	IN_data     : in std_logic_vector(255 downto 0);        
	addr_in     : in std_logic_vector (3 downto 0);
	data        : out std_logic_vector (15 downto 0)
);
end component;
---- SIGNAL DEFINITIONS --

signal load_enable	: std_logic;
signal rst_sumReg	: std_logic;
signal web          : std_logic_vector(1 downto 0);
signal addr_in 		: std_logic_vector(3 downto 0);
signal addr_rom		: std_logic_vector(3 downto 0);
signal addr_ram		: std_logic_vector(7 downto 0);
signal data_in		: std_logic_vector(15 downto 0);
signal data_rom		: std_logic_vector(13 downto 0);
signal data_ram		: std_logic_vector(16 downto 0);

signal finished		: std_logic;
signal data_out		: std_logic_vector(16 downto 0);


begin
	-- Setup the controller
	controller_inst: Controller port map(
		clk			=> clk,
		rst			=> reset,
		IN_read		=> in_read,
		IN_load		=> in_load,
		IN_matrix   => IN_matrix_sel,
		finished	=> finished,
		web         => web,
		addr_ram	=> addr_ram,
		addr_in		=> addr_in,
		addr_rom	=> addr_rom,
		rst_sumReg	=> rst_sumReg
	);
	-- Setup the MAC
	mac_inst: MAC port map(
		clk			=> clk,
		reset		=> reset,
		init_mac	=> rst_sumReg,
		dataROM		=> data_rom,
		in_data		=> data_in,
		dataRAM		=> data_ram
	);
	-- Setup the input registers
	input_matrix_inst: Input_Matrix port map(
		clk			=> clk,
		rst			=> reset,
		load_enable	=> load_enable,
		IN_data		=> IN_data_in,
		addr_in		=> addr_in,
		data		=> data_in
	);
end Structural;


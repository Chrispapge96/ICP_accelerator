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
		OUT_data_out : out std_logic_vector(31 downto 0);  -- Output data
		finish     : out std_logic;
		test_out  :   out std_logic_vector(31 downto 0)
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
            RAM_part      : out std_logic;
            W_on 					:	out std_logic;
            enable_MAC		:	out std_logic;
            finish        : out std_logic
            
		);
end component;

component MAC is port(
	clk         : in std_logic; -- Clock signal
	rst         : in std_logic; -- Reset signal
	init_mac    : in std_logic; -- Reset the accumulation
	RAM_part		: in std_logic;
	W_on 				: in std_logic;
	enable			:	in std_logic;
	dataROM     : in std_logic_vector (11 downto 0);    -- 2 7bits words from ROM
	in_data     : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
	dataRAM     : out std_logic_vector (31 downto 0)    -- 16bit result
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

component ROM is
     Port ( 
            clk         : in std_logic;
            enable_ROM  : in std_logic;
            addr_ROM    : in std_logic_vector (3 downto 0); 
            dataROM     : out std_logic_vector (11 downto 0)
        );
end component;


component SRAM_SP_WRAPPER is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (7 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (31 downto 0);
    DataxDO : out std_logic_vector (31 downto 0)
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
signal  data_in:    std_logic_vector(15 downto 0);
signal  dataRAM:    std_logic_vector(31 downto 0);
signal  ready:      std_logic;
signal  RAM_part:   std_logic;
signal	W_on:				std_logic;
signal	enable_MAC:			std_logic;
signal  finito:         std_logic ;

begin
--	OUT_data_out <= (others => '0');
--	finish <= '0';
    enable_ROM<='1'; -- Not sure if we need this, but to be sure i have it prepared
	finish<=finito;
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
            RAM_part=>RAM_part,
            enable_MAC=>enable_MAC,
            W_on=>W_on,
            finish=>finito
	);
	
	 rom_mem: ROM
	 port map (
             clk=>clk,
             enable_ROM=>enable_ROM,
             addr_ROM=>addr_rom,
             dataROM=>dataROM	 
	 );
	 
	 	-- Setup the MAC
	mac_inst: MAC port map(
		clk			=> clk,
		rst		    => rst,
		init_mac	=> rst_sumReg,
		RAM_part	=> RAM_part,
		W_on 			=> W_on,
		dataROM		=> dataROM,
		enable		=>enable_MAC,
		in_data		=> data_in,
		dataRAM		=> dataRAM
	);
	-- Setup the input registers
	input_matrix_inst: Input_Matrix port map(
		clk			=> clk,
		rst			=> rst,
		load_enable	=> load_enable,
		IN_data		=> IN_data_in,
		addr_in		=> addr_in,
		data		=> data_in
	);
	
    RAM              : SRAM_SP_WRAPPER 
  port map (
        ClkxCI      =>clk,
        CSxSI       =>web(0),
        WExSI       =>web(1),            --Active Low
        AddrxDI     =>addr_ram,
        RYxSO       =>ready,
        DataxDI     =>dataRAM,
        DataxDO     =>OUT_data_out
    );	   
	   
	   test_out<=dataRAM;
end Structural;
	


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
					IN_data_in : in  std_logic_vector(7 downto 0);   -- Input data to set
					IN_matrix : in std_logic_vector(3 downto 0);  -- Result matrix index
					OUT_data_out : out std_logic_vector(8 downto 0);  -- Output data
					finish     : out std_logic
				);
end TOP_Accelerator;

architecture Structural of TOP_Accelerator is

	---- COMPONENT ----

	component Controller is
			Port (
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
	          option 				: out std_logic_vector(1 downto 0);
	          load_enable   : out std_logic;
	          
	          en_diag 			: out std_logic;
	          enable_MAC		:	out std_logic;
	          finish        : out std_logic
	            
					);
	end component;

	component MAC is 
			Port (
						clk         : in std_logic; -- Clock signal
						rst         : in std_logic; -- Reset signal
						init_mac    : in std_logic; -- Reset the accumulation
					
						en_diag			:	in std_logic;
						option 			:	in std_logic_vector(1 downto 0);
						enable			:	in std_logic;
						dataROM     : in std_logic_vector (11 downto 0);    -- 2 7bits words from ROM
						in_data_mac : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
						dataRAM     : out std_logic_vector (31 downto 0)    -- 16bit result
					);
	end component;

	component Input_Matrix is
	generic(WORD_LENGTH : integer := 16);
			Port (
						clk         : in std_logic;
						rst         : in std_logic;
						load_enable : in std_logic;
						IN_data     : in std_logic_vector(7 downto 0);        
						addr_in     : in std_logic_vector (3 downto 0);
						data        : out std_logic_vector (15 downto 0)
					);
	end component;

	component ROM is
	     Port ( 
	         
	          enable_ROM  : in std_logic;
	          addr_ROM    : in std_logic_vector (3 downto 0); 
	          dataROM     : out std_logic_vector (11 downto 0)
	        );
	end component;

	component ST_SPHDL_160x32m8_L is
    PORT (
        Q : OUT std_logic_vector(31 DOWNTO 0);
        RY : OUT std_logic;
        CK : IN std_logic;
        CSN : IN std_logic;
        TBYPASS : IN std_logic;
        WEN : IN std_logic;
        A : IN std_logic_vector(7 DOWNTO 0);
        D : IN std_logic_vector(31 DOWNTO 0)   
) ;    
END component;




	---- SIGNAL DEFINITIONS --
	signal  web: 					std_logic_vector(1 downto 0);
	signal  addr_ram: 			std_logic_vector(7 downto 0);
	signal	addr_In: 			std_logic_vector(3 downto 0);
	signal	addr_rom:			std_logic_vector(3 downto 0);
	signal	rst_sumReg: 	std_logic;
	signal  enable_ROM: 	std_logic;
	signal  dataROM:    	std_logic_vector(11 downto 0);
	signal	data_to_MAC:  std_logic_vector(15 downto 0);
	signal  dataRAM:    	std_logic_vector(31 downto 0);
	signal  ready:      	std_logic;
	
	signal	option:				std_logic_vector(1 downto 0);
	signal	enable_MAC:		std_logic;
	signal  en_diag:			std_logic;
	signal  finito:     	std_logic;
	signal  load_en:    	std_logic;
	signal  outRAM: 			std_logic_vector(31 downto 0);
	signal LOW  : std_logic;

	begin

			LOW  <= '0';

	--	OUT_data_out <= (others => '0');
	--	finish <= '0
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
	            load_enable=>load_en,
	            
	            option=>option,
	            en_diag=>en_diag,
	            enable_MAC=>enable_MAC,
	            finish=>finito
		);
		
		 rom_mem: ROM
		 port map (
	             enable_ROM=>enable_ROM,
	             addr_ROM=>addr_rom,
	             dataROM=>dataROM	 
		 );
		 
		 	-- Setup the MAC
		mac_inst: MAC port map(
							clk			=> clk,
							rst		    => rst,
							init_mac	=> rst_sumReg,
							
							dataROM		=> dataROM,
							en_diag   => en_diag,
							enable		=>enable_MAC,
							option    =>option,
							in_data_mac		=> data_to_MAC,
							dataRAM		=> dataRAM
		);
		-- Setup the input registers
		input_matrix_inst: Input_Matrix port map(
							clk			=> clk,
							rst			=> rst,
							load_enable	=> load_en,
							IN_data		=> IN_data_in,
							addr_in		=> addr_in,
							data		=> data_to_MAC
		);
		
	    RAM              : ST_SPHDL_160x32m8_L 
	  port map (
			        CK     =>clk,
			        CSN       =>web(0),
			        WEN       =>web(1),            --Active Low
			        A     =>addr_ram,
			        TBYPASS => LOW,
			        RY      =>ready,
			        D     =>dataRAM,
			        Q     =>outRAM
	    );	   


	  ------------------------------------------------------------------------------
	  -- -- Logic behind choosing the correct bits of the RAM for output
	  ------------------------------------------------------------------------------

	  	out_logic: process(addr_rom,outRAM) is begin
	  		if addr_rom(0)='0' then
	  			OUT_data_out<=outRAM(8 downto 0);
	  		else
	  			OUT_data_out<=outRAM(17 downto 9);
	  		end if;
	  	end process;
	--------------------------------------------------------------------------------

		   
		   
end Structural;
	


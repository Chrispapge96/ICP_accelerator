library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;


library STD;
use STD.textio.all;

entity TB_Controller is

end TB_Controller;

architecture Structural of TB_Controller is
	-----------------------------------------------------------------------------
	--SIGNALS
	-----------------------------------------------------------------------------
	signal clk: 				std_logic :='0';
	signal rst: 				std_logic;
	signal IN_read: 			std_logic:='0';
	signal IN_load: 			std_logic:='0';
	signal IN_matrix: 			std_logic_vector(3 downto 0):="0000";
	signal stimulus_data:		std_logic_vector(255  downto 0):=(others=>'0');
    signal IN_data:   			std_logic_vector(15 downto 0):=(others=>'0');
	signal Out_data:   			std_logic_vector(31 downto 0);
	signal finito:     			std_logic:='0';
	signal load_en,load_en_n:			std_logic:='0';
	signal tb_cnt_r,tb_cnt_n:	integer:=0;

    signal outwrite0,outwrite1                           : integer:= 0;

--------------------------------------------------------------------------------
--/*--controller signals
--	signal web: std_logic_vector(1 downto 0);
--	signal addr_ram: std_logic_vector(7 downto 0);
--	signal addr_rom: std_logic_vector(3 downto 0);
--	signal addr_In: std_logic_vector(3 downto 0);
--	signal rst_sumReg: std_logic;
--	signal RAM_part: std_logic;
--	signal en_diag: std_logic;
--	signal enable_MAC: std_logic;
--    signal option: std_logic ;*/
--------------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	--COMPONENTS
	-----------------------------------------------------------------------------
	
	component TOP_Accelerator is
		port(
		clk        : in  	std_logic;                       -- Clock signal
		rst      : in  		std_logic;                       -- Reset signal
		IN_read    : in  	std_logic;                       -- Read signal
		IN_load    : in  	std_logic;                       -- Start loading data signal
		IN_data_in : in  	std_logic_vector(15 downto 0);   -- Input data to set
		IN_matrix : in 		std_logic_vector(3 downto 0);  -- Result matrix index
		OUT_data_out : out 	std_logic_vector(31 downto 0);  -- Output data
		finish     : out 	std_logic
		
			);
	end component;
---------------------------------------------------------------------------------

    constant Count: integer := 31;

begin
--------------------------------------------------------------------------------
	-- Instantiate the components
--------------------------------------------------------------------------------

   
        
		top_ac: TOP_Accelerator
	port map (
		clk=>clk,
		rst=>rst,
		IN_load=>IN_load,
		IN_read=>IN_read,
		IN_matrix=>IN_matrix,
	   IN_data_in=>IN_data,
	   OUT_data_out=>Out_data,
	   finish=>finito
	   
	);
 -----------------------------------------------------------------------------
 -- CLK simulation period 10 ns	
 -----------------------------------------------------------------------------
     rst <= '1', '0' after 15 ns;
     clk <= not clk after 5 ns;
   -----------------------------------------------------------------------------  

     stimulus: process
     
      
      file Fin: TEXT open READ_MODE is "C:\Users\Xristos\Documents\GitHub\ICP_accelerator\code\simulation\input_stimuli.txt";
	-----------------------------------------------------------------------------
	--VARIABLES for reading
	-----------------------------------------------------------------------------

	variable read_line_cur : line;
	variable read_field_cur: std_logic_vector(7 downto 0);
	variable x:    integer := 0;
    variable mat:	std_logic_vector(3 downto 0):= "0000"; 
      begin
     	  	

        while (not endfile(Fin)) loop
            for I in 0 to Count loop
                readline(Fin,read_line_cur );
                read(read_line_cur,read_field_cur);
                stimulus_data((7+8*I) downto I*8)<=read_field_cur;
            end loop;   
            

	        if x=0 then
                wait until rst='0';
                x:=1;
            end if;

            IN_read<='0';
            IN_load<='1';
          	IN_matrix<=mat;

            wait for 10ns;
          
            IN_load<='0';
            
            wait for 660ns;
             
             IN_read<='1';
            wait for 20ns;
            IN_read<='0'; 
          	wait for 380ns;
   			mat:=mat+1;
        end loop;
       
     end process;

     
       seq: process(clk,rst) is 
       		file Fout: TEXT open WRITE_MODE is "C:\Users\Xristos\Documents\GitHub\ICP_accelerator\code\simulation\output.txt";
  			variable write_line_cur: line;
            --variable tb_cnt: integer := 0;

  			begin
  			if rising_edge(clk) then
  				if rst='1' then
  				tb_cnt_r<=0;
  				load_en<='0';
  				else
  				tb_cnt_r<=tb_cnt_n;
  				
  				load_en<=load_en_n;
  				end if;
                if outwrite0 > 0 then
                  write(write_line_cur,string'("MAC0: "));
                  write(write_line_cur,outwrite0,right,10);
                  writeline(Fout,write_line_cur);
                  write(write_line_cur,string'("MAC1: "));
                  write(write_line_cur,outwrite1,right,10);
                  writeline(Fout,write_line_cur);
                end if;
	        end if;
			end process;

			comb:process(load_en,tb_cnt_r,stimulus_data,IN_load,load_en) is begin
				load_en_n<=load_en;
				if IN_load='1' and tb_cnt_r=0 then
					load_en_n<='1';
				elsif tb_cnt_r=15 then
					load_en_n<='0';
				end if;

				if load_en='1' then
	                    tb_cnt_n<=tb_cnt_r+1;
	                    
	                    IN_data<=stimulus_data((15+16*(tb_cnt_r)) downto ((tb_cnt_r)*16));
	                else
	                	tb_cnt_n<=0;
	                end if;
			end process;
			  
---------------------------------------------------------------------------------changing input during load	   		
			outwrite0<=to_integer(unsigned(Out_data(15 downto 0)));
   			outwrite1<=to_integer(unsigned(Out_data(31 downto 16)));


   
end Structural;

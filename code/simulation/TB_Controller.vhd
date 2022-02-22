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
	signal clk: std_logic :='0';
	signal rst: std_logic;
	signal IN_read: std_logic:='0';
	signal IN_load: std_logic:='0';
	signal IN_matrix: std_logic_vector(3 downto 0):="0000";
    signal IN_data:   std_logic_vector(255 downto 0):=(others=>'0');
	signal Out_data:   std_logic_vector(31 downto 0);
	signal finito:     std_logic:='0';
	signal outRAM:     std_logic_vector(31 downto 0);
    
	-----------------------------------------------------------------------------
	--COMPONENTS
	-----------------------------------------------------------------------------
	
	component TOP_Accelerator is
		port(
		clk        : in  std_logic;                       -- Clock signal
		rst      : in  std_logic;                       -- Reset signal
		IN_read    : in  std_logic;                       -- Read signal
		IN_load    : in  std_logic;                       -- Start loading data signal
		IN_data_in : in  std_logic_vector(255 downto 0);   -- Input data to set
		IN_matrix : in std_logic_vector(3 downto 0);  -- Result matrix index
		OUT_data_out : out std_logic_vector(31 downto 0);  -- Output data
		finish     : out std_logic;
		test_out : out std_logic_vector(31 downto 0)

			);
	end component;

    constant Count: integer := 31;

begin
    

        
		top_ac: TOP_Accelerator
	port map (
		clk=>clk,
		rst=>rst,
		IN_load=>IN_load,
		IN_read=>IN_read,
		IN_matrix=>IN_matrix,
	   IN_data_in=>IN_data,
	   OUT_data_out=>Out_data,
	   finish=>finito,
	   test_out=>outRAM
	);
	
     
     rst <= '1', '0' after 50 ns;
     clk <= not clk after 5 ns;
     
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
                IN_data((7+8*I) downto I*8)<=read_field_cur;
            end loop;   
            
          
	        if x=0 then
                wait until rst='0';
                x:=1;
            end if;

            IN_read<='0';
            IN_load<='1';
          	IN_matrix<=mat;

            wait for 20ns;
          
            IN_load<='0';
            
            wait for 640ns;
             
             IN_read<='1';
            wait for 20ns;
            IN_read<='0'; 
          	wait for 370ns;
   			mat:=mat+1;
        end loop;
         
      	
     end process;
     
       
	
end Structural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;


library STD;
use STD.textio.all;

entity TB_TIP_TOP is

end TB_TIP_TOP;

architecture Structural of TB_TIP_TOP is
	-----------------------------------------------------------------------------
	--SIGNALS
	-----------------------------------------------------------------------------
	signal clk: 				std_logic :='0';
	signal rst: 				std_logic;
	signal IN_read: 			std_logic:='0';
	signal IN_load: 			std_logic:='0';
	signal IN_matrix: 			std_logic_vector(3 downto 0):="0000";
	signal stimulus_data:		std_logic_vector(255  downto 0):=(others=>'0');
    signal IN_data:   			std_logic_vector(7 downto 0):=(others=>'0');
	signal Out_data:   			std_logic_vector(8 downto 0);
	signal output_c,output_n:	std_logic_vector(8 downto 0);
	signal finito:     			std_logic:='0';
	signal load_en,load_en_n,read_en,read_en_n:			std_logic:='0';
	signal tb_cnt_r,tb_cnt_n,read_cnt,read_cnt_n:	integer:=0;

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
	
component TIP_TOP is
    Port (
        clk        : in  std_logic;                       -- Clock signal
        rst      : in  std_logic;                       -- Reset signal
        IN_read    : in  std_logic;                       -- Read signal
        IN_load    : in  std_logic;                       -- Start loading data signal
        i0         : in  std_logic; 
        i1         : in  std_logic;
        i2         : in  std_logic;
        i3         : in  std_logic;  -- Input pads to set
        i4         : in  std_logic;
        i5         : in  std_logic;
        i6         : in  std_logic;
        i7         : in  std_logic;




        o0         : out  std_logic; 
        o1         : out  std_logic;
        o2         : out  std_logic;
        o3         : out  std_logic;  -- OUT pads to set
        o4         : out  std_logic;
        o5         : out  std_logic;
        o6         : out  std_logic;
        o7         : out  std_logic;
        o8         : out  std_logic;

        fns        : out  std_logic -- finish signal bit
        
        
    );
end component;
---------------------------------------------------------------------------------

    constant Count: integer := 31;
    constant CLOCK_CYCLE: time := 10 ns;

begin
--------------------------------------------------------------------------------
	-- Instantiate the components
--------------------------------------------------------------------------------

   
        
		top_ac: TIP_TOP
	port map (
		clk=>clk,
		rst=>rst,
		IN_load=>IN_load,
		IN_read=>IN_read,
        i0     =>IN_data(0), 
        i1     =>IN_data(1),
        i2     =>IN_data(2),
        i3     =>IN_data(3),  -- Input pads to set
        i4     =>IN_data(4),
        i5     =>IN_data(5),
        i6     =>IN_data(6),
        i7     =>IN_data(7),



        o0   	   =>Out_data(0), 
        o1         =>Out_data(1),
        o2         =>Out_data(2),
        o3         =>Out_data(3),  -- OUT pads to set
        o4         =>Out_data(4),
        o5         =>Out_data(5),
        o6         =>Out_data(6),
        o7         =>Out_data(7),
        o8         =>Out_data(8),

        fns        =>finito -- finish signal bit
        
        
    );
	   
	
 -----------------------------------------------------------------------------
 -- CLK simulation period 10 ns	
 -----------------------------------------------------------------------------
     rst <= '1', '0' after 1.5*CLOCK_CYCLE;
     clk <= not clk after CLOCK_CYCLE/2 ;
   -----------------------------------------------------------------------------  

     stimulus: process
     
      
      file Fin: TEXT open READ_MODE is "/h/d5/t/ch6487pa-s/ICP1/22io_before_synth/Chris_22io/code/simulation/input_stimuli.txt";
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

            wait for 1*CLOCK_CYCLE;
          
            IN_load<='0';
            
            wait for 83*CLOCK_CYCLE;
             
             IN_read<='1';
            wait for 2*CLOCK_CYCLE;
            IN_read<='0'; 
          	wait for 37*CLOCK_CYCLE;
   			mat:=mat+1;
        end loop;
       
     end process;

     
       seq: process(clk,rst,read_en,read_cnt) is 
       		file Fout: TEXT open WRITE_MODE is "/h/d5/t/ch6487pa-s/ICP1/22io_before_synth/Chris_22io/code/simulation/output.txt";
  			variable write_line_cur: line;
            --variable tb_cnt: integer := 0;

  			begin
  			if rising_edge(clk) then
  				if rst='1' then
  				tb_cnt_r<=0;
				read_cnt<=0;
  				load_en<='0';
  				read_en<='0';
  				output_c<=(others=>'0');
  				else
  				tb_cnt_r<=tb_cnt_n;
				read_cnt<=read_cnt_n;
  				read_en<=read_en_n;
  				load_en<=load_en_n;
  				output_c<=output_n;
  				end if;
                if outwrite0 > 0 and read_en='1' and  ((read_cnt) mod 2)=1 then
                  write(write_line_cur,string'("Element: "));
                  write(write_line_cur,outwrite0,right,10);
                  writeline(Fout,write_line_cur);
                end if;
	        end if;
			end process;

			comb:process(load_en,tb_cnt_r,stimulus_data,IN_load,load_en,IN_matrix,IN_read,read_en,Out_data,read_cnt) is begin
				read_en_n<=read_en;
				load_en_n<=load_en;
				tb_cnt_n<=0;
				read_cnt_n<=0;
				----------------------------------------------------------------
				if IN_load='1' and IN_read='0' and tb_cnt_r=0 then
					load_en_n<='1';
				elsif tb_cnt_r=31 then
					load_en_n<='0';								--loading
				end if;

				if load_en='1' and read_en='0' then
                    tb_cnt_n<=tb_cnt_r+1;
                    IN_data<=stimulus_data((7+8*(tb_cnt_r)) downto ((tb_cnt_r)*8));
                end if;
                ----------------------------------------------------------------
	            if IN_read='1' and tb_cnt_r=0 then
	            	IN_data(3 downto 0)<=IN_matrix;
	            	read_en_n<='1';
	            elsif (read_cnt=37) then
	            	read_en_n<='0';
			IN_data<=stimulus_data((7+8*(tb_cnt_r)) downto ((tb_cnt_r)*8));								--reading
	            end if;

            	if read_en='1' and load_en='0' then
            		read_cnt_n<=read_cnt+1;
            	
            		
            	end if;
            	----------------------------------------------------------------
	            output_n<=Out_data;

			end process;
			  
---------------------------------------------------------------------------------changing input during load	   		
			outwrite0<=to_integer(unsigned(  output_c & Out_data ));


   
end Structural;

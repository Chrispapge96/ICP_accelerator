library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Input_Matrix_tb is
end Input_Matrix_tb;

architecture structural of Input_Matrix_tb is
   -- Constants
   constant CLOCK_PERIOD   : time := 2500 ns;
   -- Components
   component Input_Matrix
   port ( 
     clk         : in std_logic;     -- Clock input
     rst         : in std_logic;     -- Reset input
     load_enable : in std_logic;     -- Writing enable bit
     IN_data     : in std_logic_vector(255 downto 0);    -- Input data
     addr_in     : in std_logic_vector ((integer(ceil(log2(real(WORD_LENGTH )))) - 1) downto 0);     -- Addres to output
     data        : out std_logic_vector (WORD_LENGTH-1 downto 0)    -- Output data
     );
   end component;

   -- Signals
   signal clk       : std_logic;
   signal rst     : std_logic;
   signal load_enable  : std_logic;
   signal IN_data   : std_logic_vector(255 downto 0);
   signal addr_in   : std_logic_vector(4 downto 0);
   signal data   : std_logic_vector(15 downto 0);
   

begin  -- structural
   
     -- Input matrix mapping
   DUT: entity work.Input_Matrix(behavioral) port map (
          clk         => clk,
          rst         => rst,
          load_enable => load_enable,
          IN_data     => IN_data,
          addr_in     => addr_in,
          data        => data
     );

     -- Process to manage the reset
     reset_gen: process
     begin
          reset <= '0';
          wait for CLOCK_PERIOD;
          reset <= '1';
          wait;
     end process reset_gen;

     -- Process to simulate the FPGA clock
    clock_process: process
        begin
          clk <= '1';
          wait for CLOCK_PERIOD/2;
          clk <= '0';
          wait for CLOCK_PERIOD/2;
     end process;

     TB_process: process
     begin
          IN_data <= x"0201 0403 0706 0908 0b0a 0d0c 0101 0101 0101 0101 0101 0101 0101 0101 0101 0101";
          load_enable <= '0';
          addr_in = "0000";
          wait for 2 * CLOCK_PERIOD;
          load_enable <= '1';
          wait for CLOCK_PERIOD;
          load_enable <= '0';

          for I in 0 to 15  loop
               wait for CLOCK_PERIOD;
               addr_in <= std_logic_vector(I);
          end loop;          
          wait;          

     end process;

end structural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Input_Matrix_tb is
end Input_Matrix_tb;

architecture structural of Input_Matrix_tb is
   -- Constants
   constant CLOCK_PERIOD   : time := 2500 ns;
   -- Components
   component Input_Matrix_tb
   port ( 
          clk         : in std_logic; -- Clock signal
          reset       : in std_logic; -- Reset signal
          load_enable : in std_logic;     -- Writing enable bit
          IN_data     : in std_logic_vector(255 downto 0);    -- Input data
          addr_in     : in std_logic_vector (4 downto 0);     -- Addres to output
          data        : out std_logic_vector (15 downto 0)    -- Output data
     );
   end component;

   -- Signals
   signal clk       : std_logic;
   signal reset     : std_logic;
   signal load_enable  : std_logic;
   signal IN_data   : std_logic_vector(255 downto 0);
   signal addr_in   : std_logic_vector(4 downto 0);
   signal data   : std_logic_vector(15 downto 0);  
   

begin  -- structural
   

   DUT: entity work.MAC(behavioral) port map (
          clk         => clk,
          reset       => reset,
          init_mac    => init_mac,
          dataROM     => dataROM,
          in_data     => in_data,
          dataRAM     => dataRAM
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
          init_mac <= '1';
          dataROM <= std_logic_vector(to_unsigned(129,14));
          in_data <= std_logic_vector(to_unsigned(257, 16));          
          wait for 2 * CLOCK_PERIOD;
          init_mac <= '0';
          wait for 4 * CLOCK_PERIOD;
          init_mac <= '1';
          wait for CLOCK_PERIOD;
          init_mac <= '0';
          wait;          

     end process;

end structural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MAC_tb is
end MAC_tb;

architecture structural of MAC_tb is
   -- Constants
   constant CLOCK_PERIOD   : time := 2500 ns;
   -- Components
   component MAC
   port ( 
          clk         : in std_logic; -- Clock signal
          reset       : in std_logic; -- Reset signal
          init_mac    : in std_logic; -- Reset the accumulation
          dataROM     : in std_logic_vector (13 downto 0);    -- 2 7bits words from ROM
          in_data     : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
          dataRAM     : out std_logic_vector (16 downto 0)    -- 16bit result
     );
   end component;

   -- Signals
   signal clk       : std_logic;
   signal reset     : std_logic;
   signal init_mac  : std_logic;
   signal dataROM   : std_logic_vector(13 downto 0);
   signal in_data   : std_logic_vector(15 downto 0);
   signal dataRAM   : std_logic_vector(16 downto 0);
   
   

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

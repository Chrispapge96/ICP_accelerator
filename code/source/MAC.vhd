library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;

-- Performs 2 multipliction-accumulation operations from 2*2*8 inputs
-- and return a 16 bit result
entity MAC is
    port(
        clk         : in std_logic; -- Clock signal
        rst       : in std_logic; -- Reset signal
        init_mac    : in std_logic; -- Reset the accumulation
        dataROM     : in std_logic_vector (11 downto 0);    -- 2 7bits words from ROM
        in_data     : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
        dataRAM     : out std_logic_vector (15 downto 0)    -- 16bit result
    );
    end MAC;

architecture behavioral of MAC is

    -- Signal definition
    signal mac_r, mac_n     : std_logic_vector (15 downto 0);
    signal mul0, mul1, sum0 : std_logic_vector (15 downto 0);
    signal mac              : std_logic_vector (15 downto 0);

begin

    -- Register management process
    register_process: process(clk, rst)
    begin
        if rst = '0' then
            mac_r <= (others => '0');
        elsif rising_edge(clk) then
            mac_r <= mac_n;            
        end if;
    end process;

    -- Combinatioonal process
    combinational_process: process(init_mac, dataROM, in_data, mac_r, mul0, mul1, sum0, mac)
        begin
        -- Set defqult vqlues
        dataRAM <= mac_r;  -- Update output
        
        if init_mac = '1' then  -- select the accumulation value
            mac <= (others => '0');
        else
            mac <= mac_r;
        end if;

        -- Perform the multiplications
        mul0    <= std_logic_vector(  unsigned("00" & dataROM(5 downto 0)) * unsigned(in_data(7 downto 0))  );
        mul1    <= std_logic_vector(  unsigned("00" & dataROM(11 downto 6)) * unsigned(in_data(15 downto 8))  );
        -- Perform the addiction and update the regiter
        sum0    <= std_logic_vector(  unsigned(mul0) + unsigned(mul1)  );
        mac_n   <= std_logic_vector(  unsigned(sum0) + unsigned(mac)  );

    end process;

end behavioral;
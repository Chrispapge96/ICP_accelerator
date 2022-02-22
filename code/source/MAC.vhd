library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;



library STD;
use STD.textio.all;

library work;

-- Performs 2 multipliction-accumulation operations from 2*2*8 inputs
-- and return a 16 bit result
entity MAC is
    port(
        clk         : in std_logic; -- Clock signal
        rst         : in std_logic; -- Reset signal
        init_mac    : in std_logic; -- Reset the accumulation
        RAM_part    : in std_logic;
        W_on        : in std_logic;
        enable      : in std_logic;
        dataROM     : in std_logic_vector (11 downto 0);    -- 2 7bits words from ROM
        in_data     : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
        dataRAM     : out std_logic_vector (31 downto 0)    -- 16bit result

    );
    end MAC;

architecture behavioral of MAC is

    -- Signal definition
    signal mac_r, mac_n ,mac_r0, mac_r0_n    : std_logic_vector (15 downto 0);
    signal mul0, mul1, sum0                  : std_logic_vector (15 downto 0);
    signal mac                               : std_logic_vector (15 downto 0):=(others=>'0');
    signal outwrite0,outwrite1               : integer:= 0;

   

begin



    -- Register management process
    register_process: process(clk, rst,W_on,enable)

     file Fout: TEXT open WRITE_MODE is "C:\Users\Xristos\Documents\GitHub\ICP_accelerator\code\simulation\output.txt";
  variable write_line_cur: line;

    begin
        if rising_edge (clk) then
            if rst = '1' or enable ='0' then
                 mac_r <= (others => '0');
                 mac_r0 <= (others => '0');
            else 
                 mac_r <= mac_n;   
                 mac_r0<=mac_r0_n;          
            end if;
            if W_on='1' then
              write(write_line_cur,string'("MAC0: "));
              write(write_line_cur,outwrite0,right,10);
              writeline(Fout,write_line_cur);
              write(write_line_cur,string'("MAC1: "));
              write(write_line_cur,outwrite1,right,10);
              writeline(Fout,write_line_cur);
            end if;
        end if;
    end process;

    -- Combinatioonal process
    combinational_process: process(init_mac, dataROM, in_data, mac_r, mul0, mul1, sum0, mac,RAM_part,mac_n,enable)


        begin
        -- To ensure zero value at next process of in matrix
            -- Set defqult vqlues
            if RAM_part='0' then
                mac_r0_n <= mac_n ;  -- Update output
            else
                mac_r0_n <= mac_r0 ;
            end if;
            
            if init_mac = '1' then  -- select the accumulation value
                mac <= (others => '0');
            else
                mac <= mac_r;
            end if;

            -- Perform the multiplications
            mul0    <= std_logic_vector(  unsigned("00" & dataROM(5 downto 0)) * unsigned(in_data(15 downto 8))  );--I swaped the data bits
            mul1    <= std_logic_vector(  unsigned("00" & dataROM(11 downto 6)) * unsigned(in_data(7 downto 0))  );--checked the simulation
            -- Perform the addiction and update the regiter
            sum0    <= std_logic_vector(  unsigned(mul0) + unsigned(mul1)  );
            mac_n   <= std_logic_vector(  unsigned(sum0) + unsigned(mac)  );
        
    end process;




    dataRAM<=mac_r & mac_r0;
    outwrite0<=to_integer(unsigned(mac_r0));
    outwrite1<=to_integer(unsigned(mac_r));



end behavioral;
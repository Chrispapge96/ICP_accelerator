library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


library work;

-- Performs 2 multipliction-accumulation operations from 2*2*8 inputs
-- and return a 16 bit result
entity MAC is
    port(
        clk         : in std_logic; -- Clock signal
        rst         : in std_logic; -- Reset signal
        init_mac    : in std_logic; -- Reset the accumulation
        RAM_part    : in std_logic; -- To choose register
        option      : in std_logic; -- To save the diag and max
        en_diag     : in std_logic; -- To enable diag calc
        enable      : in std_logic; -- To enable the MAC
        dataROM     : in std_logic_vector (11 downto 0);    -- 2 7bits words from ROM
        in_data     : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
        dataRAM     : out std_logic_vector (31 downto 0)    -- 16bit result

    );
    end MAC;

architecture behavioral of MAC is

    -- Signal definition
    signal mac_r, mac_n ,mac_r0, mac_r0_n,max_n,max_c    : std_logic_vector (15 downto 0);
    signal mul0, mul1, sum0                              : std_logic_vector (15 downto 0);
    signal mac                                           : std_logic_vector (15 downto 0):=(others=>'0');
  
    signal diag_sum_n,diag_sum_c                         : std_logic_vector (17 downto 0);
   

begin



    -- Register management process
    register_process: process(clk, rst,enable) is

    begin
        if rising_edge (clk) then
            if rst = '1' or enable ='0' then
                 mac_r <= (others => '0');
                 mac_r0 <= (others => '0');
                 max_c <= (others => '0');
                 diag_sum_c <= (others => '0');
            else 
                 max_c<=max_n;
                 mac_r <= mac_n;   
                 mac_r0<=mac_r0_n;    
                 diag_sum_c<=diag_sum_n;      
            end if;
        end if;
    end process;

    -- Combinatioonal process
    combinational_process: process(init_mac, dataROM, in_data, mac_r, mul0, mul1, sum0, mac,RAM_part,mac_n,enable,max_c,diag_sum_c)


        begin
            diag_sum_n<=diag_sum_c;
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

            if max_c<mac_n then
                max_n<=mac_n;
            else
                max_n<=max_c;
            end if;

            if en_diag='1' then
                diag_sum_n<=std_logic_vector(unsigned(diag_sum_c)+ unsigned("00" & mac_n));
            end if;

            
    end process;



    saving: process(option,mac_r,mac_r0,diag_sum_c,max_c) is begin -- to choose what to save
            if option='0' then
                dataRAM<=mac_r & mac_r0;
            else
                dataRAM<=max_c & diag_sum_c(17 downto 2);
            end if;
            end process;

    



end behavioral;
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
        option      : in std_logic_vector(1 downto 0); -- To save the diag and max
        en_diag     : in std_logic; -- To enable diag calc
        enable      : in std_logic; -- To enable the MAC
        dataROM     : in std_logic_vector (11 downto 0);    -- 2 7bits words from ROM
        in_data_mac : in std_logic_vector (15 downto 0);    -- 2 8bits words from inpuyt buffer
        dataRAM     : out std_logic_vector (31 downto 0)    -- 16bit result

    );
    end MAC;

architecture behavioral of MAC is

    -- Signal definition
    signal mac_r, mac_n,max_n,max_c, sum0                : std_logic_vector (17 downto 0);
    signal mul0, mul1                                    : std_logic_vector (15 downto 0);
    signal mac                                           : std_logic_vector (17 downto 0);
    signal diag_sum_n,diag_sum_c                         : std_logic_vector (19 downto 0);
   

begin



    -- Register management process
    register_process: process(clk, rst,enable) is

    begin
        if rising_edge (clk) then
            if rst = '1' or enable ='0' then
                 mac_r <= (others => '0');
                
                 max_c <= (others => '0');
                 diag_sum_c <= (others => '0');
                
            else 
                 max_c<=max_n;
                 mac_r <= mac_n;   
               
                 diag_sum_c<=diag_sum_n;      
            end if;
        end if;
    end process;

    -- Combinatioonal process
    combinational_process: process(init_mac, dataROM, in_data_mac, mac_r, mul0, mul1, sum0, mac,mac_n,enable,max_c,diag_sum_c,en_diag)


        begin
            diag_sum_n<=diag_sum_c;
            -- Set defqult vqlues

            if init_mac = '1' then  -- select the accumulation value
                mac <= (others => '0');
            else
                mac <= mac_r;
            end if;

            -- Perform the multiplications
            mul0    <= std_logic_vector(  unsigned("00" & dataROM(5 downto 0)) * unsigned(in_data_mac(15 downto 8))  );--I swaped the data bits
            mul1    <= std_logic_vector(  unsigned("00" & dataROM(11 downto 6)) * unsigned(in_data_mac(7 downto 0))  );--checked the simulation
            -- Perform the addiction and update the regiter
            sum0    <= std_logic_vector(  unsigned("00" & mul0) + unsigned("00" & mul1)  );
            mac_n   <= std_logic_vector(  unsigned(sum0) + unsigned(mac)  );

            if max_c<mac_n then
                max_n<=mac_n;
            else
                max_n<=max_c;
            end if;

            if en_diag='1' then
                diag_sum_n<=std_logic_vector(unsigned(diag_sum_c)+ unsigned("00" & mac_r));
            end if;

            
    end process;



    saving: process(option,mac_r,diag_sum_c,max_c) is begin -- to choose what to save
                if option="00" then
                    dataRAM<="00000000000000" & mac_r; 
                elsif option="01" then
                    dataRAM<="00000000000000" & max_c;
                else  
                    dataRAM<="00000000000000" & diag_sum_c(19 downto 2);
                end if;
            end process;

    



end behavioral;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;

library work;

entity Input_Matrix is

    generic(WORD_LENGTH : integer := 16);
    port(
        clk         : in std_logic;     -- Clock input
        rst         : in std_logic;     -- Reset input
        load_enable : in std_logic;     -- Writing enable bit
        IN_data     : in std_logic_vector(7 downto 0);    -- Input data
        addr_in     : in std_logic_vector ((integer(ceil(log2(real(WORD_LENGTH )))) - 1) downto 0);     -- Addres to output
        data        : out std_logic_vector (WORD_LENGTH-1 downto 0)    -- Output data

    );
end Input_Matrix;


architecture behavioral of Input_Matrix is


    -- Type definition
    type t_Memory is array (0 to (256/WORD_LENGTH)-1) of std_logic_vector(WORD_LENGTH - 1 downto 0);
    
    -- Constant definition
    constant WL_MIN_1 : integer:= t_Memory'LENGTH -1;

    -- Signal definition
    signal data_r, data_n   : t_Memory;
    signal addr_load_c, addr_load_n: std_logic_vector(4 downto 0);--count for loading
begin
    -- Register management process
    register_process : process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst='1' then
                for I in 0 to WL_MIN_1   loop
                    data_r(I) <= (others => '0');
                end loop;
                addr_load_c<= (others => '0');
            else
                data_r <= data_n;
                addr_load_c<=addr_load_n;--counter for loading
            end if;
        end if;
    end process;

    -- Combinational management process
    combinational_process : process(load_enable, IN_data, addr_in, data_r,addr_load_c)
        begin
        data_n <= data_r;
        -- Manage the input update
        if load_enable = '1' then
            addr_load_n<=addr_load_c + 1;
            if addr_load_c(0)='0' then
                data_n(to_integer(unsigned(addr_load_c(3 downto 0)))) <= data_r(to_integer(unsigned(addr_load_c(3 downto 0)))) & IN_data;
            else
                data_n(to_integer(unsigned(addr_load_c(3 downto 0)))) <= IN_data & data_r(to_integer(unsigned(addr_load_c(3 downto 0))));
            end if;
        else
            addr_load_n<=addr_load_c;
            
        end if;
        
        -- Manage the output
        data <= data_r(to_integer(unsigned(addr_in)));

    end process;

end behavioral;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

library work;

entity Input_Matrix is

    generic(WORD_LENGTH : integer := 16);
    port(
        clk         : in std_logic;     -- Clock input
        rst         : in std_logic;     -- Reset input
        load_enable : in std_logic;     -- Writing enable bit
        IN_data     : in std_logic_vector(255 downto 0);    -- Input data
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

begin
    -- Register management process
    register_process : process(clk, rst)
    begin
        if rst = '0' then
            -- Defualt values set to 0
            for I in 0 to WL_MIN_1   loop
                data_r(I) <= (others => '0');
            end loop;
            
        elsif rising_edge(clk) then
            data_r <= data_n;
        end if;
    end process;

    -- Combinational management process
    combinational_process : process(load_enable, IN_data, addr_in, data_r)
        begin
        -- Manage the input update
        if load_enable = '1' then
            
            --#pragma unroll
            for I in 0 to WL_MIN_1  loop
                data_n(I) <= IN_data((I * WORD_LENGTH + WL_MIN_1) downto (I * WORD_LENGTH));
            end loop;
        else
            data_n <= data_r;
        end if;
        
        -- Manage the output
        data <= data_r(to_integer(unsigned(addr_in)));

    end process;

end behavioral;
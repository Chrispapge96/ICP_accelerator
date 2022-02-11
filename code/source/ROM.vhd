library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ROM is
 Port ( clk         : in std_logic;
        enable_ROM  : in std_logic;
        addr_ROM    : in std_logic_vector (3 downto 0); 
        dataROM     : out std_logic_vector (11 downto 0)
        );
end ROM;

architecture Behavioral of ROM is

    type ROM_Memory is array (0 to 15) of std_logic_vector(11 downto 0);
    
    constant coef : ROM_Memory:=(
        "000011010110",
        "001011000001",
        "001000000011",
        "000001000010",
	    "001000001111",
	    "000010000100",
	    "001100000110",
	    "000001000010",
	    "010010101000",
	    "000011000010",
	    "010000001001",
	    "000001000010",
	    "000001001010",
	    "000100000000",
	    "000010001100",
	    "000001000010"
               );
      
    
    begin
    

        dataROM<=coef(to_integer(unsigned(addr_ROM)));

    
end Behavioral;

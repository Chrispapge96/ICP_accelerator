library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TOP_TOP is
    Port (
        clk        : in  std_logic;                       -- Clock signal
        rst      : in  std_logic;                       -- Reset signal
        IN_read    : in  std_logic;                       -- Read signal
        IN_load    : in  std_logic;                       -- Start loading data signal
        i0         : in  std_logic; 
        i1         : in  std_logic;
        i2         : in  std_logic;
        i3         : in  std_logic;  -- Input pads to set
        i4         : in  std_logic;
        i5         : in  std_logic;
        i6         : in  std_logic;
        i7         : in  std_logic;
        i8         : in  std_logic;
        i9         : in  std_logic;
        i10        : in  std_logic;
        i11        : in  std_logic;
        i12        : in  std_logic;
        i13        : in  std_logic;
        i14        : in  std_logic;
        i15        : in  std_logic;


        o0         : out  std_logic; 
        o1         : out  std_logic;
        o2         : out  std_logic;
        o3         : out  std_logic;  -- OUT pads to set
        o4         : out  std_logic;
        o5         : out  std_logic;
        o6         : out  std_logic;
        o7         : out  std_logic;
        o8         : out  std_logic;
        o9         : out  std_logic;
        o10        : out  std_logic;
        o11        : out  std_logic;
        o12        : out  std_logic;
        o13        : out  std_logic;
        o14        : out  std_logic;
        o15        : out  std_logic;
        fns        : out  std_logic -- finish signal bit
        
        
    );
end TOP_TOP;


architecture Structural of TOP_TOP is

--------------------------------------------------------------------------------
-- -- Signals
--------------------------------------------------------------------------------
    signal IN_bits,Out_bits : std_logic_vector(15 downto 0);
    signal matrix_bits: std_logic_vector(3 downto 0);
    signal finito,clk_sig,rst_sig, In_read_sig, IN_load_sig: std_logic;
  
--------------------------------------------------------------------------------
-- -- Components
--------------------------------------------------------------------------------

    component  TOP_Accelerator is
        Port (
            clk        : in  std_logic;                       -- Clock signal
            rst      : in  std_logic;                       -- Reset signal
            IN_read    : in  std_logic;                       -- Read signal
            IN_load    : in  std_logic;                       -- Start loading data signal
            IN_data_in : in  std_logic_vector(15 downto 0);   -- Input data to set
            IN_matrix : in std_logic_vector(3 downto 0);  -- Result matrix index
            OUT_data_out : out std_logic_vector(15 downto 0);  -- Output data
            finish     : out std_logic
            
            
        );
    end component;

    component CPAD_S_74x50u_IN is ----------------------------------input pad comp

        Port(
             PADIO      :in std_logic;
             COREIO     :out std_logic
        );
    end component;


    component CPAD_S_74x50u_OUT is ---------------------------------output pad comp

        Port(
             PADIO      :out std_logic;
             COREIO     :in std_logic
        );
    end component;

begin

--------------------------------------------------------------------------------
--IN
--------------------------------------------------------------------------------
    inpad0: CPAD_S_74x50u_IN
    port map(
        PADIO=>i0,
        COREIO=>IN_bits(0)
     
    );

        inpad1: CPAD_S_74x50u_IN
    port map(
        PADIO=>i1,
        COREIO=>IN_bits(1)
     
    );

        inpad2: CPAD_S_74x50u_IN
    port map(
        PADIO=>i2,
        COREIO=>IN_bits(2)
     
    );

        inpad3: CPAD_S_74x50u_IN
    port map(
        PADIO=>i3,
        COREIO=>IN_bits(3)
     
    );

        inpad4: CPAD_S_74x50u_IN
    port map(
        PADIO=>i4,
        COREIO=>IN_bits(4)
     
    );

        inpad5: CPAD_S_74x50u_IN
    port map(
        PADIO=>i5,
        COREIO=>IN_bits(5)
     
    );

        inpad6: CPAD_S_74x50u_IN
    port map(
        PADIO=>i6,
        COREIO=>IN_bits(6)
     
    );

        inpad7: CPAD_S_74x50u_IN
    port map(
        PADIO=>i7,
        COREIO=>IN_bits(7)
     
    );

        inpad8: CPAD_S_74x50u_IN
    port map(
        PADIO=>i8,
        COREIO=>IN_bits(8)
     
    );

        inpad9: CPAD_S_74x50u_IN
    port map(
        PADIO=>i9,
        COREIO=>IN_bits(9)
     
    );

        inpad10: CPAD_S_74x50u_IN
    port map(
        PADIO=>i10,
        COREIO=>IN_bits(10)
     
    );

        inpa11: CPAD_S_74x50u_IN
    port map(
        PADIO=>i11,
        COREIO=>IN_bits(11)
     
    );

        inpad12: CPAD_S_74x50u_IN
    port map(
        PADIO=>i12,
        COREIO=>IN_bits(12)
     
    );

        inpad13: CPAD_S_74x50u_IN
    port map(
        PADIO=>i13,
        COREIO=>IN_bits(13)
     
    );

        inpad14: CPAD_S_74x50u_IN
    port map(
        PADIO=>i14,
        COREIO=>IN_bits(14)
     
    );

        inpad15: CPAD_S_74x50u_IN
    port map(
        PADIO=>i15,
        COREIO=>IN_bits(15)
     
    );

        clk_pad: CPAD_S_74x50u_IN
    port map(
        PADIO=>clk,
        COREIO=>clk_sig
     
    );

        load_pad: CPAD_S_74x50u_IN
    port map(
        PADIO=>IN_load,
        COREIO=>IN_load_sig
     
    );

        read_pad: CPAD_S_74x50u_IN
    port map(
        PADIO=>IN_read,
        COREIO=>IN_read_sig
     
    );

        rst_pad: CPAD_S_74x50u_IN
    port map(
        PADIO=>rst,
        COREIO=>rst_sig
     
    );

---------------------------------------------------------------------------------
-- -- OUT
--------------------------------------------------------------------------------       
    

    Outpad0: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o0,
        COREIO=>Out_bits(0)
     
    );

        Outpad1: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o1,
        COREIO=>Out_bits(1)
     
    );

        Outpad2: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o2,
        COREIO=>Out_bits(2)
     
    );

        Outpad3: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o3,
        COREIO=>Out_bits(3)
     
    );

        Outpad4: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o4,
        COREIO=>Out_bits(4)
     
    );

        Outpad5: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o5,
        COREIO=>Out_bits(5)
     
    );

        Outpad6: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o6,
        COREIO=>Out_bits(6)
     
    );

        Outpad7: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o7,
        COREIO=>Out_bits(7)
     
    );

        Outpad8: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o8,
        COREIO=>Out_bits(8)
     
    );

        Outpad9: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o9,
        COREIO=>Out_bits(9)
     
    );

        Outpad10: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o10,
        COREIO=>Out_bits(10)
     
    );

        Outpad11: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o11,
        COREIO=>Out_bits(11)
     
    );

        Outpad12: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o12,
        COREIO=>Out_bits(12)
     
    );

        Outpad13: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o13,
        COREIO=>Out_bits(13)
     
    );

        Outpad14: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o14,
        COREIO=>Out_bits(14)
     
    );

            Outpad15: CPAD_S_74x50u_OUT
    port map(
        PADIO=>o15,
        COREIO=>Out_bits(15)
     
    );


        Finish_bit: CPAD_S_74x50u_OUT
    port map(
        PADIO=>fns,
        COREIO=>finito     
    );


    -----------------------------------------------------------------------------
    -- -- TOP_Accelerator
    ----------------------------------------------------------------------------

            top_ac: TOP_Accelerator
    port map (
        clk=>clk_sig,
        rst=>rst_sig,
        IN_load=>IN_load_sig,
        IN_read=>IN_read_sig,
        IN_matrix=>matrix_bits,
        IN_data_in=>IN_bits(15 downto 0),
        OUT_data_out=>Out_bits(15 downto 0),
        finish=>finito
       
    );

    -----------------------------------------------------------------------------
    -- -- LOGIC for I/O
    -----------------------------------------------------------------------------
        matrix_bits<=IN_bits(3 downto 0);



    end structural;
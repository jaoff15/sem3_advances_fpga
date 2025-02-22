

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;


entity top is
    Port ( clk_in_hw        : in  STD_LOGIC := '0';
           clk_out          : out std_logic := '0';
           tx_out_hw        : out std_logic := '0';
           rx_in_hw         : in  std_logic := '0';
    --       tx_active            : in  std_logic := '0';
           segment_out      : out std_logic_vector(7 downto 0) := (others => '0');
           input_hw         : in  std_logic_vector(7 downto 0) := (others => '0');
           rx_data_hw       : out std_logic_vector(7 downto 0) := (others => '0'));
end top;

architecture Behavioral of top is
    
    component bus_master is
        Port ( clk_in       : in    STD_LOGIC := '0';
               reset_in     : in    STD_LOGIC := '0';
               rx_in        : in    STD_LOGIC := '0';
               tx_out       : out   STD_LOGIC := '0';
               clk_out      : out   STD_LOGIC := '0';
               data_bus_in  : in    STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
               data_bus_out : out   STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
               address_bus  : out   STD_LOGIC_VECTOR(7  downto 0) := (others => '0');
               rx_data_out  : out   std_logic_vector(7 downto 0)   := (others => '0')
               );
    end component;
    
    component segment_display is
        generic(    module_adr  :     std_logic_vector(7  downto 0)  := (others => '0'));
        Port (      clk_in      : in  std_logic                      := '0';
                    reset_in    : in  std_logic                      := '0';
                    adr_in      : in  STD_LOGIC_VECTOR (7  downto 0) := (others => '0');
                    data_in     : in  STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
                    hw_out      : out STD_LOGIC_VECTOR (7  downto 0) := (others => '0'));
    end component;

    component input_module is
        generic(    module_adr  :     std_logic_vector(7  downto 0)  := (others => '0'));
        Port (      clk_in      : in  std_logic                      := '0';
                    reset_in    : in  std_logic                      := '0';
                    adr_in      : in  STD_LOGIC_VECTOR (7  downto 0) := (others => '0');
                    data_out    : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
                    hw_in       : in  STD_LOGIC_VECTOR (7  downto 0) := (others => '0')
                    );
    end component;



    signal rx_data_out      : std_logic_vector(7 downto 0) := (others => '0');
    --signal bus_master_clk   : std_logic := '0';
    
    signal bus_master_clk : std_logic := '0';
    
    signal address_signal       : std_logic_vector(7  downto 0) := (others => '0');
    signal data_bus_in_signal   : std_logic_vector(31 downto 0) := (others => '0');
    signal data_bus_out_signal  : std_logic_vector(31 downto 0) := (others => '0');
    
begin

clk_out <= bus_master_clk;

rx_data_hw <= rx_data_out;


bus_master0:bus_master
port map(
    clk_in       => clk_in_hw,  
    reset_in     => '0',
    rx_in        => rx_in_hw,
    tx_out       => tx_out_hw,
    clk_out      => bus_master_clk,
    data_bus_in  => data_bus_in_signal,
    data_bus_out => data_bus_out_signal,
    address_bus  => address_signal,
    rx_data_out  => rx_data_out
);

segment_display0:segment_display
generic map( module_adr     => x"AB")
port map(    clk_in         => bus_master_clk,
             reset_in       => '0',
             adr_in         => address_signal, 
             data_in        => data_bus_out_signal,
             hw_out         => segment_out
);

input_module0:input_module
generic map( module_adr    => x"98")
port map(    clk_in        => bus_master_clk,
             reset_in      => '0',
             adr_in        => address_signal, 
             hw_in         => input_hw,
             data_out      => data_bus_in_signal
);



end Behavioral;

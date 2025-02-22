----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/29/2020 03:52:06 PM
-- Design Name: 
-- Module Name: uart_tx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx is
    
    Port    ( CLK_IN    : in  STD_LOGIC := '0';
              START_IN  : in  std_logic := '0';
              RESET_IN  : in  std_logic := '0';
              TX_DATA   : in  std_logic_vector(7 downto 0) := (others => '0');
              TX_DONE   : out std_logic := '0';
              TX_BUSY   : out std_logic := '0';
              TX_OUT    : out std_logic := '1');
end uart_tx;

architecture Behavioral of uart_tx is

    
    signal substate         : integer range 0 to 32 := 0;
    signal substate_count   : integer range 0 to 32 := 32;
    
    signal tx_out_signal    : std_logic := '1';
    signal tx_out_signal_i  : std_logic := '1';
    
    signal running          : std_logic := '0';
    
    signal tx_data_snapshot : std_logic_vector(7 downto 0) := (others => '0');

    type T_STATE is (S_WAIT, S_START, S_BITS, S_STOP);
    signal state, next_state : T_STATE;

    signal bit_index         : integer range 0 to 7 := 0;
     
begin

TX_BUSY <= running;
TX_DONE <=  not running;
TX_OUT <= tx_out_signal;



SYNC_PROC: process (clk_in)
begin
  if rising_edge(clk_in) then
     if (RESET_IN = '1') then
        state         <= S_WAIT;
        tx_out_signal <= '1';
     else
        state         <= next_state;
        tx_out_signal <= tx_out_signal_i;
     end if;
    
  end if;
end process;

--MOORE State-Machine - Outputs based on state only
OUTPUT_DECODE: process (state, substate)
begin
    tx_out_signal_i     <= tx_out_signal_i;
    running             <= '0';
    tx_out_signal_i     <= '1';
    if state = S_WAIT then 
        running         <= '0';
    elsif state = S_STOP then
        running         <= '1';
        tx_out_signal_i <= '1';
    elsif state = S_BITS then
        running         <= '1';
        tx_out_signal_i <= tx_data_snapshot(bit_index);
    elsif state = S_START then
        running         <= '1';
        tx_out_signal_i <= '0';
    end if;
end process;


NEXT_STATE_DECODE: process (clk_in)
begin
  next_state        <= state;  --default is to stay in current state
  tx_data_snapshot  <= tx_data_snapshot;
  case (state) is
     when S_WAIT =>
        if START_IN = '1' then
            tx_data_snapshot  <= TX_DATA;
            next_state <= S_START;
        end if;
     
     when S_START =>
        if substate = substate_count-1 then
           next_state <= S_BITS;
        end if;
     
     when S_BITS =>
        if bit_index = 7 and substate = substate_count-1 then
            next_state <= S_STOP;
         end if;
     
     when S_STOP =>
        if substate = substate_count-1 then
             next_state <= S_WAIT;
          end if;
     
     when others =>
        next_state <= S_WAIT;
  end case;
end process;


process (clk_in) 
begin
    if rising_edge(clk_in) then
        substate <= substate + 1;
        if state /= next_state or substate = substate_count -1 then
            substate <= 0;
        end if;
    end if;
end process;


process (clk_in) 
begin
    if rising_edge(clk_in) then
        bit_index <= bit_index;
        if substate = substate_count - 1 and state = S_BITS then
            bit_index <= bit_index + 1;
        elsif state /= s_BITS then
            bit_index <= 0;
        end if;      
    end if;
end process;



end Behavioral;

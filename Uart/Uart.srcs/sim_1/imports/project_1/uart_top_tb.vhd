library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity uart_top_tb is
end uart_top_tb;

architecture Behavioral of uart_top_tb is
    
    component uart_top is
                   -- generic(M : integer);
                   port( rst, clk :in std_logic;
                         uart_rx_i : in std_logic;
                         --data_received_i : in std_logic_vector(7 downto 0);
                         --data_received_ready_i : in std_logic;
                         uart_tx_o : out std_logic      
                         --data_xmit_o : out std_logic_vector(7 downto 0);
                         --data_xmit_ready_o : out std_logic
                       );
    end component;
     
     signal clk, rst : std_logic := '0';
     signal uart_rx_i   : std_logic ;
     signal uart_tx_o : std_logic;
 --    signal tx_done_o : std_logic;


     constant clk_time : time := 10 ns;
     constant wait_time : time := 13020*clk_time;      
         
 begin
     
     Inst : uart_top 
            port map ( clk=>clk, rst=>rst, uart_rx_i=>uart_rx_i, uart_tx_o=>uart_tx_o);
     
     process
     begin
     
--     for i in 0 to 500 loop
             wait for clk_time/2;
             clk <= '1';
             wait for clk_time/2;
             clk <= '0';
--         end loop;
--         wait;
     end process;
     
     process
     begin
         rst <= '1';
         uart_rx_i<='1';
         wait for 50 ns;
         rst <= '0';
         wait for wait_time;
           for i in 0 to 15 loop
               uart_rx_i <= '0';
               wait for wait_time;
               for j in 0 to 7 loop
                uart_rx_i <= to_unsigned(i, 8)(j);
                wait for wait_time;
               end loop;
                uart_rx_i <= '1';  
                wait for 2*wait_time;
            
           end loop;
           wait;

         wait;
     end process;


end Behavioral;

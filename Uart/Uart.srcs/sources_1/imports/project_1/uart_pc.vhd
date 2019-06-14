library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_pc is
    generic  ( M : integer  );
    port     ( clk,rst  : in std_logic;     
               uart_rx_i             : in std_logic ;
               data_xmit_o           : out std_logic_vector(7 downto 0);
               data_xmit_ready_o     : out std_logic;  
               data_received_ready_i : in std_logic;
               data_received_i       : in std_logic_vector(7 downto 0);
               uart_tx_o             : out std_logic;  
               tx_done_o             : out std_logic );
end uart_pc;

architecture Behavioral of uart_pc is

    component uart_tx is  
        generic  ( M : integer ;
                   D : integer := 8 );
        port     ( clk, rst  : in std_logic;
                   start_i   : in std_logic;
                   data_i    : in std_logic_vector(7 downto 0);
                   tx_o      : out std_logic;
                   tx_done_o : out std_logic );
    end component;                                   

    component uart_rx is  
    generic ( D : integer := 8; 
              M : integer    );
    port    ( clk, rst   : in  std_logic;
              rx_i       : in  std_logic; 
              data_o     : out std_logic_vector(7 downto 0); 
              rx_ready_o : out std_logic );
    end component;

begin
    rx0 : uart_rx   generic map ( M => M )
                    port map    ( clk=>clk, rst=>rst, data_o=>data_xmit_o, rx_ready_o=>data_xmit_ready_o, rx_i=>uart_rx_i );
                    
    tx0 : uart_tx   generic map ( M => M )
                    port map    ( clk=>clk,  rst=>rst, start_i=>data_received_ready_i, data_i=>data_received_i, tx_o=>uart_tx_o, tx_done_o=>tx_done_o );

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uart_top is
                --generic (M : integer:=13020);
                port( rst, clk :in std_logic;
                      uart_rx_i : in std_logic;
                     -- modem_rx_i : in std_logic;
                      uart_tx_o : out std_logic   
                    --  modem_tx_o: out std_logic
                    );
end uart_top;

architecture Behavioral of uart_top is

    component uart_pc is 
        generic  ( M : integer);
        port     (clk,rst   : in std_logic;
                  uart_rx_i : in std_logic ;
                  data_xmit_o       : out std_logic_vector(7 downto 0);
                  data_xmit_ready_o : out std_logic;
                  data_received_ready_i : in std_logic;
                  data_received_i       : in std_logic_vector(7 downto 0);
                  uart_tx_o : out std_logic;  
                  tx_done_o : out std_logic );
    end component;        
    
    component transmitter is
        generic( D : integer := 8;
                 M : integer    );
        port   ( clk, rst : in  std_logic;
                 data_xmit_ready_i : in  std_logic;
                 data_xmit_i : in  std_logic_vector(D-1 downto 0);
                 tx_o : out std_logic );    
    end component;
    
    component receiver is
    generic ( D : integer := 8; 
              M : integer    );
    port    ( clk, rst : in  std_logic;
              shift    : in std_logic;
              rx_i     : in  std_logic;
              data_received_o       : out std_logic_vector(D-1 downto 0); 
              data_received_ready_o : out std_logic );
    end component;      
        
    signal data_xmit_i           : std_logic_vector(7 downto 0);    
    signal data_xmit_ready_i     : std_logic;   
    signal data_received_ready_o : std_logic;  
    signal data_received_o       : std_logic_vector(7 downto 0);  
    signal tx_o                  : std_logic;
    signal tx_done_o             : std_logic;
    constant M : integer := 13020;
begin

pc : uart_pc generic map (M => M)
             port map(clk=>clk, rst=>rst, uart_rx_i=>uart_rx_i, data_xmit_o=>data_xmit_i, 
                      data_xmit_ready_o=>data_xmit_ready_i, data_received_ready_i=>data_received_ready_o, 
                      data_received_i =>data_received_o, uart_tx_o=>uart_tx_o, tx_done_o=>tx_done_o); 
                     
tr : transmitter generic map (M => M)
                 port map(clk=>clk, rst=>rst, data_xmit_i =>data_xmit_i,data_xmit_ready_i=>data_xmit_ready_i,tx_o=>tx_o );
    
rc : receiver generic map (M => M)
              port map(clk=>clk, rst=>rst,data_received_o=>data_received_o, data_received_ready_o=>data_received_ready_o,rx_i=>tx_o, shift=>tx_done_o);


end Behavioral;

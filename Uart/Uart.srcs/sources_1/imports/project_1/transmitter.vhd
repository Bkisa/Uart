library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity transmitter is
    generic( D : integer := 8; 
             M : integer    );
    port   ( clk, rst          : in  std_logic;
             data_xmit_ready_i : in  std_logic; 
             data_xmit_i       : in  std_logic_vector(D-1 downto 0);
             tx_o              : out std_logic );    
end transmitter;

architecture Behavioral of transmitter is

    component uart_tx is 
        generic ( M : integer ;
                  D : integer := 8 );                                
        port    ( clk, rst  : in std_logic;
                  start_i   : in std_logic;
                  data_i    : in std_logic_vector(D-1 downto 0);
                  tx_o      : out std_logic;
                  tx_done_o : out std_logic );
    end component;
                 
type state_type is (idle, buffdata, zeros, senddata, ones);
signal state     : state_type:=idle;                              
signal done0     : std_logic := '0';
signal en        : std_logic := '0';
signal str       : std_logic := '0'; 
signal send_data : std_logic_vector(7 downto 0);
signal tx_done_o : std_logic; 
signal tmp_buff  : std_logic_vector(127 downto 0):=(others=>'0'); 
signal cnt       : integer:=0;

begin   
      
tx  : uart_tx  generic map ( M => M )
               port map    ( clk=>clk,rst=>rst,start_i=>str,data_i=>send_data,tx_o=>tx_o,tx_done_o=>tx_done_o );     

process(clk)
begin
    if(rising_edge(clk)) then
        if(rst='1') then
            state<=idle;
        else
            en<='1';
            str<='0';
        
        case state is
            when idle =>
                en<='0';
                str<='0';
                if(data_xmit_ready_i='1') then
                    state<=buffdata;
                    cnt<=0;
                    tmp_buff<=data_xmit_i & tmp_buff(127 downto 8);
                end if;      
            
            when buffdata =>
                if(data_xmit_ready_i='1') then
                    tmp_buff<=data_xmit_i & tmp_buff(127 downto 8);
                    cnt<=cnt+1;
                    if(cnt=14) then
                        state<=zeros;
                        cnt<=0;
                    end if;    
                end if;     
            
            when zeros =>
                str<='1';
                send_data<="00000000";
                if(tx_done_o='1') then
                    str<='1';
                    cnt <= cnt + 1;
                    if(cnt = 0) then                 
                        state<=senddata;
                    end if;
                end if;
            
            when senddata =>
                if(tx_done_o='1') then  
                    str<='1';                
                    send_data<=tmp_buff(7 downto 0);
                    tmp_buff<="00000000" & tmp_buff(127 downto 8);
                    cnt<=cnt+1;
                    if(cnt=17) then
                        cnt<=0;
                        state<=ones;
                    end if;
                end if;   
            
            when ones => 
                send_data<="11111111";                  
                    if(tx_done_o='1') then  
                        str <= '1';                   
                        cnt <= cnt + 1;
                        if(cnt = 2) then                        
                            state<=idle;
                            str <= '0';
                        end if;
                    end if;
        end case;
        end if;
    end if;
end process;         
end Behavioral;

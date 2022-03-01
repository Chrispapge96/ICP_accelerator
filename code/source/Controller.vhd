library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity Controller is
  port(
  	clk 							: in  std_logic;
  	rst 					    : in  std_logic;
		IN_read 					: in  std_logic;
		IN_load						: in  std_logic;
		IN_matrix 		    : in  std_logic_vector(3 downto 0);
		web 							: out std_logic_vector(1 downto 0);
		addr_ram          : out std_logic_vector(7 downto 0);
		addr_In  					: out std_logic_vector(3 downto 0);
		addr_rom  		    : out std_logic_vector(3 downto 0);
		rst_sumReg  	    : out std_logic;
		load_enable  	    : out std_logic;
		RAM_part          : out std_logic;
		en_diag						:	out std_logic;
		enable_MAC				:	out std_logic;
		option 						:	out std_logic;
		finish    		    : out std_logic
		);

end Controller;

architecture Behavioral of Controller is
 
	type state_of_operation is (IDLE,OP,LOAD,SAVE,SAVE_extra,FINISHED,READ);
	signal state_cur, state_next														: state_of_operation;

	signal addr_ram_r_n,addr_ram_r,addr_ram_w_n,addr_ram_w  :	std_logic_vector(7 downto 0);
	signal cnt_r,cnt_n 																			: std_logic_vector(5 downto 0);
	signal web_s																						:	std_logic_vector(1 downto 0);
	--signal IN_matrix_c,IN_matrix_n													: std_logic_vector(3 downto 0);
	begin
-------------------------------------------------------------------------------	
--Sequential part
-------------------------------------------------------------------------------
	seq: process(clk,rst,state_next,addr_ram_w_n,addr_ram_r_n,cnt_n) is begin
		if rising_edge(clk) then
			if rst = '1' then
				state_cur<=IDLE;
				cnt_r<=(others=>'0');
				addr_ram_r<=(others=>'0');
				addr_ram_w<=(others=>'0');
				IN_matrix_c<=(others=>'0');
			else
				state_cur<=state_next;
				cnt_r<=cnt_n;
				addr_ram_r<=addr_ram_r_n;
				addr_ram_w<=addr_ram_w_n;
				IN_matrix_c<=IN_matrix_n;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--Logic behind RAM address write and read
--------------------------------------------------------------------------------

--	RAM_MUX: process(addr_ram_r,addr_ram_w,web_s) is begin
	--	if web_s(1)='1' then
		--	addr_ram<=addr_ram_r;
		--else
		--	addr_ram<=addr_ram_w;
		--end if;
	--end process;

---------------------------------------------------------------------------------
--The FSM
--------------------------------------------------------------------------------
	Rotation_of_states: process(IN_read,state_cur,IN_load,cnt_r) is begin
	   state_next<=state_cur;
		if state_cur=IDLE then
			if IN_read='1' then
					state_next<=READ;
			else
				if IN_load='1' then
					state_next<=LOAD;
				end if;
			end if;
		elsif state_cur=READ then
			if cnt_r(3 downto 0)="1001" then
				state_next<=IDLE;
			else
				state_next<=state_cur;
			end if;
		elsif state_cur=LOAD then
			state_next<=OP;
		elsif state_cur=OP then
		  if cnt_r(1 downto 0)="11" then
			if cnt_r(5 downto 0)="111111" then
				state_next<=SAVE_extra;
			else
				state_next<=SAVE;
			end if;
		  else
		      state_next<=state_cur;
		  end if;
		elsif state_cur=SAVE then
				state_next<=OP;
		elsif state_cur=SAVE_extra then
				state_next<=FINISHED;
		elsif state_cur=FINISHED then
			state_next<=IDLE;
		end if;
	end process;
	
--------------------------------------------------------------------------------
--Output of each state
--------------------------------------------------------------------------------
	Operation_of_each_state: process(state_cur,addr_ram_r,cnt_r,addr_ram_w,web_s,IN_read) is begin
	option<='0';
	en_diag<='0'; 
	enable_MAC<='0';
	addr_ram<=addr_ram_w;
	rst_sumReg<='0';
    finish<='0';
    web_s<="11";
	cnt_n<=cnt_r;
	addr_ram_r_n<=addr_ram_r;
	addr_ram_w_n<=addr_ram_w;
		case state_cur is
			when IDLE =>

			  load_enable<='0';
				cnt_n<=(others=>'0');
				web_s<="11";
				-- goes to MAC unit sumReg_n<=(others=>'0'); 
				if IN_read='1'then
					addr_ram_r_n <='0' & IN_matrix & IN_matrix(2 downto 0);-- Because we save 9 rows for each matrix
				end if;
			when READ =>
				load_enable<='0';
				addr_ram<=addr_ram_r;
				if cnt_r(0)='1' then
					addr_ram_r_n<=addr_ram_r + '1';
				end if;
				cnt_n<=cnt_r+1;
				web_s<="10";
			when LOAD =>
				load_enable<='1';
			when OP =>
				if cnt_r(5 downto 0)<"001111" then -- This is to load while operating
					load_enable<='1';
				else
					load_enable<='0';
				end if;
				enable_MAC<='1';
				
				cnt_n<=cnt_r+1;
				web_s<="11";
								--diag_mean
				if cnt_r="000011" or cnt_r="010111" or cnt_r="101011" or cnt_r="111111" then
					en_diag<='1';
				end if;
				--
			when SAVE =>
				enable_MAC<='1';
				cnt_n<=cnt_r+1;
				if cnt_r(5 downto 0)<"001111" then -- This is to load while operating
					load_enable<='1';
				else
					load_enable<='0';
				end if;
			 	if cnt_r(2 downto 0)="000" then
			 			web_s<="00";
				    addr_ram_w_n<=addr_ram_w + 1;
				end if;
			 	rst_sumReg<='1';	
			when SAVE_extra =>
				load_enable<='0';
			  enable_MAC<='1';
				cnt_n<=cnt_r+1;
			 	web_s<="00";
				addr_ram_w_n<=addr_ram_w + 1;
			 	rst_sumReg<='1';
			when FINISHED =>
				load_enable<='0';
				enable_MAC<='1';
				cnt_n<=cnt_r;
				web_s<="00";
				finish<='1';
				addr_ram_w_n<=addr_ram_w + 1;
				option<='1';
		end case;
	end process;

--------------------------------------------------------------------------------
--Addressing
--------------------------------------------------------------------------------
	addr_rom<=cnt_r(3 downto 0);
	addr_In<=cnt_r(5 downto 4) & cnt_r(1 downto 0);

	web<=web_s;
  RAM_part<=cnt_r(2);






end Behavioral;

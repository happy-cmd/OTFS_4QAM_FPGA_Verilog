----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2023 05:13:03
-- Design Name: 
-- Module Name: RandomBitGenerator - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RandomBitGenerator is
    port(
        Clk : in std_logic;
        SRst : in std_logic;
        Start : in std_logic;
        ModulationOrder : in std_logic_vector(2 downto 0);
        RandomBitValid : out std_logic;
        RandomBit : out std_logic
    );
end RandomBitGenerator;

architecture Behavioral of RandomBitGenerator is
    
    type StateType is (IDLE, GO);
    signal State : StateType := IDLE;
    
    signal ShiftReg : std_logic_vector(15 downto 0) := (others => '1');
    signal BitCount : integer range 0 to 32767 := 0;
    
    signal NumberOfBits : std_logic_vector(15 downto 0) := (others => '0');

begin
    
    process(Clk)
    begin
        if rising_edge(Clk) then
            RandomBitValid <= '0';
            RandomBit <= '0'; 
            if (SRst = '1') then
                State <= IDLE;
                ShiftReg <= (Others => '1');
            else
                case State is
                    when IDLE =>
                        State <= IDLE;
                        BitCount <= 0;
                        if (Start = '1') then
                            State <= GO;
                            if(ModulationOrder = "000") then       -- M = 4
                                NumberOfBits <= std_logic_vector(to_unsigned(4096*2,16));
                            elsif(ModulationOrder = "001") then    -- M = 8
                                NumberOfBits <= std_logic_vector(to_unsigned(4096*3,16));
                            elsif(ModulationOrder = "010") then    -- M = 16
                                NumberOfBits <= std_logic_vector(to_unsigned(4096*4,16));
                            elsif(ModulationOrder = "011") then    -- M = 32
                                NumberOfBits <= std_logic_vector(to_unsigned(4096*5,16));
                            else                                   -- M = 32
                                NumberOfBits <= std_logic_vector(to_unsigned(4096*5,16));
                            end if;
                        end if;
                        
                    when GO =>
                        ShiftReg <= (ShiftReg(0) xor ShiftReg(2) xor ShiftReg(3) xor ShiftReg(5)) & ShiftReg(15 downto 1);
                        RandomBitValid <= '1';
                        RandomBit <= (ShiftReg(0) xor ShiftReg(2) xor ShiftReg(3) xor ShiftReg(5));
                        BitCount <= BitCount + 1;
                        if (BitCount = to_integer(unsigned(NumberOfBits)) - 1) then
                            State <= IDLE;
                        end if;
                        
                    when others => 
                        State <= IDLE;
                        
                end case;
            end if;
        end if; 
    end process;
    
end Behavioral;

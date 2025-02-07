----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2023 05:45:12
-- Design Name: 
-- Module Name: QAMModulator - Behavioral
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

entity QAMModulator_32QAM is
    port(
        Clk : in std_logic;
        SRst : in std_logic;
        Start : in std_logic;
        DataValidIn : in std_logic;
        Data : in std_logic;
        ModDataOutValid : out std_logic;
        FrameBeginnigIndicator : out std_logic;
        FrameNum : out std_logic_vector(7 downto 0);
        DataNum : out std_logic_vector(7 downto 0);
        ModDataOutRe : out std_logic_vector(11 downto 0);
        ModDataOutIm : out std_logic_vector(11 downto 0)
    );
end QAMModulator_32QAM;

architecture Behavioral of QAMModulator_32QAM is
    
    -- 32 QAM
    type Bit2SymbolLUT_32QAM is array (0 to 31) of std_logic_vector(11 downto 0);
    constant Bit2Symbol_Re_32QAM : Bit2SymbolLUT_32QAM := (std_logic_vector(to_signed(-687,12)),   -- 00000
                                                           std_logic_vector(to_signed(-229,12)),   -- 00001
                                                           std_logic_vector(to_signed(-687,12)),   -- 00010
                                                           std_logic_vector(to_signed(-229,12)),   -- 00011
                                                           std_logic_vector(to_signed(-1145,12)),  -- 00100
                                                           std_logic_vector(to_signed(-1145,12)),  -- 00101
                                                           std_logic_vector(to_signed(-1145,12)),  -- 00110
                                                           std_logic_vector(to_signed(-1145,12)),  -- 00111
                                                           std_logic_vector(to_signed(-229,12)),   -- 01000
                                                           std_logic_vector(to_signed(-229,12)),   -- 01001
                                                           std_logic_vector(to_signed(-229,12)),   -- 01010
                                                           std_logic_vector(to_signed(-229,12)),   -- 01011
                                                           std_logic_vector(to_signed(-687,12)),   -- 01100
                                                           std_logic_vector(to_signed(-687,12)),   -- 01101
                                                           std_logic_vector(to_signed(-687,12)),   -- 01110
                                                           std_logic_vector(to_signed(-687,12)),   -- 01111
                                                           std_logic_vector(to_signed(687,12)),    -- 10000
                                                           std_logic_vector(to_signed(229,12)),    -- 10001
                                                           std_logic_vector(to_signed(687,12)),    -- 10010
                                                           std_logic_vector(to_signed(229,12)),    -- 10011
                                                           std_logic_vector(to_signed(1145,12)),   -- 10100
                                                           std_logic_vector(to_signed(1145,12)),   -- 10101
                                                           std_logic_vector(to_signed(1145,12)),   -- 10110
                                                           std_logic_vector(to_signed(1145,12)),   -- 10111
                                                           std_logic_vector(to_signed(229,12)),    -- 11000
                                                           std_logic_vector(to_signed(229,12)),    -- 11001
                                                           std_logic_vector(to_signed(229,12)),    -- 11010
                                                           std_logic_vector(to_signed(229,12)),    -- 11011
                                                           std_logic_vector(to_signed(687,12)),    -- 11100
                                                           std_logic_vector(to_signed(687,12)),    -- 11101
                                                           std_logic_vector(to_signed(687,12)),    -- 11110
                                                           std_logic_vector(to_signed(687,12))     -- 11111
                                                           );
    constant Bit2Symbol_Im_32QAM : Bit2SymbolLUT_32QAM := (std_logic_vector(to_signed(1145,12)),   -- 00000
                                                           std_logic_vector(to_signed(1145,12)),   -- 00001
                                                           std_logic_vector(to_signed(-1145,12)),  -- 00010
                                                           std_logic_vector(to_signed(-1145,12)),  -- 00011
                                                           std_logic_vector(to_signed(687,12)),    -- 00100
                                                           std_logic_vector(to_signed(229,12)),    -- 00101
                                                           std_logic_vector(to_signed(-687,12)),   -- 00110
                                                           std_logic_vector(to_signed(-229,12)),   -- 00111
                                                           std_logic_vector(to_signed(687,12)),    -- 01000
                                                           std_logic_vector(to_signed(229,12)),    -- 01001
                                                           std_logic_vector(to_signed(-687,12)),   -- 01010
                                                           std_logic_vector(to_signed(-229,12)),   -- 01011
                                                           std_logic_vector(to_signed(687,12)),    -- 01100
                                                           std_logic_vector(to_signed(229,12)),    -- 01101
                                                           std_logic_vector(to_signed(-687,12)),   -- 01110
                                                           std_logic_vector(to_signed(-229,12)),   -- 01111
                                                           std_logic_vector(to_signed(1145,12)),   -- 10000
                                                           std_logic_vector(to_signed(1145,12)),   -- 10001
                                                           std_logic_vector(to_signed(-1145,12)),  -- 10010
                                                           std_logic_vector(to_signed(-1145,12)),  -- 10011
                                                           std_logic_vector(to_signed(687,12)),    -- 10100
                                                           std_logic_vector(to_signed(229,12)),    -- 10101
                                                           std_logic_vector(to_signed(-687,12)),   -- 10110
                                                           std_logic_vector(to_signed(-229,12)),   -- 10111
                                                           std_logic_vector(to_signed(687,12)),    -- 11000
                                                           std_logic_vector(to_signed(229,12)),    -- 11001
                                                           std_logic_vector(to_signed(-687,12)),   -- 11010
                                                           std_logic_vector(to_signed(-229,12)),   -- 11011
                                                           std_logic_vector(to_signed(687,12)),    -- 11100
                                                           std_logic_vector(to_signed(229,12)),    -- 11101
                                                           std_logic_vector(to_signed(-687,12)),   -- 11110
                                                           std_logic_vector(to_signed(-229,12))    -- 11111
                                                           );
    
    constant FRAME_LEN : integer := 64;
    constant FRAME_COUNT : integer := 64;
    
    type StateType is (IDLE, Gen32QAM);
    signal State : StateType := IDLE;
    
    signal CurrBitCount : integer range 0 to 15 := 0;
    signal CurrBits : std_logic_vector(4 downto 0) := (others => '0'); 
    signal DataCount : std_logic_vector(15 downto 0);
    
begin
    
    FrameNum <= DataCount(13 downto 6);
    DataNum <= "00" & DataCount(5 downto 0);
    
    process(Clk)
        variable TempBits : std_logic_vector(4 downto 0);
    begin
        if rising_edge(Clk) then
            ModDataOutValid <= '0';
            ModDataOutRe <= (others => '0');
            ModDataOutIm <= (others => '0');
            FrameBeginnigIndicator <= '0';
            if (SRst = '1') then
                State <= IDLE;
            else
                case State is
                    when IDLE =>
                        DataCount <= (others => '1');
                        CurrBitCount <= 0;
                        CurrBits <= (others => '0');
                        State <= IDLE;
                        if (Start = '1') then      
                                State <= Gen32QAM;
                        end if;
                                
                    when Gen32QAM =>
                        if (DataValidIn = '1') then
                            CurrBitCount <= CurrBitCount + 1;
                            CurrBits <= CurrBits(3 downto 0) & Data;
                            TempBits := CurrBits(3 downto 0) & Data;
                            if (CurrBitCount = 4) then -- depends on modulation order
                                CurrBitCount <= 0;
                                ModDataOutValid <= '1';
                                ModDataOutRe <= Bit2Symbol_Re_32QAM(to_integer(unsigned(TempBits(4 downto 0))));    
                                ModDataOutIm <= Bit2Symbol_Im_32QAM(to_integer(unsigned(TempBits(4 downto 0))));
                                DataCount <= std_logic_vector(unsigned(DataCount) + 1);
                                if (unsigned(DataCount) = 4094) then
                                    State <= IDLE;
                                end if;   
                            end if;
                        end if; 
                                
                    when others =>
                        State <= IDLE;    
                end case;
            end if;
        end if;
    end process;

end Behavioral;

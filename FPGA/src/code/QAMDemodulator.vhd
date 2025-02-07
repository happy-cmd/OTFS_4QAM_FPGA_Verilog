----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.05.2023 10:04:09
-- Design Name: 
-- Module Name: QAMDemodulator - Behavioral
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

entity QAMDemodulator is
    port(
        Clk : in std_logic;
        
        OTFSRxDemodValid : in std_logic;
        OTFSRxDemodRe : in std_logic_vector(23 downto 0);
        OTFSRxDemodIm : in std_logic_vector(23 downto 0);
        
        QAMDemodDataValid : out std_logic;
        QAMDemodData : out std_logic_vector(4 downto 0) 
    );
end QAMDemodulator;

architecture Behavioral of QAMDemodulator is

begin

    process(Clk)
    begin
        if rising_edge(Clk) then
            QAMDemodDataValid <= '0';
            QAMDemodData <= (others => '0');
            if (OTFSRxDemodValid = '1') then
                QAMDemodDataValid <= '1';
                if (signed(OTFSRxDemodRe) < -1832) then
                    if (signed(OTFSRxDemodIm) < -1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(6,5));
                    elsif (signed(OTFSRxDemodIm) < -916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(6,5));
                    elsif (signed(OTFSRxDemodIm) < 0) then
                        QAMDemodData <= std_logic_vector(to_unsigned(7,5));
                    elsif (signed(OTFSRxDemodIm) < 916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(5,5));
                    elsif (signed(OTFSRxDemodIm) < 1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(4,5));
                    else
                        QAMDemodData <= std_logic_vector(to_unsigned(4,5));
                    end if;
                elsif (signed(OTFSRxDemodRe) < -916) then
                    if (signed(OTFSRxDemodIm) < -1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(2,5));
                    elsif (signed(OTFSRxDemodIm) < -916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(14,5));
                    elsif (signed(OTFSRxDemodIm) < 0) then
                        QAMDemodData <= std_logic_vector(to_unsigned(15,5));
                    elsif (signed(OTFSRxDemodIm) < 916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(13,5));
                    elsif (signed(OTFSRxDemodIm) < 1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(12,5));
                    else
                        QAMDemodData <= std_logic_vector(to_unsigned(0,5));
                    end if;
                elsif (signed(OTFSRxDemodRe) < 0) then
                    if (signed(OTFSRxDemodIm) < -1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(3,5));
                    elsif (signed(OTFSRxDemodIm) < -916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(10,5));
                    elsif (signed(OTFSRxDemodIm) < 0) then
                        QAMDemodData <= std_logic_vector(to_unsigned(11,5));
                    elsif (signed(OTFSRxDemodIm) < 916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(9,5));
                    elsif (signed(OTFSRxDemodIm) < 1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(8,5));
                    else
                        QAMDemodData <= std_logic_vector(to_unsigned(1,5));
                    end if;
                elsif (signed(OTFSRxDemodRe) < 916) then
                    if (signed(OTFSRxDemodIm) < -1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(19,5));
                    elsif (signed(OTFSRxDemodIm) < -916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(26,5));
                    elsif (signed(OTFSRxDemodIm) < 0) then
                        QAMDemodData <= std_logic_vector(to_unsigned(27,5));
                    elsif (signed(OTFSRxDemodIm) < 916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(25,5));
                    elsif (signed(OTFSRxDemodIm) < 1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(24,5));
                    else
                        QAMDemodData <= std_logic_vector(to_unsigned(17,5));
                    end if;
                elsif (signed(OTFSRxDemodRe) < 1832) then
                    if (signed(OTFSRxDemodIm) < -1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(18,5));
                    elsif (signed(OTFSRxDemodIm) < -916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(30,5));
                    elsif (signed(OTFSRxDemodIm) < 0) then
                        QAMDemodData <= std_logic_vector(to_unsigned(31,5));
                    elsif (signed(OTFSRxDemodIm) < 916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(29,5));
                    elsif (signed(OTFSRxDemodIm) < 1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(28,5));
                    else
                        QAMDemodData <= std_logic_vector(to_unsigned(16,5));
                    end if;
                else
                    if (signed(OTFSRxDemodIm) < -1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(22,5));
                    elsif (signed(OTFSRxDemodIm) < -916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(22,5));
                    elsif (signed(OTFSRxDemodIm) < 0) then
                        QAMDemodData <= std_logic_vector(to_unsigned(23,5));
                    elsif (signed(OTFSRxDemodIm) < 916) then
                        QAMDemodData <= std_logic_vector(to_unsigned(21,5));
                    elsif (signed(OTFSRxDemodIm) < 1832) then
                        QAMDemodData <= std_logic_vector(to_unsigned(20,5));
                    else
                        QAMDemodData <= std_logic_vector(to_unsigned(20,5));
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;

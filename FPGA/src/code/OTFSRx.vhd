----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2023 14:03:14
-- Design Name: 
-- Module Name: OTFSRx - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OTFSRx is
    port(
        Clk : in std_logic;
        Srst : in std_logic;
        Start : in std_logic;
        
        RecSigDataValid : in std_logic;
        RecSigRe : in std_logic_vector(15 downto 0);
        RecSigIm : in std_logic_vector(15 downto 0);
        
        OTFSRxDemodValid : out std_logic;
        OTFSRxDemodRe : out std_logic_vector(23 downto 0);
        OTFSRxDemodIm : out std_logic_vector(23 downto 0);
        
        QAMDemodDataValid : out std_logic;
        QAMDemodData : out std_logic_vector(4 downto 0) 
    );
end OTFSRx;

architecture Behavioral of OTFSRx is
    
    component OTFSDemodulator is
        port(
            Clk : in std_logic;
            Srst : in std_logic;
            Start : in std_logic;
            
            RecSigDataValid : in std_logic;
            RecSigRe : in std_logic_vector(15 downto 0);
            RecSigIm : in std_logic_vector(15 downto 0);
                    
            OTFSRxDemodValid : out std_logic;
            OTFSRxDemodRe : out std_logic_vector(23 downto 0);
            OTFSRxDemodIm : out std_logic_vector(23 downto 0)
        );
    end component;
    
    component QAMDemodulator is
        port(
            Clk : in std_logic;
            
            OTFSRxDemodValid : in std_logic;
            OTFSRxDemodRe : in std_logic_vector(23 downto 0);
            OTFSRxDemodIm : in std_logic_vector(23 downto 0);
            
            QAMDemodDataValid : out std_logic;
            QAMDemodData : out std_logic_vector(4 downto 0) 
        );
    end component;
    
    signal OTFSRxDemodValidReg : std_logic;
    signal OTFSRxDemodReReg : std_logic_vector(23 downto 0);
    signal OTFSRxDemodImReg : std_logic_vector(23 downto 0);
    
begin
    
    U0 : OTFSDemodulator
        port map(
            Clk => Clk,
            Srst => Srst,
            Start => Start,
            
            RecSigDataValid => RecSigDataValid,
            RecSigRe => RecSigRe,
            RecSigIm => RecSigIm,
            OTFSRxDemodValid => OTFSRxDemodValidReg,
            OTFSRxDemodRe => OTFSRxDemodReReg,
            OTFSRxDemodIm => OTFSRxDemodImReg
        );
    
    OTFSRxDemodValid <= OTFSRxDemodValidReg;
    OTFSRxDemodRe <= OTFSRxDemodReReg;
    OTFSRxDemodIm <= OTFSRxDemodImReg;
    U1 : QAMDemodulator
        port map(
            Clk => Clk,
            
            OTFSRxDemodValid => OTFSRxDemodValidReg,
            OTFSRxDemodRe => OTFSRxDemodReReg,
            OTFSRxDemodIm => OTFSRxDemodImReg,
            
            QAMDemodDataValid => QAMDemodDataValid,
            QAMDemodData => QAMDemodData
        );

end Behavioral;

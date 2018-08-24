library verilog;
use verilog.vl_types.all;
entity Crossbar is
    port(
        clk             : in     vl_logic;
        master_req      : in     vl_logic_vector(1 downto 0);
        master_addr     : in     vl_logic;
        master_cmd      : in     vl_logic_vector(1 downto 0);
        master_wdata    : in     vl_logic;
        master_rdata    : out    vl_logic;
        master_ack      : out    vl_logic_vector(1 downto 0);
        slave_ack       : in     vl_logic_vector(1 downto 0);
        slave_addr      : out    vl_logic;
        slave_rdata     : in     vl_logic;
        slave_wdata     : out    vl_logic;
        slave_cmd       : out    vl_logic_vector(1 downto 0)
    );
end Crossbar;

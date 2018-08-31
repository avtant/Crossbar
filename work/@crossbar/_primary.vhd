library verilog;
use verilog.vl_types.all;
entity Crossbar is
    generic(
        count           : integer := 2
    );
    port(
        clk             : in     vl_logic;
        master_req      : in     vl_logic;
        master_addr     : in     vl_logic;
        master_cmd      : in     vl_logic;
        master_wdata    : in     vl_logic;
        master_rdata    : out    vl_logic;
        master_ack      : out    vl_logic;
        slave_ack       : in     vl_logic;
        slave_addr      : out    vl_logic;
        slave_wdata     : out    vl_logic;
        slave_rdata     : in     vl_logic;
        slave_cmd       : out    vl_logic
    );
end Crossbar;

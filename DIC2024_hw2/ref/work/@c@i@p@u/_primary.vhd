library verilog;
use verilog.vl_types.all;
entity CIPU is
    generic(
        IDLE            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        READ            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        FIFO_OUT        : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        LIFO_OUT        : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        \OUT\           : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        people_thing_in : in     vl_logic_vector(7 downto 0);
        ready_fifo      : in     vl_logic;
        ready_lifo      : in     vl_logic;
        thing_in        : in     vl_logic_vector(7 downto 0);
        thing_num       : in     vl_logic_vector(3 downto 0);
        valid_fifo      : out    vl_logic;
        valid_lifo      : out    vl_logic;
        valid_fifo2     : out    vl_logic;
        people_thing_out: out    vl_logic_vector(7 downto 0);
        thing_out       : out    vl_logic_vector(7 downto 0);
        done_thing      : out    vl_logic;
        done_fifo       : out    vl_logic;
        done_lifo       : out    vl_logic;
        done_fifo2      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of FIFO_OUT : constant is 1;
    attribute mti_svvh_generic_type of LIFO_OUT : constant is 1;
    attribute mti_svvh_generic_type of \OUT\ : constant is 1;
end CIPU;

interface intf;
  logic clk;
  logic rst;
  logic Newd;
  logic rwbar;
  logic [7:0] wdata;
  logic [7:0] rdata;
  logic [6:0] addr;
  logic done;
  logic sclk_ref;
endinterface
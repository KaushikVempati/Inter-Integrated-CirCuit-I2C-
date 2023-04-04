// Code your testbench here
// or browse Examples
`include "transaction.sv"
`include "interface.sv"
`include "gen.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"



module tb;
   
  gen gen1;
  dri drv;
  monitor mon;
  scoreboard sco;
  
  
 // event nextgd;
  //event nextgs;
 
  
  mailbox #(transaction) gen2driv, mon2scb;
 
  
  intf vif();
  
  I2C_top dut (vif.clk, vif.rst,  vif.Newd, vif.rwbar, vif.wdata, vif.addr, vif.rdata, vif.done);
 
  initial begin
    vif.clk <= 0;
  end
  
  always #5 vif.clk <= ~vif.clk;
  
   initial begin
   
     
    gen2driv = new();
    mon2scb = new();
    
     gen1 = new(gen2driv,vif);
     drv = new(mon2scb);
    
     mon = new(mon2scb);
     sco = new(mon2scb);
 
    gen1.count = 20;
  
    drv.vif = vif;
    mon.vif = vif;
    
   // gen.drvnext = nextgd;
   // drv.drvnext = nextgd;
    
   // gen.sconext = nextgs;
   // sco.sconext = nextgs;
  
   end
  
  task pre_test;
  drv.reset();
  endtask
  
  task test;
    fork
      gen1.run();
      drv.run();
      mon.run();
      sco.run();
    join_any  
  endtask
  
  
  task post_test;
    wait(gen1.done.triggered);
    $finish();    
  endtask
  
  task run();
    pre_test;
    test;
    post_test;
  endtask
  
  initial begin
    run();
  end
   
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,tb);   
  end
 
assign vif.sclk_ref = dut.e1.sclk_ref;   
  
endmodule
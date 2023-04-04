class dri;
  trans t;
  mailbox #(trans) gen2driv;
  
  virtual intf vif;
  
  function new(mailbox #(trans) gen2driv,virtual intf vif);
    this.gen2driv = gen2driv;
    this.vif = vif;
  endfunction
  
  task reset();
    vif.rst <= 1'b1;
    vif.Newd <= 1'b0;
     vif.rwbar <= 1'b0;
    vif.wdata <= 0;
    vif.addr  <= 0;
    repeat(10) @(posedge vif.clk);
    vif.rst <= 1'b0;
    repeat(5) @(posedge vif.clk);
    $display("[DRV] : RESET DONE"); 
  endtask
  
  task run();
    forever begin
      gen2driv.get(t);
      @(posedge vif.sclk_ref);
      
      vif.rst <= 1'b0;
      vif.Newd <= 1'b1;
      vif.rwbar <= t.rwbar;
      vif.wdata <= t.wdata;
      vif.rdata <= t.rdata;
      vif.addr <= t.addr;
      
      
      @(posedge vif.sclk_ref);
      vif.Newd <= 1'b0;
      
      
      wait(vif.done == 1'b1);
      @(posedge vif.sclk_ref);
      wait(vif.done == 1'b0);
      
      $display("rwbar=%0b wdata=%0d rdata=%0d waddr=%0d ",vif.rwbar,vif.wdata,vif.rdata,vif.addr);
      
    end
  endtask
  
endclass
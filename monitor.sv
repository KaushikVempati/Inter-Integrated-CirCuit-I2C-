class monitor;
  virtual intf vif;
  mailbox #(trans) mon2scb;
  
  function new(mailbox #(trans) mon2scb,virtual intf vif);
    this.mon2scb = mon2scb;
    this.vif = vif;
  endfunction
  
  task run();
    $display("Monitor starting time %0t",$time);
    t = new();
    
    forever begin
      @(posedge vif.sclk_ref);
      if(vif.Newd == 1'b1) begin
        if(vif.rwbar == 1'b0) begin
        t.rwbar = vif.rwbar;
          t.wdata = vif.wdata;
          t.addr = vif.addr;
          
          @(posedge vif.sclk_ref);
          wait(vif.done == 1'b1);
          t.data = vif.rdata;
          
          repeat(2) @(posedge vif.sclk_ref);
          $display("monitor : rdata=%0d addr=%0d",t.rdata,t.addr);
        end
      else begin
        t.rwbar = vif.rwbar;
        t.wdata = vif.wdata;
        t.addr = vif.addr;
        
        @(posedge vif.sclk_ref);
        wait(vif.done == 1'b1);
        
        t.rdata = vif.rdata;
        
        $display("wdata=%0d addr=%0d",t.wdata,t.addr);
      end
        
        mon2scb.put(t);
      end
      
    end
  endtask
    
  
endclass
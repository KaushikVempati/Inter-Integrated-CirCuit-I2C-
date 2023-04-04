class scoreboard;
  
  transaction t;
  
  mailbox #(transaction) mon2scb;
  
  //event sconext;
  
  bit [7:0] reg1;
  
  bit [7:0] data[128] = '{default:0};
  
 
  
  function new( mailbox #(transaction) mon2scb );
    this.mon2scb = mon2scb;
  endfunction
  
  
  task run();
    
    forever begin
      
      mbxms.get(t);
      
      t.display("SCOreboard");
      
      if(t.rwbar == 1'b1)
        begin
          
          data[t.addr] = t.wdata;
          
          $display("DATA STORED ADDR : %0d DATA : %0d", t.addr, t.wdata);
        end
       else 
        begin
         reg1 = data[t.addr];
          
          if( (t.rdata == reg1) )
            $display("DATA READ -> Data Matched");
         else
            $display("DATA READ -> DATA MISMATCHED");
       end
      
        
     // ->sconext;
    end 
  endtask
  
  
endclass
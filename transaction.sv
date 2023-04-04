class trans;
  bit Newd;
  rand bit rwbar;
  rand bit [7:0] wdata;
  rand bit[6:0] addr;
  bit [7:0] rdata;
  bit done;
  
  constraint addr1{addr >1 ;addr <24;};
  
  function trans copy();
    copy = new();
    copy.Newd = this.Newd;
    copy.rwbar = this.rwbar;
    copy.wdata = this.wdata;
    copy.addr = this.addr;
    copy.rdata = this.rdata;
    copy.done = this.done;
  endfunction
  
  function void display();
    $display("rwbar =%0b wdata=%0d rdata = %0d done = %0b ",rwbar,wdata,rdata,done);
  endfunction
    
  
endclass
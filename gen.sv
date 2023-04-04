class gen;
  trans t;
  mailbox #(trans) gen2driv;
  event done;
  //event drvnxt;
  //event sconxt;

  int count = 0;
  function new(mailbox #(trans) gen2driv);
    this.gen2driv = gen2driv;
    t = new();
  endfunction
  
  
  task run();
    repeat(count) begin
      t.randomize();
      gen2driv.put(t.copy);
      $display("%0t wdata=%0d rdata=%0d done=%0b ",$time,t.a,t.b,t.c)
    end
    -> done;
  endtask
endclass
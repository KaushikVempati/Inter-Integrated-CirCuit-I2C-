
module I2C_top(
    input clk,
    input rst,
    input Newd,
    input rwbar,
    input [7:0] wdata,
    output [7:0] rdata,
    input [6:0] addr,
    output done

);
wire sdac;
wire sclc;
wire ackc;

i2cocntroller #(depth =4) e1(.clk(clk),.rst(rst),.newd(Newd),.rwbar(rwbar),.ack(ackc),.addr(addr),.scl(sclc),.sda(sdac),.wdata(wdata),.rdata(rdata),.done(done));

i2cmem #(Depth = 7) mem1(.clk(clk).rst(rst),.scl(sclc),.sda(sdac),.ack(ackc));

endmodule

module i2cocntroller #(parameter depth = 4)(
    input clk,
    input rst,
    input newd,
    input rwbar,
    input ack,
    input [6:0] addr,
    output scl,
    inout sda,
    input [7:0] wdata,
    output reg [7:0] rdata,
    output reg done,
 
);

reg [7:0] mem [2**depth-1:0];
reg scltemp,sdatemp;
reg donetemp;
reg sda_en = 0;
reg [7:0] addrtemp;
reg sclk_ref = 0;
int count = 0;
int i = 0;
reg [3:0] state;
parameter [3:0] Newd = 4'b0000,
                write = 4'b0001,
                writestart = 4'b0010,
                wraddr = 4'b0011,
                waddrack = 4'b0100,
                wdata1 = 4'b0101,
                wdataack = 4'b0110,
                wstop = 4'b0111
                //read = 4'b1000,
                readaddr = 4'b1000,
                rdata1 = 4'b1001,
                readack = 4'b1010,
                rdataack = 4'b1011,
                rstop = 4'b1100;


always @(posedge clk) begin
    if(count <=9) begin
        count <= count+1;
    end
    else begin
        count <= 0;
        sclk_ref <= ~sclk_ref;
    end
end


always @(posedge sclk_ref,posedge rst) begin
     if(rst) begin
        scltemp <= 1'b0;
        sdatemp <= 1'b0;
        donetemp <= 1'b0;
     end
     else begin
        case(state)
        Newd: begin
            //sdatemp <= 1'b0;
            done <= 1'b0;
            sda_en <= 1'b1;
            scltemp <= 1'b1;
            sdatemp <= 1'b1;
            if(Newd == 1'b1)
             state <= writestart; 
            else 
             state <= Newd;
        end
       
       // Write operation
       writestart: begin
           sdatemp <= 1'b0;
           scltemp <= 1'b1;
           state <= write;
           addrtemp <= {addr,rwbar};
       end

       write: begin
           if(rwbar == 1'b1) begin
            state <= wraddr;
            sdatemp <= addrtemp[0];
            i <= 1;
           end
           else begin
            state <= readaddr;
            sdatemp <= addrtemp[0];
            i <= 1;
           end
       end

       wraddr : begin
            if(i <= 7) begin
                sdatemp <= addrtemp [i];
                i <= i+1;
            end
            else begin
                i <= 0;
                state <= waddrack;
            end
       end

       waddrack : begin
          if(ack == 1'b1) begin
             state <= wdata1;
             sdatemp <= wdata[0];
             i <= i+1;
          end
          else begin
              state <= waddrack;
          end
       end

       wdata1: begin
          if(i <= 7) begin
             i <= i+1;
             sdatemp <= wdata[i];
          end
          else begin
              i <= 0;
              state <= wdataack;
          end
       end

       wdataack: begin
          if(ack == 1'b1) begin
             state <= wstop;
             sdatemp <= 1'b0;
             scltemp <= 1'b1;
          end
          else begin
             state <= wdataack;
          end
       end

       wstop: begin
          sdatemp <= 1'b1;
          state <= Newd;
          done <= 1'b1;
       end

       // Read operation

       readaddr: begin
              if(i <= 7) begin
                sdatemp <= addrtemp[i];
                i <= i+1;
              end
              else begin
                 i <= 0;
                 state <= readack;
              end
       end
     
      readack: begin
        if(ack == 1'b1) begin
            state <= rdata1;
            sda_en <= 1'b0;
        end
        else begin
            state <= readack;
        end
      end   

      rdata1: begin
        if(i <= 7) begin
            i <= i+1;
            state <= rdata1;
            rdata[i] <= sda;
        end
        else begin
             i <= 0;
            state <= rstop;
            scltemp <= 1'b1;
            sdatemp <= 1'b0;
        end
      end  

      rstop: begin
           sdatemp <= 1'b1;
           done <= 1;
           state <= Newd;
      end

      default: state <= Newd;
        endcase
     end

end

assign scl = ((state == writestart) || (state == wstop) || (state == rstop)) ? scltemp : sclk_ref;

assign sda = (sda_en == 1'b1) ? sdatemp : 1'bz;

endmodule



// I2C Memory module

module i2cmem #(parameter Depth =7)(
    input clk,
    input rst,
    input scl,
    inout sda,
    output reg ack
);
reg [7:0] mem[2**Depth-1:0];
reg [7:0] addrin;
reg [7:0] datain;
reg [7:0] datard;
reg sda_en = 0;


int i=0;
int count =0;
reg sclk_ref = 0;
reg sdar;

reg [3:0] state1;

parameter [3:0] start = 3'b000,
                 store_addr = 3'b001,
                 ack_addr = 3'b010,
                 store_data = 3'b011,
                 data_ack = 3'b100,
                 stop     = 3'b101,
                 read_data = 3'b110;

always @(posedge clk) begin
    if(count <= 9) begin
        count <= count+1;
    end
    else begin
        count <= 0;
        sclk_ref <= ~sclk_ref;
    end
end

always @(posedge sclk_ref,posedge rst) begin
    if(rst) begin
        for(int j=0;j<127;j++) begin
            mem[j] <= 8'h0;
        end
        sda_en <= 1'b1;
    end
    else begin
        case(state) 
        start: begin
            sda_en <= 1'b1;   // Read
            if((scl == 1'b1) && (sda == 1'b0)) begin
                state <= store_addr;
            end
            else begin
                state <= start;
            end
        end

        store_addr: begin
            sda_en <= 1'b1;
            if( i == 7) begin
                i <= i+1;
                addrin[i] <= sda;
            end
            else begin
                state <= ack_addr;
                datard <= mem[addrin[7:1]];
                ack <= 1'b1;
                i <= 0;
            end
        end

        ack_addr: begin
              ack <= 1'b0;
             if(addrin[0] == 1'b1) begin
                state <= store_data;
                sda_en <= 1'b1;
             end
             else begin
                state <= read_data;
                i <= 1;
                sda_en <= 1'b0;
                sdar <= datard[0];
             end
        end

        store_data: begin
             if(i <= 7) begin
                i < = i+1;
                datain[i] <= sda;
             end
             else begin
                state <= data_ack;
                ack <= 1'b1;
                i <= 0;
             end
        end

        data_ack: begin
             ack <= 1'b0;
             mem[addrin[7:1]] <= datain;
             state <= stop;
        end

        stop: begin
            sda_en <= 1'b1;
            if((scl == 1'b1) && (sda ==1'b1)) begin
            state <= start;
            end
            else begin
                state <= stop;
            end
        end
        
        read_data: begin
            sda_en <= 1'b0;
            if(i <= 7) begin
                i <= i+1;
                sdar <= datard[i];
            end
            else begin
                state <= stop;
                i<= 0;
                sda_en <= 1'b1;
            end
        end

        default: state <= start;

        endcase
    end
end

assign sda =( sda_en == 1'b1 ) ? 1'bz : sdar;

endmodule
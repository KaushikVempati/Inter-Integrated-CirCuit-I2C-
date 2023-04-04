// I2C interfacing with EEPROM using Virtex-5 FPGA

module i2c(
    clk1,   //FPGA clock
    scl,    // serial clock of master(FPGA)
    sdaout,
    sda,
    page_write,
    page_read,
    ack,
    nack,
    rw,
    dataout,
    sclout
);
input clk1;   // FPGA clock
reg clk2;     // EEPROM clock
input reset;

input page_write;   // If page_write = 1, then write 1 single page of 16 byte data
input page_read;    // If page_read = 1, read 1 page data and display 

inout sda;      // SDA is bidirectional I2C signal
output scl;  //  400KHZ I2C clock

output sdaout;  // EEPROM output same as SDA
output sclout;

reg sda_h;
reg scl_h;

input rw;   // Read-write control signal

output reg ack;  // acknowledgement signal
output reg nack; // no acknowledgement signal
output reg [7:0] dataout; // EEPROM output sent serially

reg [7:0] datain = 8'b10110011; // first 4bits = slave address, E2=0(FIXED), {A9,A8} ={00,01,10,11} R0,R1,R2,R3 Last bit=RW bit);
reg [7:0] slave_addr_write = 8'b10100010;
reg [7:0] slave_addr_read = 8'b10100011;
reg [7:0] reg_addr = 8'b00001010;


reg [4:0] page_write_counter = 16;
reg [4:0] page_read_counter = 16;
reg [7:0] state;
reg [3:0] bit_counter = 8;
reg [7:0] clk_count = 0;
reg [3:0] count1  = 4;
reg [3:0] count2  = 4;
reg [3:0] count3  = 4;

// STATES OF FSM I2C-EEPROM
parameter idle = 8'b0,
start_cond = 8'b00000001,
start_cond_wait = 8'b00000010,
slave_addr = 8'b00000011,
slave_addr_addr = 8'b00000100,
slave_addr_idle = 8'b00000101,
ack_slave_addr  = 8'b00000110,
ack_slave_wait  = 8'b00000111,
reg_addr        = 8'b00001000,
reg_addr_addr   = 8'b00001001,
ack_reg_addr    = 8'b00001010,
ack_reg_wait    = 8'b00001011,
repeat_cond     = 8'b00001100,
data_write      = 8'b00001101,
data_write_wait = 8'b00001110,
ack_reg_data    = 8'b00001111,
ack_reg_wait    = 8'b00010000,
stop_write      = 8'b00010001,
stop_wr_idle    = 8'b00010010,
stop_wr_done    = 8'b00010011,
repeat_idle     = 8'b00010100,
repeat_done     = 8'b00010101,
data_read       = 8'b00010110,
data_r_con      = 8'b00010111,
data_r_ack      = 8'b00011000,
data_r_ack_wait = 8'b00011001,
eeprom_out      = 8'b00011010,
eeprom_out_ack  = 8'b00011011,
eeprom_out_wait = 8'b00011100,
page_read_ctrl  = 8'b00011101,
mutliple_read   = 8'b00011110,
send_stop       = 8'b00011111,
send_stop_idle  = 8'b00100000,
send_stop_wait  = 8'b00100001,
send_stop_done  = 8'b00100010,
start_idle      = 8'b00100011,
start_idle1     = 8'b00100100,
start_idle2     = 8'b00100101,
start_idle3     = 8'b00100110,














assign sda = sda_h ? 1'bz : 1'b0;

assign scl = scl_h ? 1'bz : 1'b0;

assign sdaout = sda;
assign sclout = scl;


always @(posedge clk1 or posedge reset) begin
    if(reset) begin
        clk2 <= 1;
    end
    else begin
        if(clk_count > 24) && (clk_count < 49) begin
            clk2 <= 1;
            clk_count <= clk_count + 1;
        end
        else begin
            clk2 <= 0;
            clk_count <= clk_count + 1;
        end
        if(clk_count > 49)
        clk_count <= 1;
    end
end





;
 
 



endmodule
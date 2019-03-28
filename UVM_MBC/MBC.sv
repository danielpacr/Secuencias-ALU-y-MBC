// max = max number of address lines required to address the max capacity of the RAM in bytes
module mbc #(parameter max = 11) (
  input clk,
  input reset,
  input [24:0] address,
  input [31:0] d_write,
  input b,
  input h,
  input enable,
  input r_w,
  input [63:0] d_pop,
  input pndng,
  input [31:0] q,
  output logic [31:0] d_read,
  output logic [max-3:0] a,
  output logic [31:0] d,
  output logic [64:0] d_psh,
  output logic psh,
  output logic mem_rdy,
  output logic pop_mbc,
  output logic error_drs,
  output logic clk_mem,
  output logic cen,
  output logic sl,
  output logic wen
);

logic cond;
logic [3:0] cond_sel;
logic error_adrs;
logic bad_addrs;
logic to_io;
logic up_mem;
logic mslgn;
logic mh;
logic mw;
logic cln_rd;
logic keep_boot;
logic spi;
logic boot_end;
logic finish_boot;
logic HoB;
logic cln_wd;

////////////////////////////////////////////////////////////
// Lógica para el decodificador de condiciones de control //
////////////////////////////////////////////////////////////

assign to_io = (address[24:22] == 0)?0:1;
assign up_mem = (address[21:max] == 0)?0:1;
assign bad_addrs = to_io & up_mem;
assign mh = h & address[0];
assign mw = ~h &~b & (address[1] | address[0]);
assign mslgn = mh | mw;
assign error_adrs = bad_addrs | mslgn;
assign cln_rd = ~(to_io | error_adrs |r_w);
assign spi = (d_pop[61:60]==1)?1:0;
assign boot_end = (d_pop[59:57] == 3)?1:0;
assign keep_boot = ~boot_end & spi;
assign finish_boot = boot_end &spi;
assign HoB = h|b;
assign cln_wd = ~(to_io |error_adrs | r_w | b | h);

always_comb begin
  case (cond_sel)
    0: begin
      cond = keep_boot;
    end
    1: begin
      cond = finish_boot;
    end
    2: begin
      cond = pndng;
    end
    3: begin
      cond = enable;
    end
    4: begin
      cond = error_adrs;
    end
    5: begin
      cond = HoB;
    end
    6: begin
      cond = r_w;
    end
    7: begin
      cond = to_io;
    end
    8: begin
      cond = cln_rd;
    end
    9: begin
      cond = cln_wd;
    end
    default: begin
      cond = 3;
    end
  endcase
end

// Logica para la memoria
logic boot;
logic [31:0] proc_write;
logic [31:0] d_read_pre;
logic ld_d_read;
assign clk_mem = ~clk&~cen;

assign a = (boot)?d_pop[33+max:34]:address[max-1:2];
assign d =(boot)?d_pop[31:0]:proc_write[31:0];

always_comb begin
  case({b,h}) 
    0: begin
      proc_write = d_write[31:0];
    end
    1: begin
      proc_write = (address[1])?{d_write[15:0],d_read[15:0]}:{d_read[31:16],d_write[15:0]};
    end
    2: begin
      case(address[1:0])
        0:begin
           proc_write = {d_read[31:8],d_write[7:0]};
        end
        1:begin
           proc_write = {d_read[31:16],d_write[7:0],d_read[7:0]};
        end
        2:begin
           proc_write = {d_read[31:24],d_write[7:0],d_read[15:0]};
        end
        3:begin
           proc_write = {d_write[7:0],d_read[23:0]};
        end
      endcase
    end
    default : begin
      proc_write = 0;
    end
  endcase

  case({b,h})
    0:begin
      d_read_pre = q[31:0];
    end
    1:begin
      d_read_pre = (address[1])?{{16{1'b0}},q[15:0]}:{{16{1'b0}},q[31:16]};
    end
    2:begin
      case(address[1:0])
        0: begin
          d_read_pre = {{24{1'b0}},q[7:0]};
        end
        1: begin
          d_read_pre = {{24{1'b0}},q[15:8]};
        end
        2: begin
          d_read_pre = {{24{1'b0}},q[23:16]};
        end
        3: begin
          d_read_pre = {{24{1'b0}},q[31:24]};
        end
      endcase
    end
  endcase
end


always@(ld_d_read) begin
  if(reset) begin
    d_read <=0;
  end else begin
    d_read <= d_read_pre;
  end
end


parameter bt_init=0;
parameter bt_psh=4;
parameter bt_png=6;
parameter bt_kp=8;
parameter bt_wr=9;
parameter bt_pop=10;
parameter bt_fns=11;
parameter cln_fifo=19;
parameter mem_rdy_st=1;
parameter mem_cln_rd=3;
parameter mem_cln_wd=7;
parameter mem_op0=12;
parameter mem_io=13;
parameter mem_w_io=14;
parameter mem_op1=15;
parameter mem_r0=2;
parameter mem_w0=16;
parameter mem_w1=5;
parameter mem_w2=17;
parameter mem_error=18;

//////////////////////////////////////////
// Lógica para el push de datos al bus // ///////////////// modificado
/////////////////////////////////////////

always_comb begin
  if (boot==0) begin
  case(address[24:22])
    0,1:  d_psh[64:62] <= 1;
    2,3:  d_psh[64:62] <= 2;
    4,5,6,7: d_psh[64:62] <= 3;
  endcase
  end
//  else begin
//    d_psh[63:62] <= 3;
//  end
end
assign d_psh[61:60] = 0;
assign d_psh[59:57] = (boot)? 3'b111 :{r_w,h,b};
assign d_psh[56:32] = address[24:0];
assign d_psh[31:0]  = d_write[31:0];

////////////////////////
// Máquina de estados //
////////////////////////


// lógica de siguiente estado
reg [4:0]state;
always@(posedge clk or posedge reset)
if (reset) begin
  state= bt_init;
end else begin
  case(state)
    bt_init:      state = bt_psh;
    bt_psh:       state = bt_png;
    bt_png:       state = (cond)?bt_kp:bt_png;
    bt_kp:        state = (cond)?bt_wr:bt_fns;
    bt_wr:        state = bt_pop;
    bt_pop:       state = bt_psh;
    bt_fns:       state = (cond)?cln_fifo:bt_pop;
    cln_fifo:     state = mem_rdy_st;
    mem_rdy_st:      state = (cond)?mem_cln_rd:mem_rdy;
    mem_cln_rd:   state = (cond)?mem_r0:mem_cln_wd;
    mem_cln_wd:   state = (cond)?mem_w1:mem_op0;
    mem_op0:      state = (cond)?mem_error:mem_io;
    mem_io:       state = (cond)?mem_w_io:mem_op1;
    mem_w_io:     state = mem_rdy_st;
    mem_op1:      state = (cond)?mem_w0:mem_r0;
    mem_r0:       state = mem_rdy_st;
    mem_w0:       state = (cond)?mem_w2:mem_w1;
    mem_w1:       state = mem_rdy_st;
    mem_w2:       state = mem_w1;
    mem_error:    state = (cond)?mem_rdy_st:mem_error;
    default: state=bt_init;
  endcase
end
//lógica de salida
parameter s_keep_boot = 0;
parameter s_finish_boot = 1;
parameter s_pndng = 2;
parameter s_enable = 3;
parameter s_error_adrs = 4;
parameter s_HoB = 5;
parameter s_r_w = 6;
parameter s_to_io = 7;
parameter s_cln_rd = 8;
parameter s_cln_wd = 9;

always_comb begin
  case(state)
    bt_init: begin
      wen=1;
      cen=1;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_pndng;
    end
    bt_psh: begin 
      wen=1;
      cen=1;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=1;
      error_drs=0;
      cond_sel=s_pndng;
    end
    bt_png: begin 
      wen=1;
      cen=1;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_pndng;
    end
    bt_kp: begin 
      wen=1;
      cen=1;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_keep_boot;
    end
    bt_wr: begin 
      wen=0;
      cen=0;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_pndng;
    end
    bt_pop: begin 
      wen=1;
      cen=1;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=1;
      psh=0;
      error_drs=0;
      cond_sel=s_pndng;
    end
    bt_fns: begin 
      wen=1;
      cen=1;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_finish_boot;
    end
    cln_fifo: begin 
      wen=1;
      cen=1;
      boot=1;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=1;
      psh=0;
      error_drs=0;
      cond_sel=s_finish_boot;
    end
    mem_rdy_st: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=1;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_enable;
    end
    mem_cln_rd: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_cln_rd;
    end
    mem_cln_wd: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_cln_wd;
    end
    mem_op0: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_error_adrs;
    end
    mem_io: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_to_io;
    end
    mem_w_io: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=1;
      error_drs=0;
      cond_sel=s_enable;
    end
    mem_op1: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_r_w;
    end
    mem_r0: begin 
      wen=1;
      cen=0;
      boot=0;
      ld_d_read=1;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_enable;
    end
    mem_w0: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_HoB;
    end
    mem_w1: begin 
      wen=0;
      cen=0;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_enable;
    end
    mem_w2: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=1;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=0;
      cond_sel=s_enable;
    end
    mem_error: begin 
      wen=1;
      cen=1;
      boot=0;
      ld_d_read=0;
      mem_rdy=0;
      pop_mbc=0;
      psh=0;
      error_drs=1;
      cond_sel=s_enable;
    end
  endcase

end

assign sl =0;
 
endmodule

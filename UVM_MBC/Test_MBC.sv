`timescale 1ns / 1ps //o 10ps
`default_nettype none
`define MAX 13

`include "MBC.sv"
`include "XSPRAMLP_2048X32_M8P.sv"
`include "bus_interface.sv"
`include "mbc_cpu_interface.sv"
`include "mbc_ctrl_interface.sv"
`include "mbc_base_test.sv"
`include "mbc_tests.sv"

module Test_MBC;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit clk;
  bit reset;

    //---------------------------------------
  //clock generation
  //---------------------------------------
  always #25 clk = ~clk;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    reset = 1;
    #5 reset =0;
  end
  
     // conexiones de la memoria
        wire [31:0] Q;
        wire [31:0] d;
        wire [`MAX-3:0] a;
        wire clk_mem;
        wire cen;
        wire sl;
        wire wen;

  
  //---------------------------------------
  //interface instance
  //---------------------------------------
 bus_if intf_bus(clk,reset);
 mbc_ctrl_if intf_ctrl(clk,reset);
 mbc_cpu_if intf_cpu(clk,reset);
        

// Instantiate the Units Under Test (UUT) 
//recordar que la memoria también es un bloque instanciado

XSPRAMLP_2048X32_M8P Memoria_8K (
  .Q(Q),
  .D(d),
  .A(a),
  .CLK(clk_mem),
  .CEn(cen),
  .WEn(wen),
  .SL(sl),
  .RDY(RDY)// este RDY no se de donde salio hay que preguntarle a Ronny
);

mbc #(.max(13)) Memory_controller(
  .clk(clk),
  .reset(reset),
  .address(intf_cpu.address),
  .d_write(intf_cpu.d_write),
  .b(intf_ctrl.b),
  .h(intf_ctrl.h),
  .enable(intf_ctrl.enable),
  .r_w(intf_ctrl.r_w),
  .d_pop(intf_bus.d_pop),
  .pndng(intf_bus.pndng),
  .q(Q),
  .d_read(intf_cpu.d_read),
  .a(a),
  .d(d),
  .d_psh(intf_bus.d_psh),
  .psh(intf_bus.psh),
  .mem_rdy(intf_ctrl.mem_rdy),
  .pop_mbc(intf_bus.pop_mbc),
  .error_drs(intf_ctrl.error_drs),
  .clk_mem(clk_mem),
  .cen(cen),
  .sl(sl),
  .wen(wen)
);

  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual bus_if)::set(uvm_root::get(),"*","vif_bus",intf_bus);
    uvm_config_db#(virtual mbc_cpu_if)::set(uvm_root::get(),"*","vif_cpu",intf_cpu);
    uvm_config_db#(virtual mbc_ctrl_if)::set(uvm_root::get(),"*","vif_ctrl",intf_ctrl);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test();
    $display("COVERAGE DE D_POP_FUENTE: %0f",bus_if.bus.D_POP_FUENTE.get_coverage());
  end



endmodule // Test_MBC
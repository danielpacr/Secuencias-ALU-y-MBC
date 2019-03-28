//-------------------------------------------------------------------------
//						mbc_ctrl_interface
//-------------------------------------------------------------------------

interface mbc_ctrl_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  // - mbc_ctrl Interface - 
    logic mem_rdy;
    logic r_w;
    logic b;
    logic h;
    logic enable;
    logic error_drs;
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    input  mem_rdy;
    output r_w;
    output b;
    output h;
    output enable;
    input  error_drs;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    input mem_rdy;
    input r_w;
    input b;
    input h;
    input enable;
    input error_drs;
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
 //////////////////////Cobertura funcional: Daniel Palacios//////////////////////////
  covergroup CTRL @(negedge clk);

    ENABLE: coverpoint enable{
    bins high = {1};
    bins low = {0};
    }
    H: coverpoint h{
    bins high = {1};
    bins low = {0};
    }
    B: coverpoint b{
    bins high = {1};
    bins low = {0};
    }
    R_W: coverpoint r_w{
    bins high = {1};
    bins low = {0};
    }
    RDY: coverpoint mem_rdy{
    bins high = {1};
    bins low = {0};
    }         
    ERROR_DRS: coverpoint error_drs{
    bins high = {1};
    bins low = {0};
    }
    ENABLEXHXBXR_W: cross ENABLE, H, B, R_W;          
  endgroup: CTRL

  CTRL ctrl=new();
///////////////////////Fin cobertura funciona: Daniel Palacios/////////////////////////  
endinterface

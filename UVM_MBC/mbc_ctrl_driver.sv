//-------------------------------------------------------------------------
//						mbc_ctrl_driver
//-------------------------------------------------------------------------

class mbc_ctrl_driver extends uvm_driver #(mbc_ctrl_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual mbc_ctrl_if vif_ctrl;
  `uvm_component_utils(mbc_ctrl_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mbc_ctrl_if)::get(this, "", "vif_ctrl",vif_ctrl))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
    @(posedge vif_ctrl.DRIVER.clk);    

    vif_ctrl.driver_cb.r_w    <= req.r_w;
    vif_ctrl.driver_cb.b      <= req.b;
    vif_ctrl.driver_cb.h      <= req.h;
    vif_ctrl.driver_cb.enable <= req.enable;
//    @(posedge vif_ctrl.DRIVER.clk);
    
  endtask : drive
endclass : mbc_ctrl_driver

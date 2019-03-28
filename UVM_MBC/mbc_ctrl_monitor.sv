//-------------------------------------------------------------------------
//						mbc_ctrl_monitor
//-------------------------------------------------------------------------

class mbc_ctrl_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual mbc_ctrl_if vif_ctrl;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(mbc_ctrl_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  mbc_ctrl_seq_item trans_collected;
  bit is_active;

  `uvm_component_utils(mbc_ctrl_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);

    /*if (get_is_active() == UVM_ACTIVE) begin
      is_active = 1;
    end
    else begin
      is_active = 0;
    end*/
    if(get_full_name() == "mbc_base_test.env.mbc_tx_ctrl_agent_inst.monitor_TX") begin
      is_active = 1;
    end
    if(get_full_name() == "mbc_base_test.env.mbc_rx_ctrl_agent_inst.monitor_RX") begin
      is_active = 0;
    end

  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mbc_ctrl_if)::get(this, "", "vif_ctrl",vif_ctrl))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif_ctrl.MONITOR.clk);
      wait(vif_ctrl.monitor_cb.mem_rdy ||
           vif_ctrl.monitor_cb.r_w     ||
           vif_ctrl.monitor_cb.b       ||
           vif_ctrl.monitor_cb.h       ||
           vif_ctrl.monitor_cb.enable  ||
           vif_ctrl.monitor_cb.error_drs);
      if (is_active == 1) begin
        trans_collected.r_w    = vif_ctrl.monitor_cb.r_w;
      	trans_collected.b      = vif_ctrl.monitor_cb.b;
      	trans_collected.h      = vif_ctrl.monitor_cb.h;
        trans_collected.enable = vif_ctrl.monitor_cb.enable;
      end
      else begin
      	trans_collected.mem_rdy   = vif_ctrl.monitor_cb.mem_rdy;
        trans_collected.error_drs = vif_ctrl.monitor_cb.error_drs;
      end
      item_collected_port.write(trans_collected);

/*/////////////////////////////porcentajes de cobertura funcional para ctrl: Daniel Palacios/////////////////////
        $display("COVERAGE DE ENABLE: %0f",vif_ctrl.ctrl.ENABLE.get_coverage());
        $display("COVERAGE DE H: %0f",vif_ctrl.ctrl.H.get_coverage());
        $display("COVERAGE DE B: %0f",vif_ctrl.ctrl.B.get_coverage());
        $display("COVERAGE DE R/W: %0f",vif_ctrl.ctrl.R_W.get_coverage());
        $display("COVERAGE DE RDY: %0f",vif_ctrl.ctrl.RDY.get_coverage());
        $display("COVERAGE DE ERROR_DRS: %0f",vif_ctrl.ctrl.ERROR_DRS.get_coverage());        
/////////////////////////////FIN porcentajes de cobertura funcional para ctrl: Daniel Palacios/////////////////*/
    end 
  endtask : run_phase

endclass : mbc_ctrl_monitor

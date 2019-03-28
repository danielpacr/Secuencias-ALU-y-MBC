//-------------------------------------------------------------------------
//						mbc_cpu_monitor
//-------------------------------------------------------------------------

class mbc_cpu_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual mbc_cpu_if  vif_cpu;
//  virtual mbc_ctrl_if vif_ctrl;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(mbc_cpu_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  mbc_cpu_seq_item trans_collected;
  bit is_active;

  `uvm_component_utils(mbc_cpu_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);

    /*if (get_is_active() == UVM_ACTIVE) begin
    //if (parent.is_active == UVM_ACTIVE) begin
      is_active = 1;
    end
    else begin
      is_active = 0;
    end*/
    if(get_full_name() == "mbc_base_test.env.mbc_tx_cpu_agent_inst.monitor_TX") begin
      is_active = 1;
    end
    if(get_full_name() == "mbc_base_test.env.mbc_rx_cpu_agent_inst.monitor_RX") begin
      is_active = 0;
    end
    
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mbc_cpu_if)::get(this, "", "vif_cpu",vif_cpu))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    /*if(!uvm_config_db#(virtual mbc_ctrl_if)::get(this, "", "vif_ctrl",vif_ctrl))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});*/
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i=0;
    int o=0;
    forever begin
      @(posedge vif_cpu.MONITOR.clk);
      wait(//vif.monitor_cb.mtie        ||
           //vif.monitor_cb.meie        ||
           vif_cpu.monitor_cb.address     ||
           vif_cpu.monitor_cb.d_write      ||
           vif_cpu.monitor_cb.d_read  );
      if (is_active == 1) begin
        /*trans_collected.csr_io = vif.monitor_cb.csr_io;
      	trans_collected.mtie   = vif.monitor_cb.mtie;
      	trans_collected.meie   = vif.monitor_cb.meie;*/
        trans_collected.address   = vif_cpu.monitor_cb.address;
        trans_collected.d_write   = vif_cpu.monitor_cb.d_write;
      end
      else begin
      	trans_collected.d_read = vif_cpu.monitor_cb.d_read;
      end
      item_collected_port.write(trans_collected);

/////////////////////////////porcentajes de cobertura funcional para cpu: Daniel Palacios/////////////////////
        if (/*i==10000 || */o==645500) begin
//        $display("COVERAGE DE ADDRESS: %0f",vif_cpu.cpu.ADDRESS_IO.get_coverage());
//        $display("COVERAGE DE D_WRITE: %0f",vif_cpu.cpu.D_WRITE.get_coverage());
//        $display("COVERAGE DE D_READ: %0f",vif_cpu.cpu.D_READ.get_coverage());
        i=0;
        end
        i++;
        o++;
/////////////////////////////FIN porcentajes de cobertura funcional para cpu: Daniel Palacios/////////////////
    end 
  endtask : run_phase

endclass : mbc_cpu_monitor

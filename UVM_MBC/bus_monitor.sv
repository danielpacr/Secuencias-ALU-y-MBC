//-------------------------------------------------------------------------
//						bus_monitor
//-------------------------------------------------------------------------
 
class bus_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual bus_if vif_bus;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(bus_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  bus_seq_item trans_collected;
  bit is_active;

  `uvm_component_utils(bus_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);

    //no sirve identificar el monitor pasivo asi por que is_active no forma parte de de la clase uvm_component
    //is_active = new();
    /*if (parent.is_active == UVM_ACTIVE) begin
    //if (get_is_active() == UVM_ACTIVE) begin
      is_active = 1;
    end
    else begin
      is_active = 0;
    end*/
    if(get_full_name() == "mbc_base_test.env.mbc_tx_bus_agent_inst.monitor_TX") begin
      is_active = 1;
    end
    if(get_full_name() == "mbc_base_test.env.mbc_rx_bus_agent_inst.monitor_RX") begin
      is_active = 0;
    end    
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual bus_if)::get(this, "", "vif_bus",vif_bus))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    int i = 0;
    int o = 0;
    int change = 0;
    forever begin
      @(posedge vif_bus.MONITOR.clk);
      wait(vif_bus.monitor_cb.pndng   ||
           vif_bus.monitor_cb.pop_mbc ||
           //vif.monitor_cb.full    ||
           vif_bus.monitor_cb.psh);
      if (is_active == 1) begin
        trans_collected.pndng  = vif_bus.monitor_cb.pndng;
      	trans_collected.d_pop  = vif_bus.monitor_cb.d_pop;
      	//trans_collected.full   = vif.monitor_cb.full;
      end
      else begin
      	trans_collected.pop_mbc = vif_bus.monitor_cb.pop_mbc;
      	trans_collected.d_psh   = vif_bus.monitor_cb.d_psh;
      	trans_collected.psh     = vif_bus.monitor_cb.psh;
      end
      item_collected_port.write(trans_collected);

/////////////////////////////porcentajes de cobertura funcional para bus: Daniel Palacios/////////////////////
        if (/*i==10000 || */(o == 300028 && change == 0) || (o== 400 && change ==1)) begin
//        $display("COVERAGE DE D_POP_DESTINO: %0f",vif_bus.bus.D_POP_DESTINO.get_coverage());
        $display("COVERAGE DE D_POP_FUENTE: %0f",vif_bus.bus.D_POP_FUENTE.get_coverage());
        $display("COVERAGE DE D_POP_CODE: %0f",vif_bus.bus.D_POP_CODE.get_coverage());
        $display("COVERAGE DE D_POP_ADDRESS: %0f",vif_bus.bus.D_POP_ADDRESS.get_coverage());  
        $display("COVERAGE DE D_POP_DATA: %0f",vif_bus.bus.D_POP_DATA.get_coverage());

        $display("COVERAGE DE D_PUSH_DESTINO: %0f",vif_bus.bus.D_PUSH_DESTINO.get_coverage());
        $display("COVERAGE DE D_PUSH_FUENTE: %0f",vif_bus.bus.D_PUSH_FUENTE.get_coverage());
        $display("COVERAGE DE D_PUSH_CODE: %0f",vif_bus.bus.D_PUSH_CODE.get_coverage());
        $display("COVERAGE DE D_PUSH_ADDRESS: %0f",vif_bus.bus.D_PUSH_ADDRESS.get_coverage());  
        $display("COVERAGE DE D_PUSH_DATA: %0f",vif_bus.bus.D_PUSH_DATA.get_coverage());        

        $display("COVERAGE DE PUSH: %0f",vif_bus.bus.PUSH.get_coverage());
        $display("COVERAGE DE POP_MBC: %0f",vif_bus.bus.POP.get_coverage());
        $display("COVERAGE DE PNDNG: %0f",vif_bus.bus.PNDNG.get_coverage());    
        i = 0;
        o = 0;
        change =1;
        end
        i++;    
        o++;
/////////////////////////////FIN porcentajes de cobertura funcional para bus: Daniel Palacios/////////////////

    end 
  endtask : run_phase

endclass : bus_monitor

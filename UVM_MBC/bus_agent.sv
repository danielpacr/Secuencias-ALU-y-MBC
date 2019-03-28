//-------------------------------------------------------------------------
//						bus_agent
//-------------------------------------------------------------------------

`include "bus_seq_item.sv"
`include "bus_sequencer.sv"
`include "bus_sequence_lib.sv"
`include "bus_driver.sv"
`include "bus_monitor.sv"

class bus_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  bus_driver     driver;
  bus_sequencer  sequencer;
  bus_monitor    monitor;

  `uvm_component_utils(bus_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    



    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver    = bus_driver::type_id::create("driver", this);
      sequencer = bus_sequencer::type_id::create("sequencer", this);
      monitor = bus_monitor::type_id::create("monitor_TX", this);      
    end
    else monitor = bus_monitor::type_id::create("monitor_RX", this);    
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : bus_agent
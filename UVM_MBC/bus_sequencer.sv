//-------------------------------------------------------------------------
//						bus_sequencer - 
//-------------------------------------------------------------------------

class bus_sequencer extends uvm_sequencer#(bus_seq_item);

  `uvm_component_utils(bus_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
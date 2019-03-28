//-------------------------------------------------------------------------
//						MBC_TESTs Desarrollado por Daniel Palacios  
//-------------------------------------------------------------------------
class mbc_mayor_test extends mbc_base_test;

  `uvm_component_utils(mbc_mayor_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  bus_initial_sequence seq_initial_bus;
  cpu_initial_sequence seq_initial_cpu;

  cpu_write_read_complete_sequence seq_wr_rd_cpu;
  ctrl_write_read_complete_sequence seq_wr_rd_ctrl;

  cpu_write_read_one_sequence seq_wr_rd_one_cpu;
  ctrl_write_read_one_sequence seq_wr_rd_one_ctrl;

  cpu_write_read_two_sequence seq_wr_rd_two_cpu;
  ctrl_write_read_two_sequence seq_wr_rd_two_ctrl;

  cpu_paquete_perifericos_sequence seq_pq_cpu;
  ctrl_paquete_perifericos_sequence seq_pq_ctrl;

  cpu_bad_ads_sequence seq_bd_cpu;
  ctrl_bad_ads_sequence seq_bd_ctrl;

  cpu_desalineado_sequence seq_desalineado_cpu;
  ctrl_desalineado_sequence seq_desalineado_ctrl;
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "mbc_mayor_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the sequence
    seq_initial_bus = bus_initial_sequence::type_id::create("seq_initial_bus");
    seq_initial_cpu = cpu_initial_sequence::type_id::create("seq_initial_cpu");

    seq_wr_rd_cpu = cpu_write_read_complete_sequence::type_id::create("seq_wr_rd_cpu");    
    seq_wr_rd_ctrl = ctrl_write_read_complete_sequence::type_id::create("seq_wr_rd_ctrl");

    seq_wr_rd_one_cpu = cpu_write_read_one_sequence::type_id::create("seq_wr_rd_one_cpu");    
    seq_wr_rd_one_ctrl = ctrl_write_read_one_sequence::type_id::create("seq_wr_rd_one_ctrl");

    seq_wr_rd_two_cpu = cpu_write_read_two_sequence::type_id::create("seq_wr_rd_two_cpu");    
    seq_wr_rd_two_ctrl = ctrl_write_read_two_sequence::type_id::create("seq_wr_rd_two_ctrl");

    seq_pq_cpu = cpu_paquete_perifericos_sequence::type_id::create("seq_pq_cpu");
    seq_pq_ctrl = ctrl_paquete_perifericos_sequence::type_id::create("seq_pq_ctrl");

    seq_bd_cpu = cpu_bad_ads_sequence::type_id::create("seq_bd_cpu");
    seq_bd_ctrl = ctrl_bad_ads_sequence::type_id::create("seq_bd_ctrl");

    seq_desalineado_cpu = cpu_desalineado_sequence::type_id::create("seq_desalineado_cpu");
    seq_desalineado_ctrl = ctrl_desalineado_sequence::type_id::create("seq_desalineado_ctrl");
  

  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
    fork
      seq_initial_cpu.start(env.mbc_tx_cpu_agent_inst.sequencer);
      seq_initial_bus.start(env.mbc_tx_bus_agent_inst.sequencer);
    join
    fork
      seq_wr_rd_cpu.start(env.mbc_tx_cpu_agent_inst.sequencer);
      seq_wr_rd_ctrl.start(env.mbc_tx_ctrl_agent_inst.sequencer);     
    join
    fork
      seq_wr_rd_one_cpu.start(env.mbc_tx_cpu_agent_inst.sequencer);
      seq_wr_rd_one_ctrl.start(env.mbc_tx_ctrl_agent_inst.sequencer);     
    join
    fork
      seq_wr_rd_two_cpu.start(env.mbc_tx_cpu_agent_inst.sequencer);
      seq_wr_rd_two_ctrl.start(env.mbc_tx_ctrl_agent_inst.sequencer);     
    join    
    fork
      seq_pq_cpu.start(env.mbc_tx_cpu_agent_inst.sequencer);
      seq_pq_ctrl.start(env.mbc_tx_ctrl_agent_inst.sequencer);     
    join
    fork
      seq_bd_cpu.start(env.mbc_tx_cpu_agent_inst.sequencer);
      seq_bd_ctrl.start(env.mbc_tx_ctrl_agent_inst.sequencer);     
    join
    fork
      seq_desalineado_cpu.start(env.mbc_tx_cpu_agent_inst.sequencer);
      seq_desalineado_ctrl.start(env.mbc_tx_ctrl_agent_inst.sequencer);     
    join

    phase.drop_objection(this);
    
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase
  
endclass : mbc_mayor_test
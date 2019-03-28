//=========================================================================
// bus sequence library Desarrollado por Daniel Palacios  
//=========================================================================

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Se generan valores y paquetes para realizar el boot del sistema luego de un reset.
class bus_boot_sequence extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(bus_boot_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "bus_boot_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    int anterior = 42950;
    int addss = 0; // para recorrido de direccion  
    for (int cuenta=0; cuenta<50000/*3*/; cuenta++) begin    
      repeat(3) begin
        req = bus_seq_item::type_id::create("req");
        wait_for_grant();
        req.pndng = 1;
//        req.d_pop[63:62] = 0;
        req.d_pop[61:60] = 1;
        req.d_pop[59:57] = $urandom_range(7,0);
        if (req.d_pop[59:57] == 3) req.d_pop[59:57] = 4; // esto para evitar que envie un boot_end
        req.d_pop[56:45] = 0;             
        req.d_pop[44:32] = addss;
//        req.d_pop[56:43] = 0;       
//        req.d_pop[42:34] = addss;
//        req.d_pop[33:32] = 0;
        req.d_pop[31:0] = anterior;
        send_request(req);
        wait_for_item_done();
      end
      anterior = anterior + $urandom_range(/*90000*/85900,42950/*80000*/);
      addss = addss +1;
      if (addss == 8192) addss = 0; 
      repeat(3) begin // se limpia D_pop del bus 
        req = bus_seq_item::type_id::create("req");
        wait_for_grant();
        req.pndng = 0;
//        req.d_pop[63:62] = 0;
        req.d_pop[61:60] = 0;
        req.d_pop[59:57] = 0;
        req.d_pop[56:32] = 0;
        req.d_pop[31:0] = 0;
        send_request(req);
        wait_for_item_done();
      end
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Se generan valores y paquetes para finalizar el boot del sistema.
class bus_boot_end_sequence extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(bus_boot_end_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "bus_boot_end_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(3) begin
      req = bus_seq_item::type_id::create("req");
      wait_for_grant();
      req.pndng = 1;
//      req.d_pop[63:62] = 0;
      req.d_pop[61:60] = 1;
      req.d_pop[59:57] = 3; //boot_end
      req.d_pop[56:32] = 0;
      req.d_pop[31:0] = 0;
      send_request(req);
      wait_for_item_done();
    end  
    req = bus_seq_item::type_id::create("req");
    wait_for_grant();
    req.pndng = 0;
//    req.d_pop[63:62] = 0;
    req.d_pop[61:60] = 0;
    req.d_pop[59:57] = 0;
    req.d_pop[56:32] = 0;
    req.d_pop[31:0] = 0;
    send_request(req);
    wait_for_item_done();
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Esta secuencia se hace unicamente con la intencion de ser utilizada en bus_initial_sequence
// para probar que la MBC descarte los paquetes de otros perifericos distintos al SPI durante
// el boot_load y para cubrir los porcentajes de cobertura de las distintas fuentes de D_POP
class bus_perifericos_sequence extends uvm_sequence#(bus_seq_item);
  
  `uvm_object_utils(bus_perifericos_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "bus_perifericos_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    for (int cuenta=0; cuenta<3; cuenta++) begin
      repeat(3) begin
        req = bus_seq_item::type_id::create("req");
        wait_for_grant();
        req.pndng = 1;
//        req.d_pop[63:62] = 0;
        req.d_pop[61:60] = cuenta + 1;
        req.d_pop[59:57] = $urandom_range(7,0);
        req.d_pop[56:32] = 25'b0000000000000000000000000;
        req.d_pop[31:0] = $urandom_range(32'hFFFFFFFF,32'h00000000);
        send_request(req);
        wait_for_item_done();
      end
      repeat(3) begin
        req = bus_seq_item::type_id::create("req");
        wait_for_grant();
        req.pndng = 0;
//        req.d_pop[63:62] = 0;
        req.d_pop[61:60] = 0;
        req.d_pop[59:57] = 0;
        req.d_pop[56:32] = 0;
        req.d_pop[31:0] = 0;
        send_request(req);
        wait_for_item_done();
      end
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Se realiza la secuencia de inicializacion del MBC y se aprovecha para generar multiples valores
// que cubran los porcentajes de cobertura

class bus_initial_sequence extends uvm_sequence#(bus_seq_item);

  bus_boot_sequence         seq_boot;
  bus_perifericos_sequence  seq_perifericos;
  bus_boot_end_sequence     seq_boot_end;
  
  `uvm_object_utils(bus_initial_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "bus_initial_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
//////////////////////////////////////////////////////////////////////////
// esta seccion es solo para que el primer paquete que vea si sea del SPI
    repeat(4) begin
      req = bus_seq_item::type_id::create("req");
      wait_for_grant();
      req.pndng = 1;
//      req.d_pop[63:62] = 0;
      req.d_pop[61:60] = 1;
      req.d_pop[59:57] = 4;
      req.d_pop[56:32] = 0;
      req.d_pop[31:0] = 0;
      send_request(req);
      wait_for_item_done();
    end 
    repeat(3) begin // se limpia D_pop del bus 
      req = bus_seq_item::type_id::create("req");
      wait_for_grant();
      req.pndng = 0;
//      req.d_pop[63:62] = 0;
      req.d_pop[61:60] = 0;
      req.d_pop[59:57] = 0;
      req.d_pop[56:32] = 0;
      req.d_pop[31:0] = 0;
      send_request(req);
      wait_for_item_done();
    end
//////////////////////////////////////////////////////////////////////////
    `uvm_do(seq_perifericos)
    `uvm_do(seq_boot)
    `uvm_do(seq_boot_end)
  endtask
endclass
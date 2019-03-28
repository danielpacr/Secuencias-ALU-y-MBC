//=========================================================================
// mbc_cpu sequence library Desarrollado por Daniel Palacios  
//=========================================================================
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Secuencia hecha para funcionar de manera paralela con bus_boot y aprovechar el cubrimiento de
// porcentajes de cobertura en data de D_push y ahorrar iteraciones o secuencias extras para cubrirla
class cpu_initial_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(cpu_initial_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "cpu_initial_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    int anterior = 42950;
    int n = 0;
    for (int cuenta=0; cuenta<50005/*8*/; cuenta++) begin
      if (cuenta == 0) n = 5; 
      else n = 6;
      repeat(n) begin
        req = mbc_cpu_seq_item::type_id::create("req");
        wait_for_grant();
        req.address = 25'b0000000000000000000000000;
        req.d_write = anterior;
        send_request(req);
        wait_for_item_done();
      end
      anterior = anterior + $urandom_range(/*90000*/85900,42950/*80000*/); 
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Secuencia para escribir un dato completo en memoria y seguidamente leerlo 
class cpu_write_read_complete_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(cpu_write_read_complete_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "cpu_write_read_complete_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int anterior = 42950;
      int addss = 0; // para recorrido de direccion 
    for (int cuenta=0; cuenta<50000/*3*/; cuenta++) begin
      repeat(14) begin
        req = mbc_cpu_seq_item::type_id::create("req");
        wait_for_grant();
        req.address[24:22] = 0; //io
        req.address[21:13] = 0; // region indefinida       
        req.address[12:2] = addss; // direccion de memoria RAM
        req.address[1:0] = 0; // idenficador de byte
        req.d_write = anterior;
        //req.randomize();
        send_request(req);
        wait_for_item_done();
      end
      anterior = anterior + $urandom_range(/*90000*/90000,62950/*80000*/);
      addss = addss +1;
      if (addss == 2048) addss = 0;  
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// secuencia para escribir y leer un unico byte
class cpu_write_read_one_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(cpu_write_read_one_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "cpu_write_read_one_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int addss = 0;
      int write = 0;
    for (int cuenta=0; cuenta<4; cuenta++) begin
      repeat(15) begin
        req = mbc_cpu_seq_item::type_id::create("req");
        wait_for_grant();
        req.address[24:22] = 0; //io
        req.address[21:13] = 0; // region indefinida       
        req.address[12:2] = addss; // direccion de memoria RAM, se limita a 512 por error de declaracion  "max" en DUT, si se utilizan mas bits podria causar bad_address
        req.address[1:0] = cuenta; // idenficador de byte
        req.d_write = write;
        //req.randomize();
        send_request(req);
        wait_for_item_done();
      end
      addss = $urandom_range(2048,0);
      write = $urandom_range(32'hFFFFFFFF,0); 
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// secuencia para escribir y leer dos bytes
class cpu_write_read_two_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(cpu_write_read_two_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "cpu_write_read_two_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int addss = 0;
      int write = 0;
    for (int cuenta=0; cuenta<4; cuenta++) begin
      repeat(15) begin
        req = mbc_cpu_seq_item::type_id::create("req");
        wait_for_grant();
        req.address[24:22] = 0; //io
        req.address[21:13] = 0; // region indefinida       
        req.address[12:2] = addss; 
        req.address[1:0] = cuenta; // idenficador de byte
        req.d_write = write;
        //req.randomize();
        send_request(req);
        wait_for_item_done();
      end
      addss = $urandom_range(2048,0);
      write = $urandom_range(32'hFFFFFFFF,0); 
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Secuencia para enviar paquetes a perifericos - diseñada para cubrir principalmente puntos de cobertura
// de destino y bits superiores de address de d_push
class cpu_paquete_perifericos_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(cpu_paquete_perifericos_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "cpu_paquete_perifericos_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int periferico = 1; // para recorrido de io
      int addss = 0;
      int write = 0;
    for (int cuenta=0; cuenta<500/*3*/; cuenta++) begin
      repeat(8) begin
        req = mbc_cpu_seq_item::type_id::create("req");
        wait_for_grant();
        req.address[24:22] = periferico; //io
        req.address[21:13] = 0; // region indefinida       
        req.address[12:2] = addss; 
        req.address[1:0] = 0; // idenficador de byte
        req.d_write = write;
        //req.randomize();
        send_request(req);
        wait_for_item_done();
      end
      addss = $urandom_range(511,0); // direccion de memoria RAM, se limita a 512 por error de declaracion  "max" en DUT, si se utilizan mas bits podria causar bad_address
      write = $urandom_range(32'hFFFFFFFF,0);
      periferico = periferico +1;
      if (periferico == 8) periferico = 1;  
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Secuencia para forzar error_drs por bad_address - diseñada para cubrir principalmente puntos de cobertura
// de de region indefinida y bandera error_drs
class cpu_bad_ads_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(cpu_bad_ads_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "cpu_bad_ads_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int ur = 1; // para recorrido de region indefinida
      int write = 0;
      int addss = 0;
      int periferico = 1;
    for (int cuenta=0; cuenta<1000/*3*/; cuenta++) begin
      repeat(8) begin
        req = mbc_cpu_seq_item::type_id::create("req");
        wait_for_grant();
        req.address[24:22] =  periferico;//io
        req.address[21:13] = ur; // region indefinida       
        req.address[12:2] = addss; // direccion de memoria RAM
        req.address[1:0] = 0; // idenficador de byte
        req.d_write = write;
        //req.randomize();
        send_request(req);
        wait_for_item_done();
      end
      ur = ur +1;
      periferico = $urandom_range(7,1);
      addss = $urandom_range(2047,0);
      write = $urandom_range(32'hFFFFFFFF,0);
      if (ur == 512) ur = 1;  
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// Secuencia para forzar error_drs poniendo por direccion desalineada 
class cpu_desalineado_sequence extends uvm_sequence#(mbc_cpu_seq_item);
  
  `uvm_object_utils(cpu_desalineado_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "cpu_desalineado_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int ur = 0; // para recorrido de region indefinida
      int write = 0;
      int addss = 0;
      int periferico = 0;
      int num_byte = 0;
    for (int recorrido=0; recorrido<2; recorrido++) begin 
      for (int cuenta=0; cuenta<3; cuenta++) begin
        if(recorrido == 0) num_byte = cuenta + 1;
        else begin
          if (cuenta == 0 || cuenta ==2) num_byte = cuenta + 1;
          else num_byte = cuenta;
        end  
        repeat(8) begin
          req = mbc_cpu_seq_item::type_id::create("req");
          wait_for_grant();
          req.address[24:22] =  periferico;//io
          req.address[21:13] = ur; // region indefinida       
          req.address[12:2] = addss; // direccion de memoria RAM
          req.address[1:0] = num_byte; // idenficador de byte
          req.d_write = write;
          //req.randomize();
          send_request(req);
          wait_for_item_done();
        end
        ur = $urandom_range(511,0);
        periferico = $urandom_range(7,0);
        addss = $urandom_range(2047,0);
        write = $urandom_range(32'hFFFFFFFF,0); 
      end
    end
  endtask
endclass
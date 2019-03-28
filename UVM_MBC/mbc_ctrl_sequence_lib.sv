//=========================================================================
// mbc_ctrl sequence library  Desarrollado por Daniel Palacios  
//=========================================================================
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para escribir un dato completo
class mbc_ctrl_write_complet_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(mbc_ctrl_write_complet_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_write_complet_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 1; //escribir
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(8) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 1;
      req.b = 0;
      req.h = 0;
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(2) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end      
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para leer un dato completo
class mbc_ctrl_read_complet_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(mbc_ctrl_read_complet_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_read_complet_sequence");
    super.new(name);
  endfunction
  
  virtual task body();     
    repeat(3) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para escribir y luego leer un dato completo
class ctrl_write_read_complete_sequence extends uvm_sequence#(mbc_ctrl_seq_item);

  mbc_ctrl_write_complet_sequence write_complet;
  mbc_ctrl_read_complet_sequence read_complet;
  
  `uvm_object_utils(ctrl_write_read_complete_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ctrl_write_read_complete_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
  for (int cuenta=0; cuenta<50000/*3*/; cuenta++) begin
    `uvm_do(write_complet)
    `uvm_do(read_complet)
  end
  endtask
endclass

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para escribir un byte
class mbc_ctrl_write_one_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(mbc_ctrl_write_one_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_write_one_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 1; //escribir
      req.b = 1;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(9) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 1;
      req.b = 1;
      req.h = 0;
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(2) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end      
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para leer un byte
class mbc_ctrl_read_one_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(mbc_ctrl_read_one_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_read_one_sequence");
    super.new(name);
  endfunction
  
  virtual task body();     
    repeat(3) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 1;
      req.h = 0;
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para escribir y luego leer un byte
class ctrl_write_read_one_sequence extends uvm_sequence#(mbc_ctrl_seq_item);

  mbc_ctrl_write_one_sequence write_one;
  mbc_ctrl_read_one_sequence read_one;
  
  `uvm_object_utils(ctrl_write_read_one_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ctrl_write_read_one_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
  for (int cuenta=0; cuenta<4; cuenta++) begin
    `uvm_do(write_one)
    `uvm_do(read_one)
  end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para escribir dos bytes
class mbc_ctrl_write_two_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(mbc_ctrl_write_two_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_write_two_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 1; //escribir
      req.b = 0;
      req.h = 1;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(9) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 1;
      req.b = 0;
      req.h = 1;
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(2) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end      
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para leer dos bytes
class mbc_ctrl_read_two_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(mbc_ctrl_read_two_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mbc_ctrl_read_two_sequence");
    super.new(name);
  endfunction
  
  virtual task body();     
    repeat(3) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 1;
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para escribir y luego leer dos bytes
class ctrl_write_read_two_sequence extends uvm_sequence#(mbc_ctrl_seq_item);

  mbc_ctrl_write_two_sequence write_two;
  mbc_ctrl_read_two_sequence read_two;
  
  `uvm_object_utils(ctrl_write_read_two_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ctrl_write_read_two_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
  for (int cuenta=0; cuenta<4; cuenta++) begin
    `uvm_do(write_two)
    `uvm_do(read_two)
  end
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para enviar un paquete a perifericos - diseñada para cubrir puntos
// de cobertura en codigo de d_push 
class ctrl_paquete_perifericos_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(ctrl_paquete_perifericos_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ctrl_paquete_perifericos_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int gen_rand = 0;
      int mant_b = 0;
      int mant_h = 0;
      int mant_rw = 0;
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done();   
  for (int cuenta=0; cuenta<500/*3*/; cuenta++) begin  
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(6) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      if (gen_rand == 0) begin
        req.randomize();
        mant_b = req.b;
        mant_h = req.h;
        mant_rw = req.r_w;
        gen_rand = 1;
      end
      else begin  
      req.r_w = mant_rw;
      req.b = mant_b;
      req.h = mant_h;
      end
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
    gen_rand = 0;
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end
  end        
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para poner a prueba la bandera error_address - diseñada para 
// de manera especifica evaluar el error cuando se da por bad_address 
class ctrl_bad_ads_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(ctrl_bad_ads_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ctrl_bad_ads_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int gen_rand = 0;
      int mant_b = 0;
      int mant_h = 0;
      int mant_rw = 0;
      repeat(2) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done();
      end   
  for (int cuenta=0; cuenta<1000/*3*/; cuenta++) begin  
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(4) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      if (gen_rand == 0) begin
        req.randomize();
        mant_b = req.b;
        mant_h = req.h;
        mant_rw = req.r_w;
        gen_rand = 1;
      end
      else begin  
      req.r_w = mant_rw;
      req.b = mant_b;
      req.h = mant_h;
      end
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
    gen_rand = 0;
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 1; 
      send_request(req);
      wait_for_item_done(); 
    end
    repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done(); 
    end        
  end        
  endtask
endclass
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
// se ponen las entradas de control para poner a prueba la bandera error_address - diseñada para 
// de manera especifica evaluar el error cuando se da por bad_address 
class ctrl_desalineado_sequence extends uvm_sequence#(mbc_ctrl_seq_item);
  
  `uvm_object_utils(ctrl_desalineado_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ctrl_desalineado_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
      int rw = 0;
      int val_b = 0;
      int val_h = 0;
      repeat(1) begin
      req = mbc_ctrl_seq_item::type_id::create("req");
      wait_for_grant();
      //req.randomize();
      req.r_w = 0;
      req.b = 0;
      req.h = 0;
      req.enable = 0; 
      send_request(req);
      wait_for_item_done();
      end
    for (int recorrido= 0; recorrido<2; recorrido++) begin
      if (recorrido == 0) begin
        val_b = 0;
        val_h = 0;
      end   
      else if (recorrido == 1) begin
        val_b = 0;
        val_h = 1;
      end     
      for (int cuenta=0; cuenta<3; cuenta++) begin  
        repeat(1) begin
          req = mbc_ctrl_seq_item::type_id::create("req");
          wait_for_grant();
          //req.randomize();
          req.r_w = 0;
          req.b = 0;
          req.h = 0;
          req.enable = 0; 
          send_request(req);
          wait_for_item_done(); 
        end
        repeat(4) begin
          req = mbc_ctrl_seq_item::type_id::create("req");
          wait_for_grant();
          req.r_w = rw;
          req.b = val_b;
          req.h = val_h;
          req.enable = 1; 
          send_request(req);
          wait_for_item_done(); 
        end
        rw = $urandom_range(1,0);
        repeat(1) begin
          req = mbc_ctrl_seq_item::type_id::create("req");
          wait_for_grant();
          //req.randomize();
          req.r_w = 0;
          req.b = 0;
          req.h = 0;
          req.enable = 0; 
          send_request(req);
          wait_for_item_done(); 
        end
        repeat(1) begin
          req = mbc_ctrl_seq_item::type_id::create("req");
          wait_for_grant();
          //req.randomize();
          req.r_w = 0;
          req.b = 0;
          req.h = 0;
          req.enable = 1; 
          send_request(req);
          wait_for_item_done(); 
        end
        repeat(1) begin
          req = mbc_ctrl_seq_item::type_id::create("req");
          wait_for_grant();
          //req.randomize();
          req.r_w = 0;
          req.b = 0;
          req.h = 0;
          req.enable = 0; 
          send_request(req);
          wait_for_item_done(); 
        end        
      end 
    end         
  endtask
endclass
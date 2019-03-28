//-------------------------------------------------------------------------
//						mbc_cpu_interface
//-------------------------------------------------------------------------

interface mbc_cpu_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  // - mbc_cpu Interface - 
  	logic [24:0] address;
  	logic [31:0] d_write;
  	logic [31:0] d_read;
  
    // this signals has been scrapped
    //logic meie; //?
    //logic mtie; //?
    //logic csr_io; //?
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    output address;
    output d_write;
    input  d_read;
    //output meie;
    //output mtie;
    //output csr_io;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    input address;
    input d_write;
    input d_read;
    //input meie;
    //input mtie;
    //input csr_io;
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking monitor_cb,input clk,reset);

 //////////////////////Cobertura funcional: Daniel Palacios//////////////////////////  
  covergroup CPU @(negedge clk);

/*    ADDRESS: coverpoint address{    
      bins io[7]          ={[25'b0010000000000000000000000:25'b1111111111111111111111111]}; // bits para ubicacion de IO
      bins ur[512]        ={[25'b0000000000010000000000000:25'b0001111111111111111111111]}; // bits de region indefinida
      bins ads[2048]      ={[25'b0000000000000000000000100:25'b0000000000001111111111111]}; // bits de memoria
      bins pos[4]         ={[25'b0000000000000000000000000:25'b0000000000000000000000011]}; // bits para byte de memoria
    }*/ 
    ADDRESS_IO: coverpoint address[24:22]{    
      bins io[7]   ={[3'b001:3'b111]}; // bits para ubicacion de IO
    }
    ADDRESS_UR: coverpoint address[21:13]{    
      bins ur[512]   ={[9'b000000001:9'b111111111]}; // bits de region indefinida
    }  
    ADDRESS_ADS: coverpoint address[12:2]{    
      bins ads[2048]   ={[11'b00000000000:11'b11111111111]}; // bits de memoria RAM
    }       
    ADDRESS_POS: coverpoint address[21:13]{    
      bins pos[4]   ={[2'b00:2'b11]}; // bits de region indefinida
    } 
    D_WRITE: coverpoint d_write{
      bins write[50000]   = {[32'h00000000:32'hFFFFFFFF]};
    }
    D_READ: coverpoint d_read{
      bins read[50000]    = {[32'h00000000:32'hFFFFFFFF]};
    }
  endgroup: CPU

  CPU cpu=new();
///////////////////////Fin cobertura funciona: Daniel Palacios/////////////////////////
endinterface
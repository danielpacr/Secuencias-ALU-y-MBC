//-------------------------------------------------------------------------
//						bus_interface that can connect to several modules
//-------------------------------------------------------------------------

interface bus_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  // - Bus Interface - 
    logic pndng;
    logic [61:0] d_pop; //why is it different than data_push?
    logic pop_mbc;
    //logic full; //this signal has been scrapped
    logic [64:0] d_psh;
    logic psh;
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    output pndng;
    output d_pop;
    input  pop_mbc;
    //output full;
    input  d_psh;
    input  psh;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    input pndng;
    input d_pop;
    input pop_mbc;
    //input full;
    input d_psh;
    input psh;
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
  covergroup BUS @(negedge clk);

//    D_POP_DESTINO: coverpoint d_pop[63:62]{ // unicamente puede ser 00 porque el paquete que entra al MBC
//      bins dest = {2'b00};
//    }
    D_POP_FUENTE: coverpoint d_pop[61:60]{ // no puede incluir al 00 por obvias razones
      bins source[3] = {[2'b01:2'b11]};
    }
    D_POP_CODE: coverpoint d_pop[59:57]{
      bins code[8] = {[3'b000:3'b111]};
    }
    D_POP_ADDRESS: coverpoint d_pop[44:32]{ // se utilizan solo 13 de los 25 porque son los de memoria fisica
      bins address[8192] = {[13'b000000000000000:13'b111111111111111]}; // la logica actual del MBC solo utiliza 9 de esos bits
    }    
    D_POP_DATA: coverpoint d_pop[31:0]{
      bins data[50000] = {[32'h00000000:32'hFFFFFFFF]};
    }

    D_PUSH_DESTINO: coverpoint d_psh[63:62]{ // no puede incluir al 00 por obvias razones
      bins dest[3] = {[2'b01:2'b11]};
    }
    D_PUSH_FUENTE: coverpoint d_psh[61:60]{ // unicamente puede ser 00 porque la fuente es el MBC
      bins source = {2'b00};
    }
    D_PUSH_CODE: coverpoint d_psh[59:57]{
      bins code[8] = {[3'b000:3'b111]};
    }
    D_PUSH_ADDRESS: coverpoint d_psh[56:32]{ // por la logica seguida en DUT ir a un IO exige que bits de region indefinida sean cero
//      bins address[2048] = {[11'b00000000000:11'b11111111111]};
        wildcard bins io_1 = {25'b11100000000000???????????}; // valores por encima de 28MB para SPI
        wildcard bins io_2 = {25'b11000000000000???????????}; // valores por encima de 24MB para SPI         
        wildcard bins io_3 = {25'b10100000000000???????????}; // valores por encima de 20MB para SPI
        wildcard bins io_4 = {25'b10000000000000???????????}; // valores por encima de 16MB para SPI 
        wildcard bins io_5 = {25'b01100000000000???????????}; // valores por encima de 12MB para UART 
        wildcard bins io_6 = {25'b01000000000000???????????}; // valores por encima de 8MB para UART
        wildcard bins io_7 = {25'b00100000000000???????????}; // valores por encima de 4MB para IO 1
    }
    D_PUSH_DATA: coverpoint d_psh[31:0]{
      bins data[50000] = {[32'h00000000:32'hFFFFFFFF]};
    }
    
    PUSH: coverpoint psh{
      bins high = {1};
      bins low = {0};
    } 
    POP: coverpoint pop_mbc{
      bins high = {1};
      bins low = {0};
    }
    PNDNG: coverpoint pndng{
      bins high = {1};
      bins low = {0};
    }
  endgroup: BUS

  BUS bus=new();
///////////////////////Fin cobertura funciona: Daniel Palacios///////////////////////// 
  
endinterface
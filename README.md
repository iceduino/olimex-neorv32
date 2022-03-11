# olimex-neorv32
 NEORV32 setup for Olimex iCE40HX8K-EVB
## Folder structure
* neorv32: [NEORV32 version 1.6.9](https://github.com/stnolting/neorv32)
* osflow: Setup for Olimex iCE40HX8K-EVB
* simulation: Testbench for simulation
* sw: Softwareframework

## Flashing Olimexboard with UM232H

Connection:  
Olimexpin -> FTDI-Pin  
SCK -> AD0  
SS -> AD4  
SDO -> AD1  
SDI -> AD2  
CREST -> AD7   
GND -> GND  

* Open terminal navigate to osflow/boards/olimex and use make clean all to create olimex_impl.bin  
* Use make program to flash olimex_impl.bin

## Using Bootloader with UART

Connection:  
Olimexpin -> FTDI-Pin  
TxD -> AD1  
RxD -> AD0  
GND -> GND  

baudrate 19200  
8 databits  
1 stopbit  
no flow control or parity  

## Compile Application

Compilation for uploading via UART  
* Open terminal navigate to sw/programs/<application folder> and use make clean_all exe to create neorv32_exe.bin  
Compilation for installing into memory without bootloader  
* Open terminal navigate to sw/programs/<application folder> and use make clean_all install to create neorv32_application_image.vhd  





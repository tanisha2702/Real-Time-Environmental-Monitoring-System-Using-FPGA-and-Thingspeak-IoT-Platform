## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

## Clock signal (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk_pin -period 10.00 [get_ports clk]


### Reset Button (Center Button BTNC)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## USB-RS232 Interface (To see "OK" in Telnet)
set_property PACKAGE_PIN A18 [get_ports usb_tx]
set_property IOSTANDARD LVCMOS33 [get_ports usb_tx]


## UART on PMOD JA (for Pmod ESP32)

## JA2 ? FPGA RX (connected to ESP32 TX)
set_property PACKAGE_PIN L2 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

## JA3 ? FPGA TX (connected to ESP32 RX)
set_property PACKAGE_PIN J2 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]

## SENSOR ISLAND: Dust Sensor on PMOD JB (Pin 1)
set_property PACKAGE_PIN A14 [get_ports sensor_in]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_in]
set_property PULLUP true [get_ports sensor_in]

## LED0 (Blinks when a dust particle is actively detected)
set_property PACKAGE_PIN U16 [get_ports led0]
set_property IOSTANDARD LVCMOS33 [get_ports led0]

## LED1 (Heartbeat: Blinks once every second to prove the FPGA is running)
set_property PACKAGE_PIN E19 [get_ports led1]
set_property IOSTANDARD LVCMOS33 [get_ports led1]
`timescale 1ns/1ps
// APB master: формирует транзакции записи и чтения (задачи apb_write / apb_read)
module apb_master
(
  input               pclk,
  input               pready,
  input               pslverr,
  input        [31:0] prdata,
  output logic        psel,
  output logic        penable,
  output logic        pwrite,
  output logic [31:0] paddr,
  output logic [31:0] pwdata
);

  initial begin
    psel = 1'b0; penable = 1'b0; pwrite = 1'b0; paddr = '0; pwdata = '0;
  end

  task apb_write(input [31:0] addr, input [31:0] data);
    wait ((penable == 0) && (pready == 0));
    @(posedge pclk);                  // SETUP
    psel   <= 1'b1;
    paddr  <= addr;
    pwdata <= data;
    pwrite <= 1'b1;
    @(posedge pclk);                  // ACCESS
    penable <= 1'b1;
    @(posedge pclk);
    wait (pready == 1'b1);
    @(posedge pclk);
    if (pslverr) $display("[%0t] MASTER: write error at 0x%h", $time, addr);
    psel    <= 1'b0;
    penable <= 1'b0;
    pwrite  <= 1'b0;
    @(posedge pclk);
  endtask

  task apb_read(input [31:0] addr, output logic [31:0] data);
    wait ((penable == 0) && (pready == 0));
    @(posedge pclk);                  // SETUP
    psel   <= 1'b1;
    pwrite <= 1'b0;
    paddr  <= addr;
    @(posedge pclk);                  // ACCESS
    penable <= 1'b1;
    @(posedge pclk);
    wait (pready == 1'b1);
    data = prdata;                    // данные валидны вместе с pready
    if (pslverr) $display("[%0t] MASTER: read error at 0x%h", $time, addr);
    @(posedge pclk);
    psel    <= 1'b0;
    penable <= 1'b0;
    @(posedge pclk);
  endtask

endmodule

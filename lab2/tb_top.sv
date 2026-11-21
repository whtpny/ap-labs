`timescale 1ns/1ps
// Модуль верхнего уровня: мастер + слейв + сценарий проверки
module tb_top;

  logic        pclk;
  logic        presetn;
  wire         psel, penable, pwrite, pready, pslverr;
  wire  [31:0] paddr, pwdata, prdata;

  parameter p_device_offset = 32'h7000_0000;

  // ---- данные варианта (поменять на свои) ----
  localparam [31:0] LIST_NUMBER = 32'd5;          // номер в списке группы
  localparam [31:0] DATE        = 32'h1111_2026;  // 11.11.2026 -> ддммгггг (BCD)
  localparam [31:0] SURNAME     = "Gorb";         // 0x476F7262
  localparam [31:0] NAME        = "Egor";         // 0x45676F72

  logic [31:0] rd;
  int errors = 0;

  apb_master MASTER (.pclk(pclk), .pready(pready), .pslverr(pslverr), .prdata(prdata),
                     .psel(psel), .penable(penable), .pwrite(pwrite),
                     .paddr(paddr), .pwdata(pwdata));

  apb_slave DUT (.pclk(pclk), .presetn(presetn), .paddr(paddr), .pwdata(pwdata),
                 .psel(psel), .penable(penable), .pwrite(pwrite),
                 .pready(pready), .pslverr(pslverr), .prdata(prdata));

  always #10 pclk = ~pclk;   // 50 МГц

  task automatic check(input [31:0] offs, input [31:0] wdata, input [31:0] expected);
    MASTER.apb_write(p_device_offset + offs, wdata);
    MASTER.apb_read (p_device_offset + offs, rd);
    $display("Addr=0x%h write=0x%h read=0x%h expected=0x%h %s",
             p_device_offset + offs, wdata, rd, expected, (rd == expected) ? "OK" : "FAIL");
    if (rd != expected) errors++;
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    pclk = 0; presetn = 1'b1;
    repeat (5) @(posedge pclk);
    presetn = 1'b0;
    repeat (5) @(posedge pclk);
    presetn = 1'b1;
    repeat (5) @(posedge pclk);

    $display("---- Part 1: register 0x0 logic ----");
    check(32'h0, 32'h1234_5678, 32'hAAAA_AAAA);   // бит0 = 0
    check(32'h0, 32'h0000_0001, 32'h5555_5555);   // бит0 = 1

    $display("---- Part 2: variant data ----");
    check(32'h0, LIST_NUMBER, LIST_NUMBER[0] ? 32'h5555_5555 : 32'hAAAA_AAAA);
    check(32'h4, DATE,    DATE);
    check(32'h8, SURNAME, SURNAME);
    check(32'hC, NAME,    NAME);

    $display("---- Wrong address ----");
    MASTER.apb_write(p_device_offset + 32'h10, 32'hDEAD_BEEF);

    $display("==== %s, errors = %0d ====", errors ? "TEST FAILED" : "TEST PASSED", errors);
    repeat (10) @(posedge pclk);
    $stop();
  end

  initial
    $monitor("APB IF: PSEL=%b PENABLE=%b PWRITE=%b PREADY=%b PSLVERR=%b PADDR=0x%h PWDATA=0x%h PRDATA=0x%h",
             psel, penable, pwrite, pready, pslverr, paddr, pwdata, prdata);

endmodule

`timescale 1ns/1ps
// APB slave: 4 регистра по смещениям 0x0, 0x4, 0x8, 0xC
module apb_slave
(
  input               pclk,     // синхросигнал
  input               presetn,  // сигнал сброса (инверсный)
  input        [31:0] paddr,    // адрес обращения
  input        [31:0] pwdata,   // данные для записи
  input               psel,     // признак выбора устройства
  input               penable,  // признак активной транзакции
  input               pwrite,   // признак операции записи
  output logic        pready,   // признак готовности от устройства
  output logic        pslverr,  // признак ошибки при обращении
  output logic [31:0] prdata    // прочитанные данные
);

  logic [31:0] register_with_some_name; // смещение 0x0
  logic [31:0] reg_date;                // смещение 0x4
  logic [31:0] reg_surname;             // смещение 0x8
  logic [31:0] reg_name;                // смещение 0xC

  // APB FSM
  enum logic [1:0] {
    APB_SETUP,
    APB_W_ENABLE,
    APB_R_ENABLE
  } apb_st;

  always @(posedge pclk)
    if (!presetn)
    begin
      prdata  <= '0;
      pslverr <= 1'b0;
      pready  <= 1'b0;
      register_with_some_name <= 32'h0;
      reg_date    <= 32'h0;
      reg_surname <= 32'h0;
      reg_name    <= 32'h0;
      apb_st  <= APB_SETUP;
    end
    else
    begin
      case (apb_st)
        APB_SETUP:
        begin: apb_setup_st
          // clear the prdata and error
          prdata  <= '0;
          pready  <= 1'b0;
          pslverr <= 1'b0;                       // ИСПРАВЛЕНО: ошибка тоже сбрасывается
          // Move to ENABLE when the psel is asserted
          if (psel && !penable)
          begin
            if (pwrite == 1'b1)
              apb_st <= APB_W_ENABLE;
            else
              apb_st <= APB_R_ENABLE;
          end
        end: apb_setup_st

        APB_W_ENABLE:
        begin: apb_w_en_st
          // decode address and write
          if (psel && penable && pwrite)
          begin
            pready <= 1'b1;
            case (paddr[7:0])
              8'h0: begin
                // ИСПРАВЛЕНО: значение выбирается по младшему биту ЗАПИСЫВАЕМЫХ данных
                if (pwdata[0] == 1'b0)
                  register_with_some_name <= 32'hAAAA_AAAA;
                else
                  register_with_some_name <= 32'h5555_5555;
                $display("[%0t] SLAVE: WRITE addr=0x%h data=0x%h -> reg0=0x%h",
                         $time, paddr, pwdata, pwdata[0] ? 32'h5555_5555 : 32'hAAAA_AAAA);
              end
              8'h4: begin
                reg_date <= pwdata;
                $display("[%0t] SLAVE: WRITE addr=0x%h data=0x%h (date)", $time, paddr, pwdata);
              end
              8'h8: begin
                reg_surname <= pwdata;
                $display("[%0t] SLAVE: WRITE addr=0x%h data=0x%h (surname)", $time, paddr, pwdata);
              end
              8'hC: begin
                reg_name <= pwdata;
                $display("[%0t] SLAVE: WRITE addr=0x%h data=0x%h (name)", $time, paddr, pwdata);
              end
              default: begin
                pslverr <= 1'b1;
                $display("[%0t] SLAVE: WRITE ERROR, wrong addr=0x%h", $time, paddr);
              end
            endcase
            apb_st <= APB_SETUP;
          end
        end: apb_w_en_st

        APB_R_ENABLE:
        begin: apb_r_en_st
          if (psel && penable && !pwrite)
          begin
            pready <= 1'b1;
            case (paddr[7:0])
              8'h0: prdata <= register_with_some_name;
              8'h4: prdata <= reg_date;
              8'h8: prdata <= reg_surname;
              8'hC: prdata <= reg_name;
              default: begin
                pslverr <= 1'b1;
                $display("[%0t] SLAVE: READ ERROR, wrong addr=0x%h", $time, paddr);
              end
            endcase
            if (paddr[7:0] == 8'h0 || paddr[7:0] == 8'h4 || paddr[7:0] == 8'h8 || paddr[7:0] == 8'hC)
              $display("[%0t] SLAVE: READ  addr=0x%h", $time, paddr);
            apb_st <= APB_SETUP;
          end
        end: apb_r_en_st

        default:
        begin
          pslverr <= 1'b1;
          apb_st  <= APB_SETUP;
        end
      endcase
      // ИСПРАВЛЕНО: блок "if (register_with_some_name[0] == 0) ..." отсюда удалён:
      // он перезаписывал регистр на каждом такте и затирал записанное значение.
    end

endmodule

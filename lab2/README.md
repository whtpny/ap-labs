# ЛР №2 — APB slave и testbench

Автор: Горбунов Е.А., группа М3О-407Б-23

## Файлы
- `apb_master.sv` — APB master: задачи `apb_write` и `apb_read`
- `apb_slave.sv` — APB slave с регистрами по смещениям 0x0, 0x4, 0x8, 0xC
- `tb_top.sv` — модуль верхнего уровня: мастер + слейв + сценарий проверки
- `run.do` — скрипт запуска в ModelSim

## Логика слейва
- 0x0: при записи числа с битом 0 = 0 хранится 0xAAAA_AAAA, с битом 0 = 1 — 0x5555_5555
- 0x4: дата в формате ДДММГГГГ (BCD)
- 0x8: первые 4 буквы фамилии в ASCII ("Gorb")
- 0xC: первые 4 буквы имени в ASCII ("Egor")
- другой адрес: PSLVERR = 1

## Запуск
ModelSim: `cd` в папку lab2, затем в Transcript: `do run.do`

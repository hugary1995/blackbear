set datafile separator ','
set xrange [0:0.00025]
set yrange [0:]
set xlabel 'total strain'
set ylabel 'creep strain'
set key left top font ',12'

set terminal qt size 1800, 600 font 'Verdana,20'

plot 'elastic_out.csv' using 4:2 with lines lw 2 title 'elastic', \
     'creep_620C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 620 C', \
     'creep_610C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 610 C', \
     'creep_600C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 600 C', \
     'creep_590C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 590 C', \
     'creep_580C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 580 C', \
     'creep_570C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 570 C', \
     'creep_560C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 560 C', \
     'creep_550C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 550 C', \
     'creep_540C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 540 C', \
     'creep_530C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 530 C', \
     'creep_520C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 520 C', \
     'creep_510C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 510 C', \
     'creep_500C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 500 C', \
     'creep_400C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 400 C', \
     'creep_300C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 300 C', \
     'creep_200C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 200 C', \
     'creep_100C.csv' using 4:2 with lines lw 2 title 'LAROMANCE 100 C'

pause -1

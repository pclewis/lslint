#!/bin/tcsh
set failed = .
if ( -e ./test.total.txt ) then
    rm ./test.total.txt
endif

foreach f (scripts/*.lsl scripts/*/*.lsl)
  printf "%40s ... " $f
  ./lslint -A $f >& ./test.run.txt
  if ( $? ) then
      echo "FAILED"
      echo "" >> ./test.total.txt
      echo "****************" >> ./test.total.txt
      echo '***>' $f >> ./test.total.txt
      echo "" >> ./test.total.txt
       cat ./test.run.txt >> ./test.total.txt
      set failed = $failed.
  else
      echo "passed"
  endif
end

rm ./test.run.txt

if ( $failed != . ) then
  cat ./test.total.txt
  rm ./test.total.txt
endif

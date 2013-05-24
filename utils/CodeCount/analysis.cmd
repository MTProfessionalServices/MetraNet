
REM -----Get the file list-----

dir /S /B codebase > allfiles.txt

REM -----Filter the file list for file types------

grep \.h allfiles.txt > hfiles.txt
grep \.cpp allfiles.txt > cppfiles.txt
cat cppfiles.txt hfiles.txt > sourcefiles.txt
grep \.asp allfiles.txt > aspfiles.txt
grep \.sql allfiles.txt > sqlfiles.txt

REM -----Build command files to count the code-----

sed  "s/D:/perl clc.pl -sections TOTAL D:/" sourcefiles.txt > sourcefiles.cmd
sed  "s/D:/wc -l D:/" aspfiles.txt > aspfiles.cmd
sed  "s/D:/wc -l D:/" sqlfiles.txt > sqlfiles.cmd

rem -----Count the code-----

aspfiles.cmd | grep -v 'wc -l' > aspfiles.out
sqlfiles.cmd | grep -v 'wc -l' > sqlfiles.out
sourcefiles.cmd | grep total > sourcefiles.out

REM -----Cleanup-----

del aspfiles.txt
del aspfiles.cmd

del sqlfiles.txt
del sqlfiles.cmd

del sourcefiles.txt
del sourcefiles.cmd
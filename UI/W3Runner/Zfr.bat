Echo off
Echo Zip W3Runner
del W3Runner203.zip
del W3Runner203.zip.pgp
del web\W3Runner.chm
CALL W:\SLA\WebMonitor\Clean.Bat
del install\setup.source\setup1.exe
wzzip -rp -sw3runnerfred13!041290 W3Runner203.zip *.*
pgp -c W3Runner203.zip
COPY help\W3Runner.chm web




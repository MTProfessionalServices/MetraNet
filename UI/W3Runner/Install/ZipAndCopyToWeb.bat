Echo off
Echo Zip and Copy W3Runner%1.zip

cd setup
wzzip W3Runner%1.zip
copy W3Runner%1.zip g:\pmsweb\W3RunnerWeb\zip
copy W3Runner%1.zip g:\pmsweb\W3RunnerWeb\zip\W3Runnerlast.zip
del W3Runner%1.zip

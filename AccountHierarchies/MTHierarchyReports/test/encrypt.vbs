
Dim o
Set o = CreateObject("MetraTech.OnlineBill.QueryStringEncrypt")

wscript.echo "Starting..."

Dim str
str =  "Hello + Wolrd = testing!!!!!"

wscript.echo "In:" & str

Dim str2
str2 = o.EncryptString(str)
wscript.echo "Encrypted:" & str2


Dim str3
str3 = o.DecryptString(str2)
wscript.echo "Decrypted:" & str3





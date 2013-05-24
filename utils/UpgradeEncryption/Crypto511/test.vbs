dim cr
set cr = CreateObject("MetraTech.Crypto511.Decryptor")
cr.Initialize()
wscript.echo cr.Decrypt("KedDb9gwqKUypraOzY9xjQE16RGP6Vde")
wscript.echo cr.Decrypt("Q3U5swmfyKn0V4Bd554rYw==")




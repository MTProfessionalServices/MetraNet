
Counterps.dll: dlldata.obj Counter_p.obj Counter_i.obj
	link /dll /out:Counterps.dll /def:Counterps.def /entry:DllMain dlldata.obj Counter_p.obj Counter_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del Counterps.dll
	@del Counterps.lib
	@del Counterps.exp
	@del dlldata.obj
	@del Counter_p.obj
	@del Counter_i.obj


PCConfigps.dll: dlldata.obj PCConfig_p.obj PCConfig_i.obj
	link /dll /out:PCConfigps.dll /def:PCConfigps.def /entry:DllMain dlldata.obj PCConfig_p.obj PCConfig_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del PCConfigps.dll
	@del PCConfigps.lib
	@del PCConfigps.exp
	@del dlldata.obj
	@del PCConfig_p.obj
	@del PCConfig_i.obj

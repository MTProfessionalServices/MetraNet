
MTAuthCapabilitiesps.dll: dlldata.obj MTAuthCapabilities_p.obj MTAuthCapabilities_i.obj
	link /dll /out:MTAuthCapabilitiesps.dll /def:MTAuthCapabilitiesps.def /entry:DllMain dlldata.obj MTAuthCapabilities_p.obj MTAuthCapabilities_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del MTAuthCapabilitiesps.dll
	@del MTAuthCapabilitiesps.lib
	@del MTAuthCapabilitiesps.exp
	@del dlldata.obj
	@del MTAuthCapabilities_p.obj
	@del MTAuthCapabilities_i.obj

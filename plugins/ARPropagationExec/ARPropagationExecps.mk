
ARPropagationExecps.dll: dlldata.obj ARPropagationExec_p.obj ARPropagationExec_i.obj
	link /dll /out:ARPropagationExecps.dll /def:ARPropagationExecps.def /entry:DllMain dlldata.obj ARPropagationExec_p.obj ARPropagationExec_i.obj \
		mtxih.lib mtx.lib mtxguid.lib \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \
		ole32.lib advapi32.lib 

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		/MD \
		$<

clean:
	@del ARPropagationExecps.dll
	@del ARPropagationExecps.lib
	@del ARPropagationExecps.exp
	@del dlldata.obj
	@del ARPropagationExec_p.obj
	@del ARPropagationExec_i.obj


MTARInterfaceExecps.dll: dlldata.obj MTARInterfaceExec_p.obj MTARInterfaceExec_i.obj
	link /dll /out:MTARInterfaceExecps.dll /def:MTARInterfaceExecps.def /entry:DllMain dlldata.obj MTARInterfaceExec_p.obj MTARInterfaceExec_i.obj \
		mtxih.lib mtx.lib mtxguid.lib \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \
		ole32.lib advapi32.lib 

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		/MD \
		$<

clean:
	@del MTARInterfaceExecps.dll
	@del MTARInterfaceExecps.lib
	@del MTARInterfaceExecps.exp
	@del dlldata.obj
	@del MTARInterfaceExec_p.obj
	@del MTARInterfaceExec_i.obj

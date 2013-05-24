
MTProgressExecps.dll: dlldata.obj MTProgressExec_p.obj MTProgressExec_i.obj
	link /dll /out:MTProgressExecps.dll /def:MTProgressExecps.def /entry:DllMain dlldata.obj MTProgressExec_p.obj MTProgressExec_i.obj \
		mtxih.lib mtx.lib mtxguid.lib \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \
		ole32.lib advapi32.lib 

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		/MD \
		$<

clean:
	@del MTProgressExecps.dll
	@del MTProgressExecps.lib
	@del MTProgressExecps.exp
	@del dlldata.obj
	@del MTProgressExec_p.obj
	@del MTProgressExec_i.obj

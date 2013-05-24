
MTYAACExecps.dll: dlldata.obj MTYAACExec_p.obj MTYAACExec_i.obj
	link /dll /out:MTYAACExecps.dll /def:MTYAACExecps.def /entry:DllMain dlldata.obj MTYAACExec_p.obj MTYAACExec_i.obj \
		mtxih.lib mtx.lib mtxguid.lib \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \
		ole32.lib advapi32.lib 

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		/MD \
		$<

clean:
	@del MTYAACExecps.dll
	@del MTYAACExecps.lib
	@del MTYAACExecps.exp
	@del dlldata.obj
	@del MTYAACExec_p.obj
	@del MTYAACExec_i.obj


MTGenericDBExecps.dll: dlldata.obj MTGenericDBExec_p.obj MTGenericDBExec_i.obj
	link /dll /out:MTGenericDBExecps.dll /def:MTGenericDBExecps.def /entry:DllMain dlldata.obj MTGenericDBExec_p.obj MTGenericDBExec_i.obj \
		mtxih.lib mtx.lib mtxguid.lib \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \
		ole32.lib advapi32.lib 

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		/MD \
		$<

clean:
	@del MTGenericDBExecps.dll
	@del MTGenericDBExecps.lib
	@del MTGenericDBExecps.exp
	@del dlldata.obj
	@del MTGenericDBExec_p.obj
	@del MTGenericDBExec_i.obj

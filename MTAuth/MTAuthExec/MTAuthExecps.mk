
MTAuthExecps.dll: dlldata.obj MTAuthExec_p.obj MTAuthExec_i.obj
	link /dll /out:MTAuthExecps.dll /def:MTAuthExecps.def /entry:DllMain dlldata.obj MTAuthExec_p.obj MTAuthExec_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del MTAuthExecps.dll
	@del MTAuthExecps.lib
	@del MTAuthExecps.exp
	@del dlldata.obj
	@del MTAuthExec_p.obj
	@del MTAuthExec_i.obj

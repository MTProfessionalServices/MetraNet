
MTAuditDBWriterps.dll: dlldata.obj MTAuditDBWriter_p.obj MTAuditDBWriter_i.obj
	link /dll /out:MTAuditDBWriterps.dll /def:MTAuditDBWriterps.def /entry:DllMain dlldata.obj MTAuditDBWriter_p.obj MTAuditDBWriter_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del MTAuditDBWriterps.dll
	@del MTAuditDBWriterps.lib
	@del MTAuditDBWriterps.exp
	@del dlldata.obj
	@del MTAuditDBWriter_p.obj
	@del MTAuditDBWriter_i.obj

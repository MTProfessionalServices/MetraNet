
MTAuditEventsps.dll: dlldata.obj MTAuditEvents_p.obj MTAuditEvents_i.obj
	link /dll /out:MTAuditEventsps.dll /def:MTAuditEventsps.def /entry:DllMain dlldata.obj MTAuditEvents_p.obj MTAuditEvents_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del MTAuditEventsps.dll
	@del MTAuditEventsps.lib
	@del MTAuditEventsps.exp
	@del dlldata.obj
	@del MTAuditEvents_p.obj
	@del MTAuditEvents_i.obj


MTYAACps.dll: dlldata.obj MTYAAC_p.obj MTYAAC_i.obj
	link /dll /out:MTYAACps.dll /def:MTYAACps.def /entry:DllMain dlldata.obj MTYAAC_p.obj MTYAAC_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del MTYAACps.dll
	@del MTYAACps.lib
	@del MTYAACps.exp
	@del dlldata.obj
	@del MTYAAC_p.obj
	@del MTYAAC_i.obj

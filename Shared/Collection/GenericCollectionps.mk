
GenericCollectionps.dll: dlldata.obj GenericCollection_p.obj GenericCollection_i.obj
	link /dll /out:GenericCollectionps.dll /def:GenericCollectionps.def /entry:DllMain dlldata.obj GenericCollection_p.obj GenericCollection_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del GenericCollectionps.dll
	@del GenericCollectionps.lib
	@del GenericCollectionps.exp
	@del dlldata.obj
	@del GenericCollection_p.obj
	@del GenericCollection_i.obj

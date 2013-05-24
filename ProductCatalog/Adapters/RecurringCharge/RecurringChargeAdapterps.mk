
RecurringChargeAdapterps.dll: dlldata.obj RecurringChargeAdapter_p.obj RecurringChargeAdapter_i.obj
	link /dll /out:RecurringChargeAdapterps.dll /def:RecurringChargeAdapterps.def /entry:DllMain dlldata.obj RecurringChargeAdapter_p.obj RecurringChargeAdapter_i.obj \
		kernel32.lib rpcndr.lib rpcns4.lib rpcrt4.lib oleaut32.lib uuid.lib \

.c.obj:
	cl /c /Ox /DWIN32 /D_WIN32_WINNT=0x0400 /DREGISTER_PROXY_DLL \
		$<

clean:
	@del RecurringChargeAdapterps.dll
	@del RecurringChargeAdapterps.lib
	@del RecurringChargeAdapterps.exp
	@del dlldata.obj
	@del RecurringChargeAdapter_p.obj
	@del RecurringChargeAdapter_i.obj

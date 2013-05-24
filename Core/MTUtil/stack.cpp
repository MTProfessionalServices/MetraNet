/**************************************************************************
 * @doc STACK
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <windows.h>
#include <winnt.h>
#include <imagehlp.h>
#include <string>
#include <iostream>

using std::cout;
using std::endl;
using std::hex;
using std::dec;

#define _T(x) x
#define printf _tprintf

#include <MTUtil.h>

//
// This routine prints a stack (call frame) trace
// of the current routine back to the start of
// the program (limited to 100 frames).  It works
// for both Intel and Alpha.
//
// If the image contains debug info (or has a .pdb),
// routine and offset are printed.
//
// Note that if it is used in an exception handler,
// the exception structure contains the necessary
// information to setup the starting point.  Some of
// the code in the architecture-specific section could
// be simplified to get the exception pointer data
// instead of using the current context.
//
// Please send any comments or corrections to
//
//      CW Hobbs
//      Software Partner Engineering - Palo Alto
//      CW.Hobbs@digital.com
//

#include <windows.h>
#include <imagehlp.h>           // link with imagehlp.lib as well...
#include <stdio.h>
#include <winerror.h>

#define  sizeof_Name            128
#define  sizeof_CONTEXT         sizeof(CONTEXT)+96
#define  sizeof_STACKFRAME      sizeof(STACKFRAME)+16
#define  sizeof_symbol          sizeof(IMAGEHLP_SYMBOL)+sizeof_Name

#if defined(_M_ALPHA) 
void RtlCaptureContext (CONTEXT *cxt);
#endif

// typedef struct {DWORD d[8];} foob;

BOOL CALLBACK SymEnumCallback(  LPCSTR ModuleName,   ULONG BaseOfDll,  
  PVOID UserContext )
{
	MTStackTrace::_tprintf("Loaded module %s\n",ModuleName);
	return TRUE;
}


void MTStackTrace::NtStackTrace()
{
        HANDLE                  hProc, hThread;
        CONTEXT                 *cxt;
        IMAGEHLP_SYMBOL *sym;
        STACKFRAME              *frm;
        DWORD                   machType, symDisp, lastErr, filepathlen;
        BOOL                    stat;
        int                             i;
        char                    filepath[MAX_PATH], *lastdir, *pPath;



// Initialize the IMAGEHLP package to decode addresses to symbols
//
//    Note: need to link /debug /debugtype:coff to get symbols into .EXE/.DLL files

        // Get image filename of the main executable

        filepathlen = GetModuleFileNameA ( NULL, filepath, sizeof(filepath));
        if (filepathlen == 0)
                printf ("NtStackTrace: Failed to get pathname for program\n");

        // Strip the filename, leaving the path to the executable

        lastdir = strrchr (filepath, '/');
        if (lastdir == NULL)
                lastdir = strrchr (filepath, '\\');
        if (lastdir != NULL)
                lastdir[0] = '\0';

        // Initialize the symbol table routines, supplying a pointer to the path

        pPath = filepath;
        if (strlen (filepath) == 0)
                pPath = NULL;

        hProc   = GetCurrentProcess ();
        hThread = GetCurrentThread ();
        if ( !_SymInitialize (hProc, pPath, TRUE) )
                printf ("NtStackTrace: failed to initialize symbols\n");

// Allocate and initialize frame and symbol structures

        frm = (STACKFRAME *) malloc (sizeof_STACKFRAME);
        memset (frm, 0, sizeof(STACKFRAME));

        sym = (IMAGEHLP_SYMBOL *) malloc (sizeof_symbol);
        memset (sym, 0, sizeof_symbol);
        sym->SizeOfStruct  = sizeof(IMAGEHLP_SYMBOL);
        sym->MaxNameLength = sizeof_Name-1;


// Initialize the starting point based on the architecture of the current machine

#if defined(_M_IX86) 

    machType = IMAGE_FILE_MACHINE_I386; 

        // The CONTEXT structure is not used on x86 systems

        cxt = NULL;

        //      Initialize the STACKFRAME to describe the current routine

    frm->AddrPC.Mode         = AddrModeFlat; 
    frm->AddrStack.Mode      = AddrModeFlat; 
    frm->AddrFrame.Mode      = AddrModeFlat;

        // If we were called from an exception handler, the exception
        // structure would contain an embedded CONTEXT structure.  We
        // could initialize the following addresses from the CONTEXT
        // registers passed to us.

        // For this example, use _asm to fetch the processor register values

        _asm mov  i, esp                                        // Stack pointer  (CONTEXT .Esp field)
        frm->AddrStack.Offset    = i; 

        _asm mov  i, ebp                                        // Frame pointer  (CONTEXT .Ebp field)
        frm->AddrFrame.Offset    = i;

        // We'd like to fetch the current instruction pointer, but the x86 IP
        // register is a bit special.  Use roughly the current offset instead
        // of a dynamic fetch (use offset because address should be past the prologue).
                                                
        //      _asm mov  i, ip         // ip is a special register, this is illegal
        //      frm->AddrPC.Offset       = i;

        frm->AddrPC.Offset       = ((DWORD) &NtStackTrace) + 0x08c;


#elif defined(_M_ALPHA) 

    machType = IMAGE_FILE_MACHINE_ALPHA; 

        cxt = malloc (sizeof_CONTEXT);
        memset (cxt, 0, sizeof_CONTEXT);

// Fetch the current context for the NtStackTrace procedure itself)

        RtlCaptureContext (cxt);

#else 
#error( "unknown target machine type - not Alpha or X86" ); 
#endif 


// The top stack frame is the call to this routine itself -
// probably not of much interest, so grab the info outside
// of the main loop.  Note that if we got the initial starting
// point from the exception frame, the top frame might be of interest.

        if ( !_StackWalk( machType, hProc, hThread, frm, cxt,
                     NULL, _SymFunctionTableAccess, _SymGetModuleBase, NULL ) ) {
                        printf ("NtStackTrace: Failed to walk current stack call\n");
                }

        printf ("\n  NT Stack Trace:          ");

// Include the address/symbol info for the stack trace routine itself

        if ( !_SymGetSymFromAddr ( hProc, frm->AddrPC.Offset, &symDisp, sym ) )
                printf ("(0x%08x  (no symbols available))\n",
                        frm->AddrPC.Offset);
        else
                printf ("(0x%08x  %s+%d):\n",
                        frm->AddrPC.Offset, sym->Name, symDisp);

        printf ("\n    Return PC    Routine+offset\n");
        printf (  "    ----------   ------------------------------\n");


// Loop through the rest of the call stack, limit trace to 100
// routines to make sure that we don't loop or flood the user
// with too much info in case of very deep stack or infinite recursion...

        for (i=0; i<100; i++) {

                // Call the routine to trace to the next frame

                stat = _StackWalk( machType, hProc, hThread, frm, cxt,
                     NULL, _SymFunctionTableAccess, _SymGetModuleBase, NULL );
                if ( !stat ) 
				{
				    lastErr = GetLastError ();
                    if ((lastErr == ERROR_NOACCESS) | 
						(lastErr == ERROR_INVALID_ADDRESS))
					{
					    printf ("       (done)\n"); // Normal end-of-stack code
					}
                    else
					{
					    printf ("       (stack walk terminated with error %d)\n", lastErr);
						break;
					}
                }

                // Ignore frames with PC = 0, these seem to be an end-of-stack guard frame on Intel

                if ( frm->AddrPC.Offset != 0 ) {

                        // Decode the closest routine symbol name

                        if ( _SymGetSymFromAddr ( hProc, frm->AddrPC.Offset, &symDisp, sym ) ) {
                                printf ("    0x%08x   %s+%d\n",
                                        frm->AddrPC.Offset, sym->Name, symDisp);
                        }
                        else {
                                lastErr = GetLastError ();
                                if (lastErr == ERROR_INVALID_ADDRESS)           // Seems normal for last frame on Intel
                                        printf ("    0x%08x   (no symbol available)\n",
                                                frm->AddrPC.Offset);
                                else
                                        printf ("    0x%08x   (no symbol available - error %d)\n",
                                                frm->AddrPC.Offset, lastErr);
                        }
                }

        }

        if (i >= 100)
                printf ("      (traceback terminated after 100 routines)\n");


		// list all the modules loaded
		_SymEnumerateModules(hProc,SymEnumCallback,NULL);


        if ( !_SymCleanup (hProc) )
                printf ("NtStackTrace: failed to cleanup symbols\n");

        free (cxt);             // If on Intel, freeing the NULL CONTEXT is a no-op...
        free (frm);
        free (sym);

        printf ("\n");

}



#if 0
class MTStackTrace
{
	static BOOL CurrentContext(LPCONTEXT apContext);

	//static void GenerateStackTrace();

	static BOOL GenerateExceptionReport(RWCString & arTrace,
																			const LPCONTEXT apContext);

	static BOOL GetLogicalAddress(PVOID addr, PSTR szModule, DWORD len,
																DWORD& section, DWORD& offset);

	static void ImagehlpStackWalk(PCONTEXT pContext);
	static BOOL InitImagehlpFunctions();

	static int __cdecl _tprintf(const char * format, ...);

	static long Filter(LPCONTEXT apContext, LPCONTEXT apSourceContext);

	static BOOL mGotContext;

	static RWCString mTrace;

#if 1
	// Make typedefs for some IMAGEHLP.DLL functions so that we can use them
	// with GetProcAddress
	typedef BOOL (__stdcall * SYMINITIALIZEPROC)( HANDLE, LPSTR, BOOL );
	typedef BOOL (__stdcall *SYMCLEANUPPROC)( HANDLE );

	typedef BOOL (__stdcall * STACKWALKPROC)
		( DWORD, HANDLE, HANDLE, LPSTACKFRAME, LPVOID,
			PREAD_PROCESS_MEMORY_ROUTINE,PFUNCTION_TABLE_ACCESS_ROUTINE,
			PGET_MODULE_BASE_ROUTINE, PTRANSLATE_ADDRESS_ROUTINE );

	typedef LPVOID (__stdcall *SYMFUNCTIONTABLEACCESSPROC)( HANDLE, DWORD );

	typedef DWORD (__stdcall *SYMGETMODULEBASEPROC)( HANDLE, DWORD );

	typedef BOOL (__stdcall *SYMGETSYMFROMADDRPROC)
		( HANDLE, DWORD, PDWORD, PIMAGEHLP_SYMBOL );

	typedef BOOL (__stdcall *SYMENUMERATEMODULESPROC)
		(HANDLE,PSYM_ENUMMODULES_CALLBACK,PVOID);                               


	static SYMINITIALIZEPROC _SymInitialize;
	static SYMCLEANUPPROC _SymCleanup;
	static STACKWALKPROC _StackWalk;
	static SYMFUNCTIONTABLEACCESSPROC _SymFunctionTableAccess;
	static SYMGETMODULEBASEPROC _SymGetModuleBase;
	static SYMGETSYMFROMADDRPROC _SymGetSymFromAddr;
	static SYMENUMERATEMODULESPROC _SymEnumerateModules;

#endif

};
#endif

std::string MTStackTrace::mTrace;
BOOL MTStackTrace::mGotContext;
MTStackTrace::SYMFUNCTIONTABLEACCESSPROC
                                MTStackTrace::_SymFunctionTableAccess = 0;

MTStackTrace::SYMGETMODULEBASEPROC
                                      MTStackTrace::_SymGetModuleBase = 0;

MTStackTrace::SYMGETSYMFROMADDRPROC
                                     MTStackTrace::_SymGetSymFromAddr = 0;


MTStackTrace::SYMINITIALIZEPROC MTStackTrace::_SymInitialize = 0;
MTStackTrace::SYMCLEANUPPROC MTStackTrace::_SymCleanup = 0;
MTStackTrace::STACKWALKPROC MTStackTrace::_StackWalk = 0;
MTStackTrace::SYMENUMERATEMODULESPROC MTStackTrace::_SymEnumerateModules = 0;


long MyFilter(LPCONTEXT ptr)
{
	return EXCEPTION_EXECUTE_HANDLER;
}

void BreakIt()
{
	char * bad = NULL;
	char badch = *bad;					// generate an access violation

}


BOOL MTStackTrace::CurrentContext(LPCONTEXT apContext)
{

	apContext->ContextFlags = CONTEXT_FULL;
	HANDLE thread = GetCurrentThread();
	if (!thread)
	{
		DWORD err = GetLastError();
		cout << "Error1: " << hex << err << dec << endl;
		return FALSE;
	}

	if (!GetThreadContext(thread, apContext))
	{
		DWORD err = GetLastError();
		cout << "Error: " << hex << err << dec << endl;
		return FALSE;
	}

	return TRUE;

#if 0

	mGotContext = FALSE;

	EXCEPTION_POINTERS * pointers;
	__try
	{
		BreakIt();
	}
	__except(pointers = GetExceptionInformation(),
					 *apContext = *(pointers->ContextRecord), EXCEPTION_EXECUTE_HANDLER)
	{
	}
	return TRUE;
#endif
}

#if 0
long MTStackTrace::Filter(LPCONTEXT apContext, LPCONTEXT apSourceContext)
{
	//struct exception_pointers {
	// EXCEPTION_RECORD *ExceptionRecord,
	//    CONTEXT *ContextRecord }

	*apContext = *apSourceContext;
	mGotContext = TRUE;
	return EXCEPTION_EXECUTE_HANDLER;
}
#endif

//===========================================================================
// Open the report file, and write the desired information to it.  Called by 
// MSJUnhandledExceptionFilter                                               
//===========================================================================

#if 0
void MTStackTrace::GenerateExceptionReport(std::string & arTrace,
										   PEXCEPTION_POINTERS pExceptionInfo)
{



    // Start out with a banner
    _tprintf( _T("//=====================================================\n") );

    PEXCEPTION_RECORD pExceptionRecord = pExceptionInfo->ExceptionRecord;

    // First print information about the type of fault
    _tprintf(   _T("Exception code: %08X %s\n"),
                pExceptionRecord->ExceptionCode,
                GetExceptionString(pExceptionRecord->ExceptionCode) );

    // Now print information about where the fault occured
    TCHAR szFaultingModule[MAX_PATH];
    DWORD section, offset;
    GetLogicalAddress(  pExceptionRecord->ExceptionAddress,
                        szFaultingModule,
                        sizeof( szFaultingModule ),
                        section, offset );

    _tprintf( _T("Fault address:  %08X %02X:%08X %s\n"),
              pExceptionRecord->ExceptionAddress,
              section, offset, szFaultingModule );

    PCONTEXT pCtx = pExceptionInfo->ContextRecord;

    // Show the registers
    #ifdef _M_IX86  // Intel Only!
    _tprintf( _T("\nRegisters:\n") );

    _tprintf(_T("EAX:%08X\nEBX:%08X\nECX:%08X\nEDX:%08X\nESI:%08X\nEDI:%08X\n"),
             pCtx->Eax, pCtx->Ebx, pCtx->Ecx, pCtx->Edx, pCtx->Esi, pCtx->Edi );

    _tprintf( _T("CS:EIP:%04X:%08X\n"), pCtx->SegCs, pCtx->Eip );
    _tprintf( _T("SS:ESP:%04X:%08X  EBP:%08X\n"),
              pCtx->SegSs, pCtx->Esp, pCtx->Ebp );
    _tprintf( _T("DS:%04X  ES:%04X  FS:%04X  GS:%04X\n"),
              pCtx->SegDs, pCtx->SegEs, pCtx->SegFs, pCtx->SegGs );
    _tprintf( _T("Flags:%08X\n"), pCtx->EFlags );

    #endif

    if ( !InitImagehlpFunctions() )
    {
        OutputDebugString(_T("IMAGEHLP.DLL or its exported procs not found"));
        
        #ifdef _M_IX86  // Intel Only!
        // Walk the stack using x86 specific code
        IntelStackWalk( pCtx );
        #endif

        return;
    }

    ImagehlpStackWalk( pCtx );

    _SymCleanup( GetCurrentProcess() );

    _tprintf( _T("\n") );
}
#endif

BOOL MTStackTrace::GenerateExceptionReport(std::string & arTrace,
										   const LPCONTEXT apContext)
{
	mTrace = _T("");

	if (!InitImagehlpFunctions())
		return FALSE;

	NtStackTrace();

	ImagehlpStackWalk(apContext);

	_SymCleanup(GetCurrentProcess());

	_tprintf( _T("\n") );

	arTrace = mTrace;
	return TRUE;
}

//==============================================================================
// Given a linear address, locates the module, section, and offset containing  
// that address.                                                               
//                                                                             
// Note: the szModule paramater buffer is an output buffer of length specified 
// by the len parameter (in characters!)                                       
//==============================================================================
BOOL MTStackTrace::GetLogicalAddress(
	PVOID addr, PSTR szModule, DWORD len, DWORD& section, DWORD& offset )
{
	MEMORY_BASIC_INFORMATION mbi;

	if ( !VirtualQuery( addr, &mbi, sizeof(mbi) ) )
		return FALSE;

	DWORD hMod = (DWORD)mbi.AllocationBase;

	if ( !GetModuleFileNameA( (HMODULE)hMod, szModule, len ) )
		return FALSE;

	// Point to the DOS header in memory
	PIMAGE_DOS_HEADER pDosHdr = (PIMAGE_DOS_HEADER)hMod;

	// From the DOS header, find the NT (PE) header
	PIMAGE_NT_HEADERS pNtHdr = (PIMAGE_NT_HEADERS)(hMod + pDosHdr->e_lfanew);

	PIMAGE_SECTION_HEADER pSection = IMAGE_FIRST_SECTION( pNtHdr );

	DWORD rva = (DWORD)addr - hMod; // RVA is offset from module load address

	// Iterate through the section table, looking for the one that encompasses
	// the linear address.
	for (   unsigned i = 0;
					i < pNtHdr->FileHeader.NumberOfSections;
					i++, pSection++ )
	{
		DWORD sectionStart = pSection->VirtualAddress;
		DWORD sectionEnd = sectionStart
			+ max(pSection->SizeOfRawData, pSection->Misc.VirtualSize);

		// Is the address in this section???
		if ( (rva >= sectionStart) && (rva <= sectionEnd) )
		{
			// Yes, address is in the section.  Calculate section and offset,
			// and store in the "section" & "offset" params, which were
			// passed by reference.
			section = i+1;
			offset = rva - sectionStart;
			return TRUE;
		}
	}

	return FALSE;   // Should never get here!
}


//============================================================
// Walks the stack, and writes the results to the report file 
//============================================================
void MTStackTrace::ImagehlpStackWalk( PCONTEXT pContext )
{
	_tprintf( _T("\nCall stack:\n") );

	_tprintf( _T("Address   Frame\n") );

	// Could use SymSetOptions here to add the SYMOPT_DEFERRED_LOADS flag

	STACKFRAME sf;
	memset( &sf, 0, sizeof(sf) );

	// Initialize the STACKFRAME structure for the first call.  This is only
	// necessary for Intel CPUs, and isn't mentioned in the documentation.
	sf.AddrPC.Offset       = pContext->Eip;
	sf.AddrPC.Mode         = AddrModeFlat;
	sf.AddrStack.Offset    = pContext->Esp;
	sf.AddrStack.Mode      = AddrModeFlat;
	sf.AddrFrame.Offset    = pContext->Ebp;
	sf.AddrFrame.Mode      = AddrModeFlat;

	while ( 1 )
	{
		if ( ! _StackWalk(  IMAGE_FILE_MACHINE_I386,
												GetCurrentProcess(),
												GetCurrentThread(),
												&sf,
												NULL,
												//pContext,
												0,
												_SymFunctionTableAccess,
												_SymGetModuleBase,
												0 ) )
		{
			DWORD err = GetLastError();
			break;
		}

		if ( 0 == sf.AddrFrame.Offset ) // Basic sanity check to make sure
			break;                      // the frame is OK.  Bail if not.

		_tprintf( _T("%08X  %08X  "), sf.AddrPC.Offset, sf.AddrFrame.Offset );

		// IMAGEHLP is wacky, and requires you to pass in a pointer to an
		// IMAGEHLP_SYMBOL structure.  The problem is that this structure is
		// variable length.  That is, you determine how big the structure is
		// at runtime.  This means that you can't use sizeof(struct).
		// So...make a buffer that's big enough, and make a pointer
		// to the buffer.  We also need to initialize not one, but TWO
		// members of the structure before it can be used.

		BYTE symbolBuffer[ sizeof(IMAGEHLP_SYMBOL) + 512 ];
		PIMAGEHLP_SYMBOL pSymbol = (PIMAGEHLP_SYMBOL)symbolBuffer;
		pSymbol->SizeOfStruct = sizeof(symbolBuffer);
		pSymbol->MaxNameLength = 512;
                        
		DWORD symDisplacement = 0;  // Displacement of the input address,
		// relative to the start of the symbol

		if ( _SymGetSymFromAddr(GetCurrentProcess(), sf.AddrPC.Offset,
														&symDisplacement, pSymbol) )
		{
			_tprintf( _T("%hs+%X\n"), pSymbol->Name, symDisplacement );
            
		}
		else    // No symbol found.  Print out the logical address instead.
		{
			char szModule[MAX_PATH] = _T("");
			DWORD section = 0, offset = 0;

			GetLogicalAddress(  (PVOID)sf.AddrPC.Offset,
													szModule, sizeof(szModule), section, offset );

			_tprintf( _T("%04X:%08X %s\n"),
								section, offset, szModule );
		}
	}

}



//=========================================================================
// Load IMAGEHLP.DLL and get the address of functions in it that we'll use 
//=========================================================================
BOOL MTStackTrace::InitImagehlpFunctions()
{
	HMODULE hModImagehlp = LoadLibraryA( _T("IMAGEHLP.DLL") );
	if ( !hModImagehlp )
		return FALSE;

	_SymInitialize = (SYMINITIALIZEPROC)GetProcAddress( hModImagehlp,
																											"SymInitialize" );
	if ( !_SymInitialize )
		return FALSE;

	_SymCleanup = (SYMCLEANUPPROC)GetProcAddress( hModImagehlp, "SymCleanup" );
	if ( !_SymCleanup )
		return FALSE;

	_StackWalk = (STACKWALKPROC)GetProcAddress( hModImagehlp, "StackWalk" );
	if ( !_StackWalk )
		return FALSE;

	_SymFunctionTableAccess = (SYMFUNCTIONTABLEACCESSPROC)
		GetProcAddress( hModImagehlp, "SymFunctionTableAccess" );

	if ( !_SymFunctionTableAccess )
		return FALSE;

	_SymGetModuleBase=(SYMGETMODULEBASEPROC)GetProcAddress( hModImagehlp,
																													"SymGetModuleBase");
	if ( !_SymGetModuleBase )
		return FALSE;

	_SymGetSymFromAddr=(SYMGETSYMFROMADDRPROC)GetProcAddress( hModImagehlp,
																														"SymGetSymFromAddr" );
	
	_SymEnumerateModules=(SYMENUMERATEMODULESPROC)GetProcAddress(hModImagehlp,
		"SymEnumerateModules");
	if(!_SymEnumerateModules) return FALSE;

	if ( !_SymGetSymFromAddr )
		return FALSE;

	if ( !_SymInitialize( GetCurrentProcess(),NULL, TRUE ) )
		return FALSE;

	return TRUE;        
}


//============================================================================
// Helper function that writes to the report file, and allows the user to use 
// printf style formating                                                     
//============================================================================
int __cdecl MTStackTrace::_tprintf(const char * format, ...)
{
	char szBuff[1024];
	int retValue;
	va_list argptr;
          
	va_start( argptr, format );
	retValue = wvsprintfA( szBuff, format, argptr );
	va_end( argptr );

	mTrace += szBuff;
	// 	DWORD cbWritten;
	//WriteFile( m_hReportFile, szBuff, retValue * sizeof(TCHAR), &cbWritten, 0 );

	return retValue;
}


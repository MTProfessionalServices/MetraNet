using System;
using System.Security;
using System.Threading;
using System.Collections;
using System.ServiceProcess;
using System.Runtime.InteropServices; 

namespace MetraTech
{
	public class Kernel32
	{
		const int ERROR_ALREADY_EXISTS = 183; 
		const int STANDARD_RIGHTS_REQUIRED = 0x000F0000;
		const int SYNCHRONIZE = 0x00100000;
		const int EVENT_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED|SYNCHRONIZE|0x3;

    // These are taken directly from WinBase.h
    const int FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100;
    const int FORMAT_MESSAGE_FROM_HMODULE = 2048; //0x00000800;
    const int FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
    const int LOAD_LIBRARY_AS_DATAFILE = 0x00000002;

		[DllImport("kernel32.dll", SetLastError=true)]
		[SuppressUnmanagedCodeSecurityAttribute()] 
		static extern IntPtr CreateEvent(IntPtr pEventAttributes,
			bool bManualReset, bool bInitialState, string pName); 

		[DllImport("kernel32.dll", SetLastError=true)]
		[SuppressUnmanagedCodeSecurityAttribute()] 
		static extern IntPtr OpenEvent(int dwDesiredAccess, bool bInheritHandle, string pName);

		[DllImport("kernel32.dll", SetLastError=true)]
		[SuppressUnmanagedCodeSecurityAttribute()] 
		static extern int CloseHandle(IntPtr hObject);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = false)]
    private static extern int FormatMessage(int dwFlags,
                                            IntPtr lpSource,
                                            int dwMessageId,
                                            int dwLanguageId,
                                            ref string MsgBuffer,
                                            int nSize,
                                            IntPtr Arguments);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
    private static extern IntPtr LoadLibraryEx([MarshalAs(UnmanagedType.LPTStr)] string lpFileName,
                                               IntPtr hFile, int dwFlags);

    [DllImport("kernel32.dll")]
    public static extern IntPtr GetModuleHandle(string lpModuleName);

		[DllImport("advapi32", SetLastError=true)]
		[SuppressUnmanagedCodeSecurityAttribute()] 
		static extern bool InitializeSecurityDescriptor( 
			IntPtr  pSecurityDescriptor, // pointer to sd 
			int dwRevision    // revision must be SECURITY_DESCRIPTOR_REVISION (1) 
			);

		[DllImport("advapi32", SetLastError=true)]
		[SuppressUnmanagedCodeSecurityAttribute()] 
		static extern bool SetSecurityDescriptorDacl( 
			IntPtr  pSecurityDescriptor, // pointer to sd 
			bool bDaclPresent, 
			IntPtr pDacl, 
			bool bDaclDefaulted 
			); 

		[DllImport("advapi32", SetLastError=true)] 
		[SuppressUnmanagedCodeSecurityAttribute()] 
		static extern bool IsValidSecurityDescriptor(IntPtr pSecurityDescriptor); 

		[StructLayout(LayoutKind.Sequential)] 
			public struct SECURITY_ATTRIBUTES 
		{ 
			public int nLength; 
			public IntPtr pSecurityDescriptor;
			public bool bInheritHandle; 
		} 

		[StructLayout(LayoutKind.Sequential)] 
			internal struct SECURITY_DESCRIPTOR 
		{ 
			public byte Revision;
			public byte Sbz1;
			public ushort Control; 
			public uint Owner;
			public uint Group;
			public uint Sacl;
			public uint Dacl;
		} 

		/// <summary> 
		/// Opens an existing named event.
		/// </summary> 
		public static AutoResetEvent OpenNamedAutoEvent(string name) 
		{ 
			IntPtr handle = OpenEvent(EVENT_ALL_ACCESS, true, name);
			int error = Marshal.GetLastWin32Error(); 

			// Get named event handle.
			if (handle == IntPtr.Zero) 
				return null;

			// Create auto named event.
			AutoResetEvent autoNamedEvent = new AutoResetEvent(false); 
			autoNamedEvent.Close();
			autoNamedEvent.Handle = handle; 
			return autoNamedEvent;
		} 

		/// <summary> 
		/// Creates a named event in the win32 space. This is an auto 
		/// reset event that is initially not signalled. 
		/// </summary> 
		public static AutoResetEvent CreateNamedAutoEvent(string name, out bool bAlreadyExists) 
		{ 
			IntPtr pSa = CreateSaWithNullDacl();

			// Create event.
			IntPtr handle = CreateEvent(pSa /*IntPtr.Zero*/, false, false, name);

			// Initialize return value.
			bAlreadyExists = false;

			// Get named event handle.
			if (handle == IntPtr.Zero) 
				return null;

			// Check if pipe is new or already exists.
			int error = Marshal.GetLastWin32Error(); 
			bAlreadyExists = (error == ERROR_ALREADY_EXISTS);

			// Create auto named event.
			AutoResetEvent autoNamedEvent = new AutoResetEvent(false); 
			autoNamedEvent.Close();
			autoNamedEvent.Handle = handle; 
			return autoNamedEvent;
		} 
		
		public static IntPtr CreateSaWithNullDacl() 
		{
			// Grant access to everyone; assign a NULL dacl.
			IntPtr pSd;
			if (!Kernel32.CreateSdWithNullDacl(out pSd)) 
				return IntPtr.Zero;

			Kernel32.SECURITY_ATTRIBUTES sa = new Kernel32.SECURITY_ATTRIBUTES(); 
			sa.pSecurityDescriptor = pSd; 
			sa.bInheritHandle = false; 
			sa.nLength = Marshal.SizeOf(sa); 
			IntPtr pSa = Marshal.AllocHGlobal(Marshal.SizeOf(sa));
			Marshal.StructureToPtr(sa, pSa, true); 
			return pSa;
		}

		private static bool CreateSdWithNullDacl(out IntPtr pSd) 
		{ 
			bool ret = false; 
			SECURITY_DESCRIPTOR sd = new SECURITY_DESCRIPTOR(); 
			pSd = Marshal.AllocHGlobal(Marshal.SizeOf(sd)); 
			Marshal.StructureToPtr(sd, pSd, true); 
				
			// Initialize SD with revision level 1, this is mandatory.
			if (InitializeSecurityDescriptor(pSd, 1)) 
			{ 
				// Set NULL DACL in SD, this sets "everyone" access privileges.
				if (SetSecurityDescriptorDacl(pSd, true, IntPtr.Zero, true)) 
					ret = IsValidSecurityDescriptor(pSd);
				else
					ret = false;
			} 
			return ret; 
		}

    /******
     * Unfortunately, I cannot get this to work with mtglobal_msg.dll.
     * Always returns Win32 system errors. - Boris
     *****/
    public static string GetGlobalMessage(int error)
    {
      // Init return value.
      string message = null;

      // Load resource libabry.
      IntPtr hModule = LoadLibraryEx("mtglobal_msg.dll", IntPtr.Zero, LOAD_LIBRARY_AS_DATAFILE);
      if (hModule != IntPtr.Zero)
      {
        // Format the message.
        int LangId = 0;
        FormatMessage(FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER,
                      hModule, error, LangId, ref message, 0, IntPtr.Zero);

        int test = Marshal.GetLastWin32Error();
      }

      // Return result
      return message;
    }
	}
}

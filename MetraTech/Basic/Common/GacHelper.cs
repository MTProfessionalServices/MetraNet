using System;
using System.Runtime.InteropServices;


namespace MetraTech.Basic.Common
{
  public static class GacHelper
  {
    [DllImport("Fusion.dll", CharSet = CharSet.Auto)]
    internal static extern int CreateAssemblyCache(out IAssemblyCache ppAsmCache, uint dwReserved);

    public static int AddAssemblyToCache(string assembly)
    {
      IAssemblyCache ac = null;
      int hr = CreateAssemblyCache(out ac, 0);

      if (hr != 0)
      {
        return hr;
      }

      return ac.InstallAssembly(0, assembly, (IntPtr)0);
    }

    static internal int RemoveAssemblyFromCache(string assembly)
    {
      IAssemblyCache ac = null;
      uint n;

      int hr = CreateAssemblyCache(out ac, 0);

      if (hr != 0)
      {
        return hr;
      }

      return ac.UninstallAssembly(0, assembly, (IntPtr)0, out n);
    }
  }

  [ComImport, InterfaceType(ComInterfaceType.InterfaceIsIUnknown), Guid("e707dcde-d1cd-11d2-bab9-00c04f8eceae")]
  internal interface IAssemblyCache
  {
    [PreserveSig()]
    int UninstallAssembly(uint dwFlags, [MarshalAs(UnmanagedType.LPWStr)] string pszAssemblyName, IntPtr pvReserved, out uint pulDisposition);

    [PreserveSig()]
    int QueryAssemblyInfo(uint dwFlags, [MarshalAs(UnmanagedType.LPWStr)] string pszAssemblyName, IntPtr pAsmInfo);

    [PreserveSig()]
    int CreateAssemblyCacheItem(uint dwFlags, IntPtr pvReserved, out /*IAssemblyCacheItem*/IntPtr ppAsmItem, [MarshalAs(UnmanagedType.LPWStr)] String pszAssemblyName);

    [PreserveSig()]
    int CreateAssemblyScavenger(out object ppAsmScavenger);

    [PreserveSig()]
    int InstallAssembly(uint dwFlags, [MarshalAs(UnmanagedType.LPWStr)] string pszManifestFilePath, IntPtr pvReserved);
  }
}


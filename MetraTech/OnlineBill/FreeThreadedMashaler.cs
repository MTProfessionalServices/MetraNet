using System;
using System.Runtime.InteropServices;
using System.Diagnostics;

using MetraTech;

namespace MetraTech.OnlineBill
{
  [
  ComImport,
  Guid("00000003-0000-0000-c000-000000000046"),
  InterfaceType(ComInterfaceType.InterfaceIsIUnknown)
  ]
  interface IMarshal
  {
    Guid GetUnmarshalClass([In] ref Guid iid,
      [MarshalAs(UnmanagedType.Interface)] Object pvInterface,
      int dwDestContext, IntPtr pvDestContext, int mshflags);
    uint GetMarshalSizeMax([In] ref Guid iid, 
      [MarshalAs(UnmanagedType.Interface)] Object pvInterface,
      int dwDestContext, IntPtr pvDestContext, int mshflags);
    void MarshalInterface(UCOMIStream pstm, [In] ref Guid iid, 
      [MarshalAs(UnmanagedType.Interface)] Object pvInterface,
      int dwDestContext, IntPtr pvDestContext, int mshflags);
    [return:MarshalAs(UnmanagedType.Interface)]
    Object UnmarshalInterface(UCOMIStream pstm, [In] ref Guid iid);
    void ReleaseMarshalData(UCOMIStream pstm);
    void DisconnectObject(int dwReserved);
  }

  /// <summary>
  /// If you need to place a managed object into classic ASP application
  /// then you need to derive from this class (FreeThreadedMashaler). 
  /// This will provied the IMarshal interface for you and return 
  /// the correct FTM CLSID on the agility test call to GetUnmarshalClass.
  /// http://support.microsoft.com/default.aspx?scid=kb;EN-US;822828
  /// </summary>
  [Guid("B1184303-7223-4aa2-B93E-19ADD85D0A8F")]
  public class FreeThreadedMashaler: IMarshal
  {
    private Logger mLogger = new Logger("[FTM]");

    [DllImport("ole32.dll", PreserveSig=false)]
    static extern void CoCreateFreeThreadedMarshaler(
      [MarshalAs(UnmanagedType.IUnknown)] object punkOuter,
      [MarshalAs(UnmanagedType.IUnknown)] out object ppunkMarshaler);

    public FreeThreadedMashaler()
    {
      try
      {
        CoCreateFreeThreadedMarshaler(null, out m_pFTM);
      }
      catch(Exception e)
      {
        mLogger.LogError("CoCreateFreeThreadedMarshaler failed");
        mLogger.LogError(e.Message);
      }
    }

    // IMarshal implementation
    public Guid GetUnmarshalClass([In] ref Guid iid,
      [MarshalAs(UnmanagedType.Interface)] Object pvInterface,
      int dwDestContext, IntPtr pvDestContext, int mshflags)
    {
      IMarshal m = null;
      try
      {
        mLogger.LogDebug("GetUnmarshalClass");
        m = (IMarshal) m_pFTM;
      }
      catch(Exception e)
      {
        mLogger.LogError("GetUnmarshalClass failed"); 
        mLogger.LogError(e.Message);
      }
      return m.GetUnmarshalClass(ref iid, pvInterface, dwDestContext, pvDestContext, mshflags);
    }

    public uint GetMarshalSizeMax([In] ref Guid iid, 
      [MarshalAs(UnmanagedType.Interface)] Object pvInterface,
      int dwDestContext, IntPtr pvDestContext, int mshflags)
    {
      mLogger.LogDebug("GetMarshalSizeMax");
      IMarshal m = (IMarshal) m_pFTM;
      return m.GetMarshalSizeMax(ref iid, pvInterface, dwDestContext, pvDestContext, mshflags);
    }

    public void MarshalInterface(UCOMIStream pstm, [In] ref Guid iid, 
      [MarshalAs(UnmanagedType.Interface)] Object pvInterface,
      int dwDestContext, IntPtr pvDestContext, int mshflags)
    {
      mLogger.LogDebug("MarshalInterface");
      IMarshal m = (IMarshal) m_pFTM;
      m.MarshalInterface(pstm, ref iid, pvInterface, dwDestContext, pvDestContext, mshflags);
      // Safety Net
      Marshal.ReleaseComObject(pstm);
    }

    [return:MarshalAs(UnmanagedType.Interface)]
    public Object UnmarshalInterface(UCOMIStream pstm, [In] ref Guid iid)
    {
      mLogger.LogDebug("UnmarshalInterface");
      IMarshal m = (IMarshal) m_pFTM;
      Object o =  m.UnmarshalInterface(pstm, ref iid);
      Marshal.ReleaseComObject(pstm);
      return o;
    }

    public void ReleaseMarshalData(UCOMIStream pstm)
    {
      mLogger.LogDebug("ReleaseMarshalData");
      IMarshal m = (IMarshal) m_pFTM;
      m.ReleaseMarshalData(pstm);
      Marshal.ReleaseComObject(pstm);
    }

    public void DisconnectObject(int dwReserved)
    {
      mLogger.LogDebug("DisconnectObject");
      IMarshal m = (IMarshal) m_pFTM;
      m.DisconnectObject(dwReserved);
    }

    object m_pFTM = null;
  }
}


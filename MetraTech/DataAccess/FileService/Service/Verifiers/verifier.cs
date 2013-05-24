namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region acVerifier Classes
  //////////////////////////////////////////////////////////////////////////////////////
  /// <summary>
  /// Verification Base Class
  /// </summary>
  class Verifier : IDisposable
  {
    private static readonly TLog m_Log = new TLog("MetraTech.cFileService.acVerifier");
    public string Name = "acVerifier";

    // Track whether Dispose has been called.
    private bool m_Disposed = false;

    public TLog Log { get { return m_Log; } }
    public string VALUE { get; set; }

    public Verifier(string value)
    {
      if (value == string.Empty || value == null)
        throw new Exception("value is empty");
      VALUE = value;
    }
    public virtual bool Verify()
    {
      Log.Debug(CODE.__FUNCTION__);
      return false;
    }

    // Implement IDisposable.
    // Do not make this method virtual.
    // A derived class should not be able to override this method.
    public void Dispose()
    {
      Dispose(true);
      // This object will be cleaned up by the Dispose method.
      // Therefore, you should call GC.SupressFinalize to
      // take this object off the finalization queue
      // and prevent finalization code for this object
      // from executing a second time.
      GC.SuppressFinalize(this);
    }
    // Dispose(bool disposing) executes in two distinct scenarios.
    // If disposing equals true, the method has been called directly
    // or indirectly by a user's code. Managed and unmanaged resources
    // can be disposed.
    // If disposing equals false, the method has been called by the
    // runtime from inside the finalizer and you should not reference
    // other objects. Only unmanaged resources can be disposed.
    private void Dispose(bool disposing)
    {
      // Check to see if Dispose has already been called.
      if (!this.m_Disposed)
      {
        // If disposing equals true, dispose all managed
        // and unmanaged resources.
        if (m_Disposed)
        {
        }
        // Note disposing has been done.
        m_Disposed = true;
      }
    }
  }
  #endregion  
  ////////////////////////////////////////////////////////////////////////////////////// 
}

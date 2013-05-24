namespace MetraTech.FileService
{
  using System;
  using System.Diagnostics;
  using System.IO;
  using System.Runtime.InteropServices;
  using System.Threading;
  /// 
  /// A non-reentrant mutex that is implemented using
  /// a lock file, and thus works across processes,
  /// sessions, and machines (as long as the underlying
  /// FS provides robust r/w locking).
  /// 
  /// To use:
  /// 
  /// FileLock fLock = new FileLock(@"c:\foo\my.lock");
  /// 
  /// using (fLock.Acquire())
  /// {
  ///        // protected operations
  /// }
  /// 
  internal class LockFile
  {
    private readonly string filepath;
    private readonly cDisposeHelper disposeHelper;
    private Stream stream;

    public LockFile(string filepath)
    {
      this.filepath = filepath;
      this.disposeHelper = new cDisposeHelper(this);
    }

    public IDisposable Acquire()
    {
      string dir = Path.GetDirectoryName(filepath);

      lock (this)
      {
        while (stream != null)
          Monitor.Wait(this);

        while (true)
        {
          if (!Directory.Exists(dir))
            Directory.CreateDirectory(dir);
          try
          {
            Debug.Assert(stream == null, "Stream was not null--programmer error");
            stream = new FileStream(filepath, FileMode.OpenOrCreate, FileAccess.Read, FileShare.None, 8, false);
            return disposeHelper;
          }
          catch (IOException)
          {
            Thread.Sleep(500);
            continue;
          }
        }
      }
    }

    internal void Release()
    {
      lock (this)
      {
        Monitor.PulseAll(this);
        if (stream == null)
          throw new InvalidOperationException("Tried to dispose a FileLock that was not owned");
        try
        {
          stream.Close();
          try
          {
            //File.Delete(filepath);
          }
          catch (IOException) { }
        }
        finally
        {
          stream = null;
        }
      }
    }

    private class cDisposeHelper : IDisposable
    {
      private readonly LockFile lockFile;

      public cDisposeHelper(LockFile lockFile)
      {
        this.lockFile = lockFile;
      }

      public void Dispose()
      {
        lockFile.Release();
      }
    }
  }
}

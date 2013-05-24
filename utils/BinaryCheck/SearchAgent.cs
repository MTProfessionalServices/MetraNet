using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Collections;
using System.Security.Cryptography;
using Microsoft.Win32;

namespace MetraTech.Tools.BinaryCheck
{
  public sealed class FoundFile
  {
    /// <summary>
    /// Lowercase, culture invariant file name
    /// </summary>
    public string Key { get; private set; }
    public string FileName { get; private set; }
    public string Directory { get; set; }
    public DateTime CreationDateUtc { get; set; }
    public DateTime ModifiedDateUtc { get; set; }
    public string Checksum { get; set; }
    public string PDBFile { get; set; }
    public bool? IsComRegistered { get; set; }
    public string ComRegisteredPath { get; set; }
    public bool? DoesPDBDateMatch { get; set; }
    public bool IsDifferentFromMaster { get; set; }
    public string MasterDiffCode { get; set; }
    public bool IsMaster { get; set; }
    public string FileVersion { get; set; }
    public long Size { get; set; }
    public FoundFile(string fileName, string directory)
    {
      if (Utility.StringIsNullOrWhiteSpace(fileName))
        throw new ArgumentNullException("key");
      if (Utility.StringIsNullOrWhiteSpace(directory))
        throw new ArgumentNullException("directory");

      Key = fileName.ToLowerInvariant();
      FileName = fileName;
      Directory = directory;
    }
    public override bool Equals(object obj)
    {
      if (obj is FoundFile)
      {
        var other = (FoundFile)obj;

        string thisDir = Directory.TrimEnd('\\');
        string otherDir = other.Directory.TrimEnd('\\');

        return Key.Equals(other.Key, StringComparison.CurrentCultureIgnoreCase)
          && thisDir.Equals(otherDir, StringComparison.CurrentCultureIgnoreCase);
      }
      return false;
    }
    public override int GetHashCode()
    {
      return base.GetHashCode();
    }
    public override string ToString()
    {
      return Directory + Key;
    }
  }
  public delegate void SearchStarted(object sender);
  public delegate void SearchCompleted(object sender);
  public delegate void InterrogationStarted(object sender);
  public delegate void InterrogationCompleted(object sender);
  internal class CaseInsensitiveStringComparer : IEqualityComparer
  {
    public new bool Equals(object x, object y)
    {
      return ((string)x).Equals((string)y, StringComparison.CurrentCultureIgnoreCase);
    }

    public int GetHashCode(object obj)
    {
      return obj.ToString().ToLower().GetHashCode();
    }
  }
  public sealed class SearchAgent
  {
    #region events
    public event InterrogationStarted InterrogationStarted;
    private void FireInterrogationStarted()
    {
      if (InterrogationStarted != null)
        InterrogationStarted(this);
    }
    public event InterrogationCompleted InterrogationCompleted;
    private void FireInterrogationCompleted()
    {
      if (InterrogationCompleted != null)
        InterrogationCompleted(this);
    }
    public event SearchStarted SearchStarted;
    private void FireSearchStarted()
    {
      if (SearchStarted != null)
        SearchStarted(this);
    }
    public event SearchCompleted SearchCompleted;
    private void FireSearchCompleted()
    {
      if (SearchCompleted != null)
        SearchCompleted(this);
    }
    #endregion

    #region variables and properties
    private static readonly string RmpDirectory;
    private static readonly string RmpBinDirectory;
    private static readonly string RmpExtensionsDirectory;
    /// <summary>
    /// Queue of files found. The object type is MetraTech.Tools.BinaryCheck.FoundFile.
    /// Synchronized Queue. Is thread safe.
    /// </summary>
    public readonly Queue FoundQueue = Queue.Synchronized(new Queue());
    public readonly Hashtable Output = Hashtable.Synchronized(new Hashtable(new CaseInsensitiveStringComparer()));
    private readonly Dictionary<string, bool> m_fileNamesFound = new Dictionary<string, bool>();
    private readonly List<FoundFile> m_interrogated = new List<FoundFile>();
    private readonly Thread[] m_interrogationThreads;
    public SearchAgent()
    {
#if SINGLE_THREADED_DEBUG
      m_interrogationThreads = new Thread[1];
#else
      m_interrogationThreads = new Thread[Config.Default.NumThreads];
#endif
    }
    public bool IsRunning
    {
      get
      {
        return m_interrogationThreads.Any(t => t != null && t.IsAlive);
      }
    }
    public long NumFilesFound { get; private set; }
    #endregion

    static SearchAgent()
    {
      RmpDirectory = Environment.GetEnvironmentVariable("MTRMP");
      if (!RmpDirectory.EndsWith("\\"))
        RmpDirectory += "\\";

      RmpBinDirectory = Environment.GetEnvironmentVariable("MTRMPBIN");
      if (!RmpBinDirectory.EndsWith("\\"))
        RmpBinDirectory += "\\";

      RmpExtensionsDirectory = RmpDirectory + "Extensions\\";
    }

    /// <summary>
    /// Starts the search thread
    /// </summary>
    public void Start()
    {
      lock (this)
      {
        if (IsRunning)
          throw new Exception("Search is already running");

        FireSearchStarted();

        //clear out the queue
        FoundQueue.Clear();

        //discover all the files and add them to the FoundQueue
        FindFiles();

        NumFilesFound = FoundQueue.Count;

        FireSearchCompleted();

        FireInterrogationStarted();

        ThreadPriority pri;
        try
        {
          pri = (ThreadPriority)Enum.Parse(typeof(ThreadPriority), Config.Default.ThreadPriority);
        }
        catch (Exception)
        {
          throw new Exception("Unknown ThreadPriority");
        }

        //start the interrogation threads
        for (int i = 0; i < m_interrogationThreads.Length; ++i)
        {
          m_interrogationThreads[i] = new Thread(InterrogateFoundFiles);
          m_interrogationThreads[i].Priority = pri;
          m_interrogationThreads[i].Start();
        }
      }
    }

    private void FindFiles()
    {
      //Discover all the files in a blocking operation but do the 
      //interrogation of the files in separate threads.

      //get all files in the RMP bin directory
      //get all files in the extensions bin directories

      #region search RMPBIN first as those files should take prescident.
      foreach (string file in Directory.GetFiles(RmpBinDirectory, "*.dll", SearchOption.TopDirectoryOnly))
        EnqueueForInterrogation(file);
      foreach (string file in Directory.GetFiles(RmpBinDirectory, "*.exe", SearchOption.TopDirectoryOnly))
        EnqueueForInterrogation(file);
      #endregion

      #region search the extension's bin directories
      foreach (string binDir in Directory.GetDirectories(RmpExtensionsDirectory, "bin", SearchOption.AllDirectories))
      {
        if (binDir.Contains(".svn"))
          continue;

        foreach (string file in Directory.GetFiles(binDir, "*.dll", SearchOption.TopDirectoryOnly))
          EnqueueForInterrogation(file);
        foreach (string file in Directory.GetFiles(binDir, "*.exe", SearchOption.TopDirectoryOnly))
          EnqueueForInterrogation(file);
      }
      #endregion

      #region search RMP recursively
      foreach (string dir in Directory.GetDirectories(RmpDirectory, "*", SearchOption.AllDirectories))
      {
        if (dir.Contains(".svn")
          || dir.StartsWith(RmpExtensionsDirectory, StringComparison.CurrentCultureIgnoreCase)
          || dir.StartsWith(RmpBinDirectory, StringComparison.CurrentCultureIgnoreCase))
          continue;

        foreach (string file in Directory.GetFiles(dir, "*.dll", SearchOption.TopDirectoryOnly))
          EnqueueForInterrogation(file);
        foreach (string file in Directory.GetFiles(dir, "*.exe", SearchOption.TopDirectoryOnly))
          EnqueueForInterrogation(file);
      }
      #endregion
    }

    private void EnqueueForInterrogation(string file)
    {
      string dir = Path.GetDirectoryName(file);

      var foundFile = new FoundFile(Path.GetFileName(file), dir);

      string pdbFile = dir + "\\" + Path.GetFileNameWithoutExtension(file) + ".pdb";

      if (File.Exists(pdbFile))
      {
        foundFile.PDBFile = pdbFile;
      }

      foundFile.IsMaster = !m_fileNamesFound.ContainsKey(foundFile.Key);

      FoundQueue.Enqueue(foundFile);

      m_fileNamesFound[foundFile.Key] = true;
    }

    private void InterrogateFoundFiles()
    {
      while (true)
      {
        //determine the batch size and dequeue it
        FoundFile[] foundFiles;
        lock (FoundQueue.SyncRoot)
        {
          if (FoundQueue.Count == 0)
            break;

          int batchSize = FoundQueue.Count < Config.Default.InterrogateBatchSize ? FoundQueue.Count : Config.Default.InterrogateBatchSize;
          foundFiles = new FoundFile[batchSize];
          for (int i = 0; i < batchSize; ++i)
            foundFiles[i] = (FoundFile)FoundQueue.Dequeue();
        }

        //interrogate each of the files
        foreach (var foundFile in foundFiles)
          InterrogateFoundFile(foundFile);

        Thread.Sleep(Config.Default.InterrogateQueueCheckWait);
      }

      lock (m_interrogationThreads.SyncRoot)
      {
        //if this is the last thread to finish, get master differences and fire the complete event.
        if (m_interrogationThreads.Count(t => t.IsAlive) == 1)
        {
          //Have to wait until all files have been interrogated before
          //we can determine all the master differences.
          GetMasterDifferences();
          EnqueueInterrogatedFiles();
          FireInterrogationCompleted();
        }
      }
    }
    private void EnqueueInterrogatedFiles()
    {
      foreach (var foundFile in m_interrogated)
      {
        if (!Output.ContainsKey(foundFile.Key))
          Output.Add(foundFile.Key, new List<FoundFile> { foundFile });
        else
          ((List<FoundFile>)Output[foundFile.Key]).Add(foundFile);
      }
    }
    private void GetMasterDifferences()
    {
      foreach (var foundFile in m_interrogated)
      {
        if (!foundFile.IsMaster)
        {
          var master = (from i in m_interrogated
                       where i.Key == foundFile.Key && i.IsMaster
                       select i).Single();

          string masterDiffCode = null;

          if (Config.Default.VersionTriggersMismatch)
          {
            if (Utility.StringIsNullOrWhiteSpace(master.FileVersion)
              ^ Utility.StringIsNullOrWhiteSpace(foundFile.FileVersion))
            {
              masterDiffCode = "V+";
            }
            else if (!Utility.StringIsNullOrWhiteSpace(master.FileVersion)
              && !Utility.StringIsNullOrWhiteSpace(foundFile.FileVersion))
            {
              //try to compare using the Version class. If an exception is caught because the string couldn't be parsed, compare the strings.
              try
              {
                var masterV = new Version(master.FileVersion);
                var fileV = new Version(foundFile.FileVersion);
                if (masterV != fileV)
                  masterDiffCode = "V+";
              }
              catch
              {
                if (!master.FileVersion.Trim().Equals(foundFile.FileVersion.Trim(), StringComparison.CurrentCultureIgnoreCase))
                  masterDiffCode = "V+";
              }
            }
          }

          if (master.Checksum != foundFile.Checksum)
            masterDiffCode += "CKSM";

          if (masterDiffCode != null)
          {
            foundFile.MasterDiffCode = masterDiffCode.TrimEnd('+');
            foundFile.IsDifferentFromMaster = true;
          }
        }
      }
    }
    private void InterrogateFoundFile(FoundFile foundFile)
    {
      try
      {
        //get a fileinfo object to get most of the information.
        var file = foundFile.Directory + "\\" + foundFile.FileName;
        var fInfo = new FileInfo(file);
        var vInfo = FileVersionInfo.GetVersionInfo(file);

        foundFile.CreationDateUtc = fInfo.CreationTimeUtc;
        foundFile.ModifiedDateUtc = fInfo.LastWriteTimeUtc;
        foundFile.Size = fInfo.Length;
        foundFile.Checksum = GetFileChecksum(file);
        foundFile.FileVersion = vInfo.FileVersion;

        string registeredPath;
        bool? registered;
        GetComInformation(file, out registeredPath, out registered);

        foundFile.IsComRegistered = registered;
        foundFile.ComRegisteredPath = registeredPath;

        if (Config.Default.UseRelativeDir)
        {
          string rmpBin = RmpBinDirectory.ToLowerInvariant().TrimEnd('\\');
          string rmp = RmpDirectory.ToLowerInvariant().TrimEnd('\\');

          if (foundFile.Directory.StartsWith(rmpBin, StringComparison.CurrentCultureIgnoreCase))
            foundFile.Directory = foundFile.Directory.ToLowerInvariant().Replace(rmpBin, "%MTRMPBIN%");
          else
            foundFile.Directory = foundFile.Directory.ToLowerInvariant().Replace(rmp, "%MTRMP%");

          if (!Utility.StringIsNullOrWhiteSpace(foundFile.ComRegisteredPath))
          {
            if (foundFile.ComRegisteredPath.StartsWith(RmpBinDirectory, StringComparison.CurrentCultureIgnoreCase))
              foundFile.ComRegisteredPath = foundFile.ComRegisteredPath.ToLowerInvariant().Replace(rmpBin, "%MTRMPBIN%");
            else
              foundFile.ComRegisteredPath = foundFile.ComRegisteredPath.ToLowerInvariant().Replace(rmp, "%MTRMP%");
          }
        }

        if (!Utility.StringIsNullOrWhiteSpace(foundFile.PDBFile))
        {
          var pdbInfo = new FileInfo(foundFile.PDBFile);
          var ft = pdbInfo.LastWriteTimeUtc;
          foundFile.DoesPDBDateMatch = Math.Abs((pdbInfo.LastWriteTimeUtc - fInfo.LastWriteTimeUtc).TotalSeconds) <= Config.Default.PDBDateMatchRangeSeconds;
        }

        m_interrogated.Add(foundFile);
      }
      catch (Exception ex)
      {
        Console.WriteLine("There was an error interrogating the found file: " + foundFile.FileName + ". Exception: " + ex.ToString());
      }
    }
    private string GetFileChecksum(string file)
    {
      using (var fStream = File.OpenRead(file))
      {
        var sha = new SHA1Managed();
        var bytes = sha.ComputeHash(fStream);
        return BitConverter.ToString(bytes).Replace("-", string.Empty);
      }
    }
    private void GetComInformation(string file, out string registeredPath, out bool? registered)
    {
      registeredPath = null;
      registered = null;

      try
      {
        TLI.TypeLibInfo tli = new TLI.TypeLibInfo();
        tli.ContainingFile = file;
        string tlbId = tli.GUID;

        var tlbRegKey = Registry.ClassesRoot.OpenSubKey("TypeLib\\" + tlbId);
        foreach (string subKey in tlbRegKey.GetSubKeyNames())
        {
          var win32Key = tlbRegKey.OpenSubKey(subKey + "\\0\\win32");
          if (win32Key == null)
            continue;

          registeredPath = (string)win32Key.GetValue(string.Empty, null);
          if (!Utility.StringIsNullOrWhiteSpace(registeredPath))
            break;
        }

        if (!Utility.StringIsNullOrWhiteSpace(registeredPath))
        {
          registeredPath = Utility.RemoveExtraBackslashes(registeredPath);
          registered = file.Equals(registeredPath, StringComparison.CurrentCultureIgnoreCase);
        }
      }
      catch { }
    }
  }
}

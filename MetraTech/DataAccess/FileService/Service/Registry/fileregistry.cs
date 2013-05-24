namespace MetraTech.FileService
{
  using System;
  using System.Collections.Generic;
  using System.Text.RegularExpressions;
  using System.Diagnostics;
  using System.IO;
  using System.Threading;
  using System.Transactions;

  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;

  /// <summary>
  /// The cFileRegistery provides the ability to look up a file, and determine if it
  /// is in the database. 
  /// </summary>
  public class FileRegistry
  {
    private static readonly TLog m_log = new TLog("MetraTech.FileService.File.Registry");
    private FlsDatabase m_database = null;

    public FileRegistry(FlsDatabase db)
    {
      m_database = db;
    }

    /// <summary>
    /// For internal use
    /// </summary>
    private IStandardRepository Database
    {
      get
      {
        return m_database.Access;
      }
    }

    /// <summary>
    /// Use to determine the existance of a file record in the DB
    /// </summary>
    /// <param name="fullname">Fullname (including path) of the file</param>
    /// <returns>true on existance otherwise false</returns>
    private bool DoesExist(string fullname)
    {
      if (null != FindByFullName(fullname))
        return true;
      if(null != FindByName(Path.GetFileName(fullname)))
        return true;
      return false;
    }

    /// <summary>
    /// Takes the name (not the fullname) and finds the file.
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    public FileBE FindByName(string name)
    {
      MTList<DataObject> files = FindAllFilesWithNameEqualTo(name);
      m_log.Debug(String.Format("Found {0} files with this name.", files.Items.Count));

      return files.Items.Find(delegate(DataObject obj)
                              {
                                FileBE f = obj as FileBE;
                                if (null == f) return false;
                                return f._Name == name;
                              }) as FileBE;
    }

    public FileBE FindByFullName(string fullname)
    {
      FileBEBusinessKey fbk = new FileBEBusinessKey();
      fbk._FullName = fullname;
      return Database.LoadInstanceByBusinessKey(typeof(FileBE).FullName, fbk) as FileBE;
    }

    /// <summary>
    /// Searches for a files (FileBE) in the database whose name contains
    /// the given string. Returns a list containing the
    /// instance if found.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="page"></param>
    /// <returns></returns>
    public MTList<DataObject> FindAllFilesContainingName(string name)
    {
      int page = 1;

      m_log.Debug("Looking in the database for filenames containing: " + name);

      // Create the MTList<DataObject>
      var mtList = new MTList<DataObject>();

      // Set paging criteria
      mtList.CurrentPage = page;  // First page
      mtList.PageSize = 100;    // Page size

      // Set filter criteria. 
      // Select collection with a simular name.
      mtList.Filters.Add(new MTFilterElement("_Name", MTFilterElement.OperationType.Like_W, "%" + name + "%"));

      // Set sort criteria. Sort by the Name of the file.
      mtList.SortCriteria.Add(new SortCriteria("_Name", SortType.Ascending));

      // Call LoadInstances
      return Database.LoadInstances(typeof(FileBE).FullName, mtList);
    }

    public List<FileBE> FindFilesToRetrigger()
    {
      List<FileBE> result = new List<FileBE>();
      int page = 1;

      // Create the MTList<DataObject>
      var mtList = new MTList<DataObject>();

      // Set paging criteria
      mtList.CurrentPage = page;  // First page
      mtList.PageSize = 100;    // Page size

      // Set filter criteria. 
      mtList.Filters.Add(new MTFilterElement("_Retry", MTFilterElement.OperationType.NotEqual, 0)); 

      // Call LoadInstances
      MTList<DataObject> files = Database.LoadInstances(typeof(FileBE).FullName, mtList);

      foreach (FileBE file in files.Items)
      {
        result.Add(file);
      }

      return result;
    }

    /// <summary>
    /// Searches for a files (FileBE) in the database whose name equals
    /// the given string. Returns a list containing the
    /// instance if found.
    /// </summary>
    /// <param name="name">Note, this is the name of the file, not the fullname.</param>
    /// <param name="page"></param>
    /// <returns></returns>
    public MTList<DataObject> FindAllFilesWithNameEqualTo(string name)
    {
      int page = 1;

      m_log.Debug("Looking in the database for file: " + name);

      // Create the MTList<DataObject>
      var mtList = new MTList<DataObject>();

      // Set paging criteria
      mtList.CurrentPage = page;  // First page
      mtList.PageSize = 100;    // Page size

      // Set filter criteria. 
      // Select collection with a simular name.
      mtList.Filters.Add(new MTFilterElement("_Name", MTFilterElement.OperationType.Equal, name));

      // Set sort criteria. Sort by the Name of the file.
      mtList.SortCriteria.Add(new SortCriteria("_Name", SortType.Ascending));

      // Call LoadInstances
      return Database.LoadInstances(typeof(FileBE).FullName, mtList);
    }

    public List<string> GetFilesForArgumentsFromDir(string dir,
                                                    string triggerFullFileName,
                                                    List<Argument> args)
    {
      List<string> filesToUse = new List<string>();
      int numberMatchedSoFar = 0;
      int numberOfMatchesNeeded = args.Count;

      m_log.Debug("Finding files that match the required target arguments in the incoming directory.");
      m_log.Debug(String.Format("Number of files needed: {0}", numberOfMatchesNeeded));

      ParsedFileName parsedTriggerFileName = new ParsedFileName(triggerFullFileName);
      if (!parsedTriggerFileName.IsHealthy)
      {
        return filesToUse;
      }

      string filter = parsedTriggerFileName.ControlNumber + "." +
                      parsedTriggerFileName.TargetTag + ".*.*";

      m_log.Debug(String.Format("Looking for files that match this filter: " + filter));
      string[] dirFiles = Directory.GetFiles(dir, filter);
      m_log.Debug("Found " + dirFiles.Length + " files.");
      
      // Clear all the match flags.  These flags are used so that we
      // don't reuse the same argument more than once.
      foreach (Argument arg in args)
      {
        arg.IsMatched = false;
      }

      foreach (string dirFile in dirFiles)
      {
        if (numberMatchedSoFar >= numberOfMatchesNeeded)
        {
          break;
        }

        foreach (Argument arg in args)
        {
          if (arg.IsMatched || arg.Type != ArgType.FILE)
          {
           continue;
          }

          if (arg.IsMatch(dirFile))
          {
            arg.IsMatched = true;
            filesToUse.Add(dirFile);
            numberMatchedSoFar++;
            break;
          }
        }
          }

      return filesToUse;
    }

    /// <summary>
    /// Given a directory, do each of the files in the given list
    /// appear in the directory?
    /// </summary>
    /// <param name="dir"></param>
    /// <param name="fileBEs"></param>
    /// <returns>True if all files are in the directory.</returns>
    public bool AreFilesPresent(string dir, List<FileBE> fileBEs)
    {
      foreach (FileBE fileBE in fileBEs)
      {
        if (!File.Exists(fileBE._Path + fileBE._Name))
        {
          m_log.Error("Expected to find file " + fileBE._Path + fileBE._Name +
                      " but didn't.");
          return false;
        }
      }
      return true;
    }
 
    /// <summary>
    /// Adds a File record to the database.  
    /// The file timestamp is set to the current date.
    /// The file state is set to PENDING.
    /// </summary>
    /// <param name="fullname">FullName of file(including path)</param>
    /// <param name="state">Initial state for the file</param>
    /// <returns>false if file already exists, or true on creation success</returns>
    public bool Add(string fullname)
    {
      m_log.Debug("Adding file (fullname): " + fullname + " to the database.");
      string name = Path.GetFileName(fullname);
      string path = Path.GetDirectoryName(fullname) + Path.DirectorySeparatorChar;
      return Add(path, name, fullname);
    }

    /// <summary>
    /// Adds a File record to the database.  
    /// The file timestamp is set to the current date.
    /// The file state is set to PENDING.
    /// </summary>
    /// <param name="name">Name of file</param>
    /// <param name="path">Path to file</param>
    /// <param name="fullname">FullName of file(including path)</param>
    /// <returns>failure if file already exists, or true on creation success</returns>
    private bool Add(string path, string name, string fullname)
    {
      if (!DoesExist(fullname))
      {
        try
        {
          FileBE fbe = new FileBE();
          fbe._Name = name;
          fbe._Path = path;
          fbe._State = EFileState.PENDING;
          fbe._CreationDate = DateTime.Now;
          fbe.FileBEBusinessKey._FullName = fullname;
          Database.SaveInstance(fbe);
          return true;
        }
        catch (TransactionAbortedException ex)
        {
          m_log.Error("Unable to add file: " + fullname + " " + ex.Message);
        }
        catch
        {
          m_log.Error("Unable to add file: " + fullname);
        }
      }
      return false;
    }

    /// <summary>
    /// This function deletes the given file from the database.
    /// </summary>
    /// <param name="fullname">file to delete</param>
    public void Delete(string fullname)
    {
      m_log.Debug("Asking database to delete stored record for file " + fullname);
      
      FileBE file = FindByFullName(fullname);

      if (file == null)
      {
        m_log.Debug("Unexpectedly unable to find " + fullname);
        return;
      }

      try
      {
        Database.DeleteInstance(file);
        return;
      }
      catch (TransactionAbortedException ex)
      {
        m_log.Error("Unable to delete file: " + file._Name + " " + ex.Message);
      }
      catch
      {
        m_log.Error("Unable to delete file: " + file._Name);
      }
      return;
    }

    /// <summary>
    /// This function will allow values in the immediate File to be updated in the
    /// registry. It does not syncronize the states or targets
    /// </summary>
    /// <param name="file">file to update in the registry</param>
    /// <returns>true on success, false on failure</returns>
    public bool Update(FileBE file)
    {
      m_log.Debug("Asking database to update stored record for file " + file._Name);
      try
      {
        Database.SaveInstance(file);
        return true;
      }
      catch (TransactionAbortedException ex)
      {
        m_log.Error("Unable to update file: " + file._Name + " " + ex.Message);
      }
      catch
      {
        m_log.Error("Unable to update file." + file._Name);
      }
      return false;
    }
 
    /// <summary>
    /// Returns file as a string
    /// </summary>
    /// <param name="fbe"></param>
    /// <returns></returns>
    private string ToString(FileBE fbe)
    {
        return String.Format("[File{{{0}}}", fbe.FileBEBusinessKey._FullName);
    }

    /// <summary>
    /// Dumps Repository
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
      string repository_dump = "";
      MTList<DataObject> files = Database.LoadInstances(typeof(FileBE).FullName, new MTList<DataObject>());

      foreach (FileBE file in files.Items)
      {
        repository_dump += String.Format("<{0}>{1}", ToString(file), System.Environment.NewLine);
      }
      return repository_dump;
    }
  }
}

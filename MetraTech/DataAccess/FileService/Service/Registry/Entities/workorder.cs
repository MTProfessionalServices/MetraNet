namespace MetraTech.FileService
{
  using System;
  using System.IO;
  using System.Text.RegularExpressions;
  using System.Transactions;
  using System.Diagnostics;
  using System.Collections;
  using System.Collections.Generic;
  using System.Linq;
  using System.ComponentModel;
  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;

  #region Target MonitorConfiguration Delegate
  /// <summary>
  /// Event callback to handle a cWorkOrder on Path Availability Changes
  /// </summary>
  /// <param name="sender"></param>
  /// <param name="e"></param>
  public delegate void TargetWorkHandler(object sender, WorkOrder wo);
  #endregion

  /// <summary>
  /// Container to match a jobs file data to a target
  /// </summary>
  public class WorkOrder : BasicEntity
  {
    private static readonly TLog m_log = new TLog("MetraTech.FileService.WorkOrder");
    private static readonly Registry m_configManager = TSingleton<Registry>.Instance;

    /// <summary>
    /// Target for the work. The target contains the details about
    /// the executable to invoke and command line parameters.
    /// </summary>
    private Target m_target = null;

    /// <summary>
    /// Flag to determine if arguments 
    /// have been properly sorted
    /// </summary>
    private bool m_sorted = false;

    /// <summary>
    /// Set to true if an old work order in a failed state is found
    /// </summary>
    public bool IsRetry = false;

    /// <summary>
    /// List of file arguments, and corresponding file entity for the target
    /// </summary>
    public Dictionary<Argument, FileBE> Arg2FileMap = new Dictionary<Argument, FileBE>();

    /// <summary>
    /// Raw list of sorted file arguments
    /// </summary>
    public List<Argument> FileArguments = new List<Argument>();

    /// <summary>
    /// Raw list of sorted fixed arguments
    /// </summary>
    public List<Argument> FixedArguments = new List<Argument>();

    /// <summary>
    /// Raw list of sorted tracking id arguments
    /// </summary>
    public List<Argument> TrackingIDArguments = new List<Argument>();

    /// <summary>
    /// Raw list of sorted batch id arguments
    /// </summary>
    public List<Argument> BatchIDArguments = new List<Argument>();

    /// <summary>
    /// The path, arguments, and options for the process that we should start.
    /// </summary>
    public ProcessStartInfo StartInfo = new ProcessStartInfo();

    /// <summary>
    /// The process which will carry out the workorder
    /// </summary>
    public Process process = new Process();

    /// <summary>
    /// The new name of the record file which triggered the work event
    /// </summary>
    public ParsedFileName parsedNameOfFile = null;

    #region Constructors
    /// <summary>
    /// 
    /// </summary>
    /// <param name="db"></param>
    public WorkOrder(IStandardRepository db)
      : base(db, new InvocationRecordBE())
    {
      Init();
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="db"></param>
    /// <param name="be"></param>
    public WorkOrder(IStandardRepository db, InvocationRecordBE be)
      : base(db, be)
    {
      Init();
    }

    /// <summary>
    /// 
    /// </summary>
    private void Init()
    {
      StartInfo.RedirectStandardError = true;
      StartInfo.RedirectStandardOutput = true;
      StartInfo.RedirectStandardInput = true;
      StartInfo.ErrorDialog = false;
      StartInfo.CreateNoWindow = true;
      StartInfo.UseShellExecute = false;
    }

    /// <summary>
    /// How many files are needed before we can invoke the executable?
    /// </summary>
    /// <returns></returns>
    public int GetNumberOfFilesRequired()
    {
      if (m_target == null)
      {
        return 0;
      }

      return m_target.FileArguments.Count;
    }

    public bool UpdateBasedOnGivenInvocationRecord(InvocationRecordBE replacement)
    {
      if (null != replacement && replacement.Id != Guid.Empty)
      {
        Instance = replacement;
        m_sorted = false;
        FileArguments.Clear();
        FixedArguments.Clear();
        Arg2FileMap.Clear();
        TrackingIDArguments.Clear();
        BatchIDArguments.Clear();
        SortAllArguments();
        // Add the tracking argument
        TrackingId = replacement._TrackingId;
        BatchId = replacement._BatchId;
        ControlNo = replacement._ControlNumber;
        return true;
      }
      return false;
    }
    #endregion

    #region Accessors

    public string TrackingId
    {
      get
      {
        return (Instance as InvocationRecordBE)._TrackingId;
      }
      set
      {
        (Instance as InvocationRecordBE)._TrackingId = value;
      }
    }

    public string BatchId
    {
      get
      {
        return (Instance as InvocationRecordBE)._BatchId;
      }
      set
      {
        (Instance as InvocationRecordBE)._BatchId = value;
      }
    }

    public string ControlNo
    {
      get
      {
        return (Instance as InvocationRecordBE)._ControlNumber;
      }
      set
      {
        (Instance as InvocationRecordBE)._ControlNumber = value;
      }
    }

    public Target Target
    {
      get
      {
        return m_target;
      }
      set
      {
        m_target = value;
      }
    }

    public EInvocationState State
    {
      get
      {
        return (Instance as InvocationRecordBE)._State;
      }
      set
      {
        (Instance as InvocationRecordBE)._State = value;
      }
    }

    public string Command
    {
      get
      {
        return (Instance as InvocationRecordBE)._Command;
      }
      set
      {
        (Instance as InvocationRecordBE)._Command = value;
      }
    }

    public long ECode
    {
      get
      {
        return (Instance as InvocationRecordBE)._ErrorCode;
      }
      set
      {
        (Instance as InvocationRecordBE)._ErrorCode = value;
      }
    }

    /// <summary>
    /// Return the age in minutes since the trigger file was
    /// last modified.
    /// </summary>
    public int FileAgeInMinutes()
    {
      try
      {
        FileInfo info = new FileInfo(parsedNameOfFile.FullName);
        DateTime lastTouched = info.LastWriteTime;
        DateTime now = DateTime.Now;
        TimeSpan age = now.Subtract(lastTouched);
        return age.Minutes;
      }
      catch (Exception e)
      {
        m_log.Error("Unable to determine age of " + parsedNameOfFile.FullName +
                    ".  Assuming the file is new. Error: " + e.Message);
        return 0;
      }
    }

    #endregion

    #region Private Helper Routines
    private static int SortOrder(Argument x, Argument y)
    {
      if (null == x)
      {
        if (null == y) return 0;
      }
      else
      {
        if (null == y) return 1;
        if (x.Order == -1)
        {
          if (y.Order == -1) return 0;
          return 1; // X is inifinite
        }
        else if (y.Order == -1)
        {
          return -1; // Y is inifinite
        }
        if (x.Order == y.Order) return 0;
        else if (x.Order > y.Order) return 1;
      }
      return -1;
    }

    private void SortAllArguments()
    {

      if (!m_sorted)
      {
        foreach (Argument a in Target.Arguments)
        {
          switch (a.Type)
          {
            case ArgType.FILE:
              FileArguments.Add(a);
              break;
            case ArgType.BATCHID:
              BatchIDArguments.Add(a);
              break;
            case ArgType.TRACKINGID:
              TrackingIDArguments.Add(a);
              break;
            case ArgType.FIXED:
              FixedArguments.Add(a);
              break;
          }
        }
        FileArguments.Sort(SortOrder);
        TrackingIDArguments.Sort(SortOrder);
        BatchIDArguments.Sort(SortOrder);
        FixedArguments.Sort(SortOrder);
        m_sorted = true;
      }
    }

    // TODO: doesn't support conditional arguments
    /// <summary>
    /// 
    /// </summary>
    /// <param name="Files"></param>
    /// <returns>Returns true if enough files were mapped.</returns>
    public bool MapFilesToArguments(List<FileBE> Files)
    {
      if (Target.FileArguments.Count != Files.Count)
      {
        m_log.Error(String.Format("Incorrect number of pending files for target {0}. Expected {1} files but saw {2} files.",
                                  Target.Name, Target.FileArguments.Count, Files.Count));
        return false;
      }

      // Mark all the arguments as unmatched.
      foreach (Argument arg in Target.FileArguments)
      {
        arg.IsMatched = false;
      }

      // Every file must match an argument.
      foreach (FileBE file in Files)
      {
        foreach (Argument arg in Target.FileArguments)
        {
          if (!arg.IsMatched && arg.IsMatch(file._Name))
          {
            Arg2FileMap.Add(arg, file);
            arg.IsMatched = true;
            break;
          }
        }
      }

      if (Arg2FileMap.Count != Target.FileArguments.Count)
      {
        // This is unexpected.  Earlier we checked that we had enough.
        m_log.Error("Not all arguments in target were matched.");
        return false;
      }

      return true;
    }

    public List<string> FilesToNameList(List<FileBE> Files)
    {
      List<string> files = new List<string>();
      foreach (FileBE file in Files)
      {
        files.Add(file.FileBEBusinessKey._FullName);
      }
      return files;
    }

    private bool IsConditionMet(EConditionalType condition, bool isRetry)
    {
      return (condition == EConditionalType.ALWAYS ||
              (condition == EConditionalType.ON_NEW && !isRetry) ||
              (condition == EConditionalType.ON_RETRY && isRetry));
    }

    #endregion

    /// <summary>
    /// Form the command line that we need to kick of the 
    /// executable.
    /// </summary>
    public void Compile()
    {
      Target.Compile();

      // At this point we assume that the arguments have been
      // sorted, and all arguments have been resolved...
      StartInfo.FileName = Target.Executable;

      Target.Arguments.OrderBy(arg => arg.Order);

      foreach (Argument arg in Target.Arguments)

      {
        switch (arg.Type)


        {
          case ArgType.FILE:
            BindFileArgument();
            break;
          case ArgType.BATCHID:
            BindBatchIDArguments(arg);
            break;
          case ArgType.TRACKINGID:
            BindTrackingIDArguments(arg);
            break;
          case ArgType.FIXED:
            BindFixedArguments(arg);
            break;
          default:
            m_log.Info("Invalid argument(s) passed : " + arg);
            break;

        }
      }

      // Well, the file so far has been in the "new" directory.  But the files
      // are moved from there to the "inprogress" directory. So switch the
      // directory name to inprogress.
      StartInfo.Arguments = StartInfo.Arguments.Replace(m_configManager.ServiceConfiguration.NewDir,
                                                        m_configManager.ServiceConfiguration.InProgressDir);

      m_log.Info("Sorted List of arguments " +StartInfo.Arguments);
    }

    /// <summary>
    /// Binds the fixed arguments.
    /// </summary>
    /// <param name="arg"></param>
    private void BindFixedArguments(Argument arg)
    {
      StartInfo.Arguments += " ";
      if (IsConditionMet(arg.Condition, IsRetry))
        StartInfo.Arguments += arg.Format;
    }

    /// <summary>
    /// Binds a tracking id to the arguments
    /// </summary>
    /// <param name="arg"></param>
    private void BindTrackingIDArguments(Argument arg)

    {
      StartInfo.Arguments += " ";
      if (IsConditionMet(arg.Condition, IsRetry))
        StartInfo.Arguments += String.Format(arg.Format, TrackingId.ToString());
    }

    /// <summary>
    /// Binds a batchId to the arguments
    /// </summary>
    /// <param name="arg"></param>
    private void BindBatchIDArguments(Argument arg)

    {
      StartInfo.Arguments += " ";
      if (IsConditionMet(arg.Condition, IsRetry))
      {
        StartInfo.Arguments += String.Format(arg.Format, BatchId.ToString());
      }
    }


    /// <summary>
    /// Binds file args
    /// </summary>
    private void BindFileArgument()
    {
      foreach (KeyValuePair<Argument, FileBE> kvp in Arg2FileMap)

      {
        StartInfo.Arguments += " ";
        if (!IsConditionMet(kvp.Key.Condition, IsRetry)) continue;
        StartInfo.Arguments += String.Format(kvp.Key.Format, kvp.Value.FileBEBusinessKey._FullName);
        // If we have added the key to the argument list remove it so that it does not get added again
        Arg2FileMap.Remove(kvp.Key);
        break;

      }
    }

    public bool RecordAllFileArgument(WorkOrderRegistry reg)
    {
      foreach (KeyValuePair<Argument, FileBE> kvp in Arg2FileMap)
      {
        try
        {
          (Instance as InvocationRecordBE).FileBEs.Add(kvp.Value);
          //reg.SetFile(Instance as InvocationRecordBE, kvp.Value);
        }
        catch
        {
          m_log.Error("Could't log file (" + kvp.Value._Name + ") against workOrder (" + ControlNo + ")");
          return false;
        }
      }
      try
      {
        DB.SaveInstance((Instance as InvocationRecordBE));
        return true;
      }
      catch (TransactionAbortedException ex)
      {
        m_log.Error("Unable to record collection: " + ex.Message);
      }
      catch
      {
        m_log.Error("Unable to record collection.");
      }
      return false;
    }

    public bool AssignTrackingId(WorkOrderRegistry reg)
    {
      if (null == Target)
      {
        m_log.Error("Target not assigned to work order yet, failing TrackingID assignment");
        return false;
      }
      SortAllArguments();

      if (TrackingIDArguments.Count > 0)
      {
        // TODO: How do we do this across multiple machines?
        TrackingId = Guid.NewGuid().ToString();
        m_log.Info("Assigning TrackingID {" + TrackingId + "} to job.");
      }
      return true;
    }

    public bool AssignBatchId(WorkOrderRegistry reg)
    {
      if (null == Target)
      {
        m_log.Error("Target not assigned to work order yet, failing batchid assignment");
        return false;
      }
      SortAllArguments();

      if (BatchIDArguments.Count > 0)
      {
        // Init only once per multi-target run
        MetraTech.Interop.MeterRowset.MeterRowset meterrs = new MetraTech.Interop.MeterRowset.MeterRowsetClass();
        meterrs.InitSDK("DiscountServer");
        // Create a new tracking ID for the group
        BatchId = meterrs.GenerateBatchID();
        m_log.Info("Assigning BatchId from service generated batchID={" + BatchId + "}");
      }
      return true;
    }

    public void FillInControlNumber()
    {
      ControlNo = parsedNameOfFile.ControlNumber;
    }

  }
  ////////////////////////////////////////////////////////////////////////////////////// 
}

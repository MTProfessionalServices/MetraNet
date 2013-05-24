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
  /// Provides the ability to look up a file, and determine if it
  /// is in the database. 
  /// </summary>
  public class WorkOrderRegistry
  {
    #region Private Data

    private FlsDatabase m_database = null;

    private static readonly TLog m_log = new TLog("MetraTech.FileService.WorkOrder");

    #endregion

    #region Constructor
    public WorkOrderRegistry(FlsDatabase db)
    {
      m_database = db;
    }
    
    #endregion

    #region Accessors
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
    #endregion
    
    #region Public Methods
	/// <summary>
    /// Add the workorder
    /// </summary>
    /// <param name="workorder"></param>
    /// <returns></returns>
    public bool Add(WorkOrder workorder)
    {
      try
      {
        if (workorder.Instance.Id != Guid.Empty)
          Database.SaveInstance(workorder.Instance);
        else if (workorder.Instance.Id == Guid.Empty)
        {
          workorder.State = EInvocationState.NEW;
          Database.CreateInstanceFor(typeof(TargetBE).FullName,
                                     workorder.Target.Instance.Id,
                                     workorder.Instance);
        }
      }
      catch
      {
        m_log.Error("Failed to save invocation record.");
        return false;
      }
      return true;
    }

    /// <summary>
    /// Saves the command to the last state
    /// </summary>
    /// <param name="workorder"></param>
    public bool SaveCommand(InvocationRecordBE be, string cmd)
    {
      try
      {
        be._Command = cmd;
        Database.SaveInstance(be);
        return true;
      }
      catch
      {
        m_log.Error("Failed to set the command of the invocation record: " +
                    be._ControlNumber);
      }
      return false;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="file"></param>
    /// <param name="state"></param>
    /// <returns></returns>
    public bool SaveState(InvocationRecordBE be, EInvocationState state)
    {
      try
      {
        be._State = state;
        be._DateTime = DateTime.Now;
        Database.SaveInstance(be);
        return true;
      }
      catch
      {
        m_log.Error("Failed to set the state of the invocation record: " +
            be._ControlNumber);
      }
      return false;
    }

    /// <summary>
    /// Gets the work order's collection(if present)
    /// </summary>
    /// <param name="file">file reference to lookup work order for..</param>
    /// <returns>null on failure, pointer to record on success</returns>
    public List<FileBE> GetFiles(InvocationRecordBE workOrder, List<FileBE> files)
    {
      MTList<DataObject> dblist = Database.LoadInstancesFor(typeof(FileBE).FullName,
                                                            typeof(InvocationRecordBE).FullName,
                                                            workOrder.Id, new MTList<DataObject>());
      foreach (FileBE file in dblist.Items)
      {
        files.Add(file);
      }
      return files;
    }


    /// <summary>
    /// Sets a workOrder's collection
    /// </summary>
    /// <param name="workOrder"></param>
    /// <returns></returns>
    public bool SaveFiles(WorkOrder workOrder)
    {
      foreach (KeyValuePair<Argument, FileBE> kvp in workOrder.Arg2FileMap)
      {
        if (!SaveFile(workOrder.Instance as InvocationRecordBE, kvp.Value))
          return false;
      }
      return true;
    }



    /// <summary>
    /// Finds a workOrder by control number.  Returns the first workOrder found
    /// with this control number.  We really expect there to only be one workOrder
    /// associated with a job.
    /// </summary>
    /// <param name="controlNumber"></param>
    /// <returns></returns>
    public InvocationRecordBE FindByControlNumber(string controlNumber)
    {
      var mtList = Find("_ControlNumber", controlNumber, MTFilterElement.OperationType.Equal);

      if (mtList == null || mtList.Items.Count < 1)
      {
        return null;
      }

      if (mtList.Items.Count > 1)
      {
        m_log.Error("Unexpectedly found multiple jobs with control number: " + controlNumber);
      }

      return (mtList.Items[0] as InvocationRecordBE);
    }

    /// <summary>
    /// Finds a workOrder by Tracking ID
    /// </summary>
    /// <param name="tid"></param>
    /// <returns></returns>
    public InvocationRecordBE FindByTID(string tid)
    {
      var mtList = Find("_TrackingId", tid, MTFilterElement.OperationType.Equal);
      if (null == mtList)
        return null;
      if (mtList.Items.Count != 1)
        return null;
      return mtList.Items[0] as InvocationRecordBE;
    }

    /// <summary>
    /// Gets the file's work order (if present)
    /// </summary>
    /// <param name="file">file reference to lookup work order for..</param>
    /// <returns>null on failure, pointer to record on success</returns>
    public InvocationRecordBE FindByFile(FileBE file)
    {
      return Database.LoadInstanceFor(typeof(InvocationRecordBE).FullName,
                                      typeof(FileBE).FullName,
                                      file.Id) as InvocationRecordBE;
    }
    #endregion 

    #region Private Methods

    /// <summary>
    /// Sets a workOrder's file
    /// </summary>
    /// <param name="workOrder">workorder to associate</param>
    /// <param name="file">file to associate</param>
    /// <returns>true on success, false on failure</returns>
    private bool SaveFile(InvocationRecordBE workOrder, FileBE file)
    {
      Database.CreateRelationship(workOrder, file);
      return true;
    }

    private MTList<DataObject> Find(string fieldnm, string value, MTFilterElement.OperationType op)
    {
      var mtList = new MTList<DataObject>();

      mtList.CurrentPage = 1;  // First page
      mtList.PageSize = 10;    // Page size

      mtList.Filters.Add(new MTFilterElement(fieldnm, op, value));

      // Set sort criteria. Sort by the Name of the teacher.
      mtList.SortCriteria.Add(new SortCriteria(fieldnm, SortType.Ascending));

      // Call LoadInstances
      return Database.LoadInstances(typeof(InvocationRecordBE).FullName, mtList);
    }

    #endregion    
  }
}

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
  public class TargetRegistry
  {
    #region Private Data Members

    private List<Target> m_targets = new List<Target>();
    private static readonly TLog m_log = new TLog("MetraTech.FileService.Target.Registry");
    private FlsDatabase m_database = null;

    #endregion Private Data Members

    #region Constructor
    public TargetRegistry(FlsDatabase db)
    {
      m_database = db;
    }
    #endregion Constructor

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
    #endregion Accessors

    #region Public Methods

    /// <summary>
    /// Returns true if the cache of configured targets was updated.
    /// </summary>
    /// <returns>false if no change detected, true if change detected.</returns>
    public bool WasUpdated()
    {
      // Mark all dirty. As we go through the list
      // we will mark them back to new/changed/current
      // thus we can ID any that are ready to be removed 
      // very easily.
      foreach (Target t in m_targets)
      {
        t.State = Target.TState.GARBAGE;
      }

      MTList<DataObject> targets = Database.LoadInstances(typeof(TargetBE).FullName, new MTList<DataObject>());
      foreach (TargetBE tgt in targets.Items)
      {
        Target existingTarget = m_targets.Find(delegate(Target t) { return (t.Instance.Id == tgt.Id); });
        if (null == existingTarget) // New target case
        {
          Target target = new Target(Database, tgt);
          if (!target.IsHealthy)
          {
            // Error already logged.
            continue;
          }

          try
          {
            lock (this) // Ensure we don't corrupt any lookups when adding
            {
              m_targets.Add(target);
              target.State = Target.TState.NEW;
              m_log.Debug("Read FLS configuration for target: " + target.Name);
            }
          }
          catch (System.ArgumentNullException ex)
          {
            // Key is null.
            m_log.Error(ex.Message);
          }
          catch (System.ArgumentException ex)
          {
            // An element with the same key already exists in the System.Collections.Generic.Dictionary<TKey,TValue>.
            m_log.Error(ex.Message);
          }
          catch (Exception ex)
          {
            m_log.Error(ex.Message);
          }
        }
        else // Existing case
        {
          if (!existingTarget.IsUpToDate()) 
          {
            lock (this) // Ensure we don't corrupt any lookups when adding
            {
              m_targets.Remove(existingTarget);

              Target replacement = new Target(existingTarget);
              if (!replacement.IsHealthy)
              {
                // Error already logged.
                continue;
              }

              try
              {
                
                m_targets.Add(replacement);
                replacement.State = Target.TState.CHANGED;
              }
              catch (System.ArgumentNullException ex)
              {
                //     key is null.
                m_log.Error(ex.Message);
              }
              catch (System.ArgumentException ex)
              {
                //     An element with the same key already exists in the System.Collections.Generic.Dictionary<TKey,TValue>.
                m_log.Error(ex.Message);
              }
            }
          }
          else
          {
            // Still there and no changes.
            existingTarget.State = Target.TState.CURRENT;
          }
        }
      }
      foreach (Target t in m_targets)
      {
        // If we didn't get any changes (new or changed)
        // then none are garbage, and all are good...
        switch (t.State)
        {
          case Target.TState.CURRENT: continue;
          case Target.TState.CHANGED: return true;
          case Target.TState.NEW:     return true;
          // Signal back to the Dispatcher, to have it 
          // drive the compile, and to ensure any jobs with 
          // targets in Garbage start may be reassessed

          // TODO: Build list of garbage targets and 
          // pass back for any active workOrders
          // And remove them from the the registry
          case Target.TState.GARBAGE: m_log.Debug("Target removal indicated."); return true;
        }
      }
      return false;
    }

    /// <summary>
    /// Use to determine if the filename matches any target
    /// </summary>
    /// <param name="filenm"></param>
    /// <returns></returns>
    public bool IsTargetMatch(string filenm)
    {
      return (null != FindTarget(filenm));
    }

    /// <summary>
    /// Use to lookup a target that matches the filename
    /// </summary>
    /// <param name="filenm"></param>
    /// <returns></returns>
    public Target FindTarget(string filename)
    {
      ParsedFileName parsedName = new ParsedFileName(filename);
      if (!parsedName.IsHealthy)
      {
        m_log.Debug("Unable to parse the file name: " + filename);
        return null;
      }

      Target val = null;
      lock (this)
      {
        val = m_targets.Find(delegate(Target t) { return t.Filter.IsMatch(parsedName.TargetTag); });
      }
      return val;
    }

    #endregion Public Methods
  }
}
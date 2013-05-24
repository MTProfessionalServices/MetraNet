namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using System.Transactions;

  using MetraTech.Basic;
  using MetraTech.Basic.Config;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  //////////////////////////////////////////////////////////////////////////////////////
  /// <summary>
  /// 
  /// </summary>
  public abstract class BasicEntity
  {
    private DataObject m_Instance = null;
    private IStandardRepository m_DB = null;
    public BasicEntity(IStandardRepository db, DataObject instance)
    {
      if (db == null)
      {
        throw new Exception("Unable to continue, no database object available");
      }
      if (instance == null)
      {
        throw new Exception("No instance provided for construction");
      }
      m_Instance = instance;
      m_DB = db;
    }
    public BasicEntity(BasicEntity previousEntity)
    {
      m_DB = previousEntity.DB;
      m_Instance = previousEntity.Instance;
    }
    public DataObject Instance
    {
      get
      {
        return m_Instance;
      }
      set
      {
        m_Instance = value;
      }
    }
    public IStandardRepository DB
    {
      get
      {
        return m_DB;
      }
    }
    /// <summary>
    /// Returns true if the held copy of the data matches the 
    /// current version stored in the database.
    /// </summary>
    /// <returns>true on most current data, false if out of date</returns>
    public virtual bool IsUpToDate()
    {
      return false;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
}

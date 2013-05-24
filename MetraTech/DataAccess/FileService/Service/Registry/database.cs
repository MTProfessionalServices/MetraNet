namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
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
  #region cDatabase Base Class
  /// <summary>
  /// Base class for configuration information. 
  /// Provides a log and repository interface
  /// </summary>
  public class FlsDatabase
  {
    #region Private Data
    private static readonly TLog m_Log = new TLog("MetraTech.cFileService.cDatabase");
    private IStandardRepository m_Repository = null; 
    #endregion

    #region Constructor
    /// <summary>
    /// Constructor
    /// </summary>
    public FlsDatabase()
    {
      RepositoryAccess.Instance.Initialize();
      m_Repository = RepositoryAccess.Instance.GetRepository();
    }
    #endregion   

    #region Accessors
    public static string RootDir { get { return SystemConfig.GetRmpDir(); } }
    public static string ConfigDir { get { return SystemConfig.GetConfigDir(); } }
    public static string ExtensionDir { get { return SystemConfig.GetExtensionsDir(); } }
    public IStandardRepository Access { get { return m_Repository; } }

    #endregion 

    #region Overloadables
    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public virtual bool IsCurrent()
    {
      m_Log.Error(CODE.__FUNCTION__ + " should not be called");
      return true;
    }
    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public virtual bool Update()
    {
      m_Log.Error(CODE.__FUNCTION__ + " should not be called");
      return true;
    } 
    #endregion
  } 
  #endregion
  //////////////////////////////////////////////////////////////////////////////////////
}

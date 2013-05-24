using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using System.IO;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Interop.MTAuth;
using MetraTech.DataAccess;
using MetraTech.Interop.Rowset;
using MetraTech.UsageServer;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IUsmService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetConfigCrossServer(out ConfigCrossServer config);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SetConfigCrossServer(ConfigCrossServer config);
  }

  [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
  public class UsmService : CMASServiceBase, IUsmService
  {
    #region Private Attributes
    private static Logger mLogger = new Logger("[UsmService]");
    #endregion

    #region Public Methods

    /// <summary>
    /// Retreive the cross-server USM configuration values from the database.
    /// If the values are uninitialized in the database, then usmServer.xml
    /// will be used as the basis for the values.   If usmServer.xml cannot
    /// be used, then hardcoded default values are used.
    /// </summary>
    /// <param name="config">retreived configuration</param>
    public void GetConfigCrossServer(out ConfigCrossServer config)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetConfigCrossServer"))
      {
        try
        {
          config = ConfigCrossServerManager.GetConfig();
        }
        catch (Exception e)
        {
          mLogger.LogException("Unhandled exception caught in GetConfigCrossServer: ", e);
          throw new MASBasicException("Unexpected error in GetConfigCrossServer");
        }
      }
    }

    /// <summary>
    /// Set the cross-server USM configuration.  These values are stored in the
    /// database.
    /// </summary>
    /// <param name="config">values to store</param>
    public void SetConfigCrossServer(ConfigCrossServer config)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SetConfigCrossServer"))
      {
        try
        {
          ConfigCrossServerManager.SetConfig(config);
        }
        catch (Exception e)
        {
          mLogger.LogException("Exception caught in SetConfigCrossServer: ", e);
          throw new MASBasicException("Unexpected error in SetConfigCrossServer.");
        }
      }
    }

    #endregion
  }
}

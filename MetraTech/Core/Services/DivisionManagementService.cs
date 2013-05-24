using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using Core.Core;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IDivisionManagementService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetDivisions(ref MTList<Division> divisions);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateDivision(ref Division division);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  class DivisionManagementService : CMASServiceBase, IDivisionManagementService
  {
    private static Logger m_Logger = new Logger("[DivisionManagementService]");

    #region IDivisionManagementService Members

    public void GetDivisions(ref MTList<Division> divisions)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetDivisions"))
      {
        try
        {
          m_Logger.LogDebug("Getting Divisions");
          StandardRepository.Instance.LoadInstances<Division>(ref divisions);
        }
        #region Error Handling
        catch (LoadDataException lde)
        {
          m_Logger.LogException("Data Load Exception retrieving Divisions", lde);
          throw new MASBasicException("Data error retrieving Divisions");
        }
        catch (MetraTech.BusinessEntity.DataAccess.Exception.DataAccessException dae)
        {
          m_Logger.LogException("Data access exception retrieving Divisions", dae);
          throw new MASBasicException("Data access error retrieving Divisions");
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unexpected error retrieving Divisions", e);
          throw new MASBasicException("Unexpected error retrieving Divisions");
        }
        #endregion
      }
    }

    public void CreateDivision(ref Division division)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CreateDivision"))
      {
        try
        {
          m_Logger.LogDebug("Creating a new Division");

          StandardRepository.Instance.SaveInstance<Division>(ref division);

          m_Logger.LogInfo("Created Division with name {0}", division.DivisionBusinessKey.Name);
        }
        #region Error Handling
        catch (SaveDataException sde)
        {
          m_Logger.LogException("Data Save Exception saving Division", sde);
          throw new MASBasicException("Data error saving Division");
        }
        catch (MetraTech.BusinessEntity.DataAccess.Exception.DataAccessException dae)
        {
          m_Logger.LogException("Data access exception saving Division", dae);
          throw new MASBasicException("Data access error saving Division");
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unexpected error saving Division", e);
          throw new MASBasicException("Unexpected error saving Division");
        }
        #endregion
      }
    }

    #endregion
  }
}

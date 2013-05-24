using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using MetraTech.Basic;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;
using MetraTech.Interop.MTHooklib;
using MetraTech;

namespace MetraTech.BusinessEntity.Hook
{
  [Guid("92A0526B-24F7-4606-9C09-3BC12EBF102C")]
  public interface IBusinessEntityHook : IMTHook
  {
  }

  [Guid("047E2A49-253F-4c00-90F0-319442D0DD10")]
  [ClassInterface(ClassInterfaceType.None)]
  public class BusinessEntityHook : IBusinessEntityHook
  {
    public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
    {
      try
      {
        logger.Debug("Synchronizing BME's");
        MetadataAccess.Instance.Synchronize();
      }
      catch (Exception e)
      {
        logger.Error("BusinessEntityHook failed with the exception: ", e);
        System.Threading.Thread.Sleep(1000); // sleep so that exception is written to the mtlog.
        throw;
      }
    }


    #region Data
    private static readonly ILog logger = LogManager.GetLogger("BusinessEntityHook");
    #endregion
  }

  [Guid("54C9D27F-D043-42E0-BACD-C163C1883B1D")]
  public interface IBusinessEntityBuildHook : IMTHook
  {
  }

  [Guid("5B0D50D5-8679-4F08-A174-FEC8C67FBDD4")]
  [ClassInterface(ClassInterfaceType.None)]
  public class BusinessEntityBuildHook : IBusinessEntityBuildHook
  {
    public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
    {
      try
      {
        logger.Debug("Building BME's");
        var syncManager = new SyncManager();
        syncManager.BuildAssemblies();
      }
      catch (Exception e)
      {
        logger.Error("BusinessEntityBuildHook failed with the exception: ", e);
        System.Threading.Thread.Sleep(1000); // sleep so that exception is written to the mtlog.
        throw;
      }
    }


    #region Data
    private static readonly ILog logger = LogManager.GetLogger("BusinessEntityBuildHook");
    #endregion
  }
}

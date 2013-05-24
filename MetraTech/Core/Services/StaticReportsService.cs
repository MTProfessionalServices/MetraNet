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
using MetraTech.Reports;
using MetraTech.Interop.Rowset;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Billing;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IStaticReportsService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetReportsList(AccountIdentifier accountId, int? intervalId, out List<ReportFile> reportFiles);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetReportFile(AccountIdentifier accountId, int? intervalId, string reportFile, out Stream reportData);
  }

  [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
  public class StaticReportsService : CMASServiceBase, IStaticReportsService
  {
    #region Private members
    private static Logger mLogger = new Logger("[StaticReportsService]");
    #endregion

    #region IStaticReportsService Members
    [OperationCapability("Manage Account Hierarchies")]
    public void GetReportsList(AccountIdentifier accountId, int? intervalId, out List<ReportFile> reportFiles)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetReportsList"))
      {
        reportFiles = null;
        try
        {
          int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(accountId);
          if (id_acc == -1)
          {
            throw new MASBasicException("Invalid account specified");
          }

          int actualInterval = -1;
          if (intervalId.HasValue)
          {
            actualInterval = intervalId.Value;
          }
          else
          {
            actualInterval = SliceConverter.GetCurrentAccountInterval(id_acc);
          }

          if (actualInterval <= 0)
          {
            throw new MASBasicException("Unable to resolve usage interval");
          }

          if (HasManageAccHeirarchyAccess(id_acc, AccessLevel.READ, MTHierarchyPathWildCard.SINGLE))
          {
            ReportViewer viewer = new ReportViewer();
            MTInMemRowset inMemRowset = viewer.GetFileList(actualInterval.ToString(), id_acc);

            inMemRowset.MoveFirst();

            reportFiles = new List<ReportFile>();
            while (!System.Convert.ToBoolean(inMemRowset.EOF))
            {
              ReportFile file = new ReportFile();
              file.FileName = (string)inMemRowset.get_Value("FileName");
              file.DisplayName = (string)inMemRowset.get_Value("DisplayName");

              reportFiles.Add(file);

              inMemRowset.MoveNext();
            }
          }
          else
          {
            throw new MASBasicException("Caller is not authorized to access specific account");
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("MAS Exception caught in GetReportsList", masE);
          throw;
        }
        catch (Exception ex)
        {
          mLogger.LogException("Unhandled Exception caught in GetReportsList", ex);
          throw new MASBasicException("Unexpected error in GetReportsList");
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void GetReportFile(AccountIdentifier accountId, int? intervalId, string reportFile, out Stream reportData)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetReportFile"))
      {
        reportData = null;

        try
        {
          int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(accountId);
          if (id_acc == -1)
          {
            throw new MASBasicException("Invalid account specified");
          }

          int actualInterval = -1;
          if (intervalId.HasValue)
          {
            actualInterval = intervalId.Value;
          }
          else
          {
            actualInterval = SliceConverter.GetCurrentAccountInterval(id_acc);
          }

          if (actualInterval <= 0)
          {
            throw new MASBasicException("Unable to resolve usage interval");
          }

          if (HasManageAccHeirarchyAccess(id_acc, AccessLevel.READ, MTHierarchyPathWildCard.SINGLE))
          {
            ReportViewer viewer = new ReportViewer(id_acc, actualInterval);
            Byte[] report = viewer.GetReportFile(reportFile);

            reportData = new MemoryStream(report);
          }
          else
          {
            throw new MASBasicException("Caller is not authorized to access specific account");
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("MAS Exception caught in GetReportFile", masE);
          throw;
        }
        catch (Exception ex)
        {
          mLogger.LogException("Unhandled Exception caught in GetReportFile", ex);
          throw new MASBasicException("Unexpected error in GetReportFile");
        }
      }
    }

    #endregion

    #region Helper methods
    #endregion
  }
}

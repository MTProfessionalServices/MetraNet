using System;
using System.Collections.Generic;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.BusinessEntity.DataAccess;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using Core.FileLandingService;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IFLSManagementService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetFileDetails(string fileName, out string details);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetFailedFiles(out List<string> fileNames);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class FLSManagementService : CMASServiceBase, IFLSManagementService
  {
    private static Logger mLogger = new Logger("[FLSManagementService]");

    #region FLSManagementService Methods

    /// <summary>
    /// This method gest the details of a file with respect to its process with FLS
    /// </summary>
    /// <param name="fileName">This is the fullname of the file</param>
    /// <param name="details">These are the details associated with a file</param>
    [OperationCapability("View FLS Files")]
    public void GetFileDetails(string fileName, out string details)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetFileDetails"))
      {
        var resourceManager = new ResourcesManager();

        mLogger.LogDebug("{0} {1}", resourceManager.GetLocalizedResource("TEXT_RETRIEVING_FILENAME_DETAILS"), fileName);
        try
        {
          FileBEBusinessKey bk = new FileBEBusinessKey();
          bk._FullName = fileName;
          bk.EntityFullName = typeof(FileBE).FullName;
          FileBE file = StandardRepository.Instance.LoadInstanceByBusinessKey(typeof(FileBE).FullName, bk) as FileBE;

          if (file._State == EFileState.REJECTED)
          {
            if (String.IsNullOrWhiteSpace(file._ErrorMessage))
            {
              details = resourceManager.GetLocalizedResource("TEXT_FILE_REJECTED");
            }
            else
            {
              details = file._ErrorMessage;
            }
          }
          else if (file._State == EFileState.PENDING)
            details = resourceManager.GetLocalizedResource("TEXT_FILE_PENDING");
          else
          {
            if (String.IsNullOrWhiteSpace(file._ErrorMessage))
            {
              details = "";

              file.InvocationRecordBE = StandardRepository.Instance.LoadInstanceFor<FileBE, InvocationRecordBE>(file.Id);
              if (file.InvocationRecordBE._State == EInvocationState.ACTIVE)
                details = resourceManager.GetLocalizedResource("TEXT_FILE_PROCESSING");
              else if (file.InvocationRecordBE._State == EInvocationState.COMPLETED)
                details = resourceManager.GetLocalizedResource("TEXT_FILE_COMPLETED");
            }
            else
              details = file._ErrorMessage;
          }
          mLogger.LogDebug("{0} {1}.", resourceManager.GetLocalizedResource("TEXT_RETRIEVED_FILE_DETAILS"), fileName);
        }
        catch (LoadDataException lde)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_LOAD_DATA_EXCEPTION"), lde);
          throw;
        }
        catch (MetraTech.BusinessEntity.DataAccess.Exception.DataAccessException dae)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_DATA_ACCESS_EXCEPTION"), dae);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNKOWN_EXCEPTION"), e);
          throw;
        }
      }
    }

    /// <summary>
    /// This method returns a list of the failed files
    /// </summary>
    /// <param name="fileNames">A list of failed filenames</param>
    [OperationCapability("View FLS Files")]
    public void GetFailedFiles(out List<string> fileNames)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetFailedFiles"))
      {
        var resourceManager = new ResourcesManager();
        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_FILES"));
        fileNames = new List<string>();
        MTList<InvocationRecordBE> jobs = new MTList<InvocationRecordBE>();
        jobs.Filters.Add(new MTFilterElement("_State", MTFilterElement.OperationType.Equal, EInvocationState.FAILED));
        try
        {
          FileBE b = new FileBE();
          StandardRepository.Instance.LoadInstances<InvocationRecordBE>(ref jobs);

          foreach (InvocationRecordBE job in jobs.Items)
          {
            MTList<FileBE> files = new MTList<FileBE>();
            StandardRepository.Instance.LoadInstancesFor<InvocationRecordBE, FileBE>(job.Id, ref files,
                                                                                     InvocationRecordBE.
                                                                                       Relationship_InvocationRecordBE_FileBE);

            // add the files that have errors 
            // TODO: What do we do if a job had one file processed, the next failed, and one is queued up to run.  Still researching
            foreach (FileBE file in files.Items)
            {
              if (job._State == EInvocationState.FAILED)
              {
                // if the job has failed, then 
                if (file._State == EFileState.ASSIGNED)
                {
                  if (!String.IsNullOrEmpty((file._ErrorMessage)))
                    fileNames.Add(file.FileBEBusinessKey._FullName);
                }
              }
            }
          }

          // add the rejected files too
          MTList<FileBE> rejectedFiles = new MTList<FileBE>();
          rejectedFiles.Filters.Add(new MTFilterElement("_State", MTFilterElement.OperationType.Equal, EFileState.REJECTED));
          StandardRepository.Instance.LoadInstances<FileBE>(ref rejectedFiles);
          foreach (FileBE rejectedFile in rejectedFiles.Items)
            fileNames.Add(rejectedFile.FileBEBusinessKey._FullName);

          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_FILES"));
        }
        catch (LoadDataException lde)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_LOAD_DATA_EXCEPTION"), lde);
          throw;
        }
        catch (MetraTech.BusinessEntity.DataAccess.Exception.DataAccessException dae)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_DATA_ACCESS_EXCEPTION"), dae);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNKOWN_EXCEPTION"), e);
          throw;
        }
      }
    }



    #endregion

    #region private methods
    #endregion

  }
}

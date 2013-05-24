using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.Debug.Diagnostics;
using MetraTech.Interop.MTAuth;

namespace MetraTech.BusinessEntity.Service
{
  public abstract class BusinessEntityService : CMASServiceBase
  {
    static BusinessEntityService()
    {
      ServiceStarting += BusinessEntityService_ServiceStarting;
    }

    #region Protected Properties
    protected static IStandardRepository Repository
    {
      get
      {
        return standardRepository;
      }
    }

    #endregion

    #region Protected Methods

    protected void InternalDelete(string entityName, Guid id)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Deleting entity of type '{0}' and id '{1}'", entityName, id));
        Repository.Delete(entityName, id);
      }
      catch (Exception e)
      {
        string message = String.Format("Error deleting entity of type '{0}' and id '{1}'", entityName, id);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    protected void InternalDeleteAll(string entityName)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Deleting all entities of type '{0}'", entityName));
        Repository.Delete(entityName);
      }
      catch (Exception e)
      {
        string message = String.Format("Error deleting all entities of type '{0}'", entityName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    protected void InternalCheckCapability(string extensionName, AccessType accessType)
    {
      try
      {
        if (accessType == AccessType.Read)
        {
          if (!CheckReadAccess(extensionName) && !CheckWriteAccess(extensionName))
          {
            throw new MASBasicException(String.Format("Failed capability check for extension '{0}'", extensionName));
          }
        }
        else if (accessType == AccessType.Write)
        {
          if (!CheckWriteAccess(extensionName))
          {
            throw new MASBasicException(String.Format("Failed capability check for extension '{0}'", extensionName));
          }
        }
      }
      catch (MASBasicException)
      {
        throw;
      }
      catch (Exception e)
      {
        string message = String.Format("Failed capability check for extension '{0}'", extensionName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void InternalGetBusinessKeyProperties(string entityName, out List<PropertyInstance> propertyInstances)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        Entity entity = MetadataRepository.Instance.GetEntity(entityName);
        Check.Require(entity != null, String.Format("Cannot find entity '{0}'", entityName), SystemConfig.CallerInfo);
        EntityInstance entityInstance = entity.GetEntityInstance();
        propertyInstances = entityInstance.GetBusinessKeyProperties();
      }
      catch (Exception e)
      {
        string message = String.Format("Error getting business key properties for entity '{0}'", entityName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }
    #endregion

    #region Private Methods
    private static void BusinessEntityService_ServiceStarting()
    {
      logger.Info("BusinessEntityService - Service starting");

      RepositoryAccess.Instance.Initialize();
      standardRepository = RepositoryAccess.Instance.GetRepository();
    }

    private bool CheckReadAccess(string extensionName)
    {
      IMTCompositeCapability capability = null;
      IMTSessionContext sessionContext = GetSessionContext();
      var security = new MTSecurityClass();
      string capabilityName = "Read Business Modeling Entities";
      capability = security.GetCapabilityTypeByName(capabilityName).CreateInstance();
      Check.Require(capability != null,
                    String.Format("Cannot create capability with name '{0}'", capabilityName),
                    SystemConfig.CallerInfo);
      capability.GetAtomicEnumCapability().SetParameter(extensionName);

      return sessionContext.SecurityContext.HasAccess(capability);
    }

    private bool CheckWriteAccess(string extensionName)
    {
      IMTCompositeCapability capability = null;
      IMTSessionContext sessionContext = GetSessionContext();
      var security = new MTSecurityClass();

      string capabilityName = "Write Business Modeling Entities";
      capability = security.GetCapabilityTypeByName(capabilityName).CreateInstance();
      Check.Require(capability != null,
                    String.Format("Cannot create capability with name '{0}'", capabilityName),
                    SystemConfig.CallerInfo);
      capability.GetAtomicEnumCapability().SetParameter(extensionName);

      return sessionContext.SecurityContext.HasAccess(capability);
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("BusinessEntityService");
    private static IStandardRepository standardRepository;
    #endregion
  }

 
}

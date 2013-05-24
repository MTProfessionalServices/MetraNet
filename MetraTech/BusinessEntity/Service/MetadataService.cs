using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;

using MetraTech.Basic;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.BusinessEntity.Service
{
  [ServiceContract()]
  public interface IMetadataService
  {
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetEntity(string entityName, out Entity entity);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetEntities(out List<Entity> entities);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetTargetEntities(string entityName, out List<RelatedEntity> targetEntities);
  }

  [ServiceBehavior(MaxItemsInObjectGraph = int.MaxValue)]
  public class MetadataService : BusinessEntityService, IMetadataService
  {
    public void GetEntity(string entityName, out Entity entity)
    {
      entity = null;
      try
      {
        logger.Debug(String.Format("Getting entity of type '{0}'", entityName));

        using (var timer = new HighResolutionTimer("MetadataService::GetEntity method"))
        {
          entity = MetadataRepository.Instance.GetEntity(entityName);
          if (entity == null)
          {
            logger.Warn(String.Format("Cannot find entity of type '{0}'", entityName));
          }
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error getting entity of type '{0}'", entityName);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void GetEntities(out List<Entity> entities)
    {
      entities = new List<Entity>();

      try
      {
        logger.Debug(String.Format("Getting all entities"));
        using (var timer = new HighResolutionTimer("MetadataService::GetEntities method"))
        {
          entities.AddRange(MetadataRepository.Instance.GetEntities(false));
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error getting entities");

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void GetTargetEntities(string entityName, out List<RelatedEntity> targetEntities)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      targetEntities = new List<RelatedEntity>();
      try
      {
        logger.Debug(String.Format("Getting target entities for type '{0}'", entityName));
        using (var timer = new HighResolutionTimer("MetadataService::GetTargetEntities method"))
        {
          targetEntities.AddRange(MetadataRepository.Instance.GetTargetEntities(entityName, true));
          if (targetEntities.Count == 0)
          {
            logger.Warn(String.Format("Cannot find target entities for type '{0}'", entityName));
          }
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error getting target entities for type '{0}'", entityName);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }
    
    #region Data
    private static readonly ILog logger = LogManager.GetLogger("MetadataService");
    #endregion
  }

 
}

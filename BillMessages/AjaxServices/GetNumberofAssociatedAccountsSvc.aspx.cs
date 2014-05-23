//
// http://localhost/MetraNet/AjaxServices/GetNumberofAssociatedAccountsSvc.aspx?&Name=Core.OrderManagement.Order&Assembly=Core.OrderManagement.Entity&AccountDef=123
//
using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Text;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class AjaxServices_GetNumberofAssociatedAccountsSvc : MTListServicePage
{
  private const int MaxRecordsPerBatch = 50;

  private string _objectName;
  private string _accountDefProp;
  private string _subscriptionDefProp;
  private string _parentName;
  private string _parentId;
  private string _unrelatedEntityList;
  private string _createRelationships;
  private string _targetEntityIds;
 

  protected bool ExtractDataInternal(ref MTList<EntityInstance> items, int batchId, int limit)
  {
    try
    {
      items.Items.Clear();
      items.PageSize = limit;
      items.CurrentPage = batchId;

      if (!String.IsNullOrEmpty(_parentId) && !String.IsNullOrEmpty(_parentName))
      {
          if (_unrelatedEntityList == "true")
          {
            var loadUnrelatedEntitiesClient = new EntityInstanceService_LoadUnrelatedEntityInstancesFor_Client();
            loadUnrelatedEntitiesClient.UserName = UI.User.UserName;
            loadUnrelatedEntitiesClient.Password = UI.User.SessionPassword;
            loadUnrelatedEntitiesClient.In_entityName = _objectName;
            loadUnrelatedEntitiesClient.In_forEntityId = new Guid(_parentId);
            loadUnrelatedEntitiesClient.In_forEntityName = _parentName;
            loadUnrelatedEntitiesClient.InOut_mtList = items;
            loadUnrelatedEntitiesClient.Invoke();
            items = loadUnrelatedEntitiesClient.InOut_mtList;
          }

          else if (_createRelationships == "true")
          {
              EntityInstanceService_CreateRelationships_Client createRelationshipsClient=
              new EntityInstanceService_CreateRelationships_Client();

            var srcEntityInstance = new EntityInstance();
            EntityInstanceService_LoadEntityInstance_Client srcEntityInstanceClient = new EntityInstanceService_LoadEntityInstance_Client();
            srcEntityInstanceClient.UserName = UI.User.UserName;
            srcEntityInstanceClient.Password = UI.User.SessionPassword;
            srcEntityInstanceClient.In_entityName = _parentName;
            srcEntityInstanceClient.In_id = new Guid(_parentId);
            srcEntityInstanceClient.Invoke();
            srcEntityInstance = srcEntityInstanceClient.Out_entityInstance;

            List<RelationshipEntityInstanceData> reiDataList = new List<RelationshipEntityInstanceData>();
            
            String[] targetIds;
            targetIds = _targetEntityIds.Split(',');

            int i;
            for (i = 0; i < targetIds.Length; i++)
            {
              RelationshipEntityInstanceData reiDataItem = new RelationshipEntityInstanceData();
              EntityInstance targetEntityInstance = new EntityInstance();
              EntityInstanceService_LoadEntityInstance_Client targetEntityInstanceClient =
                new EntityInstanceService_LoadEntityInstance_Client();
              targetEntityInstanceClient.UserName = UI.User.UserName;
              targetEntityInstanceClient.Password = UI.User.SessionPassword;
              targetEntityInstanceClient.In_entityName = _objectName;
              targetEntityInstanceClient.In_id = new Guid(targetIds[i]);
              targetEntityInstanceClient.Invoke();
              targetEntityInstance = targetEntityInstanceClient.Out_entityInstance;
           
              reiDataItem.Source = srcEntityInstance;
              reiDataItem.Target = targetEntityInstance;
              reiDataList.Add(reiDataItem);
            }

            createRelationshipsClient.UserName = UI.User.UserName;
            createRelationshipsClient.Password = UI.User.SessionPassword;
            createRelationshipsClient.In_relationshipEntityInstanceDataList = reiDataList;
            createRelationshipsClient.Invoke();
          }
          else
          {
            // Associate with AccountDef:  When we already have a parent we no longer need to provide the association for child entities

            EntityInstanceService_LoadEntityInstancesFor_Client client =
              new EntityInstanceService_LoadEntityInstancesFor_Client();
            client.UserName = UI.User.UserName;
            client.Password = UI.User.SessionPassword;

            client.In_entityName = _objectName;
            client.In_forEntityId = new Guid(_parentId);
            client.In_forEntityName = _parentName;
            client.InOut_mtList = items;
            client.Invoke();
            items = client.InOut_mtList;
          }
       
      }
      else
      {
        if (!String.IsNullOrEmpty(_subscriptionDefProp))
        {
          // Associate with Subscription
          EntityInstanceService_LoadEntityInstancesForMetranetEntity_Client client = new EntityInstanceService_LoadEntityInstancesForMetranetEntity_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;

          client.In_entityName = _objectName;

          SubscriptionDef metranetEntity = new SubscriptionDef();
          metranetEntity.SubscriptionId = int.Parse(_subscriptionDefProp);
          client.In_metranetEntity = metranetEntity;

          client.InOut_mtList = items;
          client.Invoke();
          items = client.InOut_mtList;
        }
        else if (String.IsNullOrEmpty(_accountDefProp))
        {
          // Load entity instances
          EntityInstanceService_LoadEntityInstances_Client client = new EntityInstanceService_LoadEntityInstances_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;
          client.In_entityName = _objectName;
          client.InOut_entityInstances = items;
          client.Invoke();
          items = client.InOut_entityInstances;
        }
        else
        {
          // Associate with AccountDef
          EntityInstanceService_LoadEntityInstancesForMetranetEntity_Client client = new EntityInstanceService_LoadEntityInstancesForMetranetEntity_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;

          client.In_entityName = _objectName;

          AccountDef metranetEntity = new AccountDef();
          metranetEntity.AccountId = int.Parse(_accountDefProp);
          client.In_metranetEntity = metranetEntity;

          client.InOut_mtList = items;
          client.Invoke();
          items = client.InOut_mtList;
        }
      }
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Detail.ErrorMessages[0]);
      Response.End();
      return false;
    }
    catch (CommunicationException ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return false;
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return false;
    }

    return true;
  }

  protected bool ExtractData(ref MTList<EntityInstance> items)
  {
    if (Page.Request["mode"] == "csv")
    {
      Response.BufferOutput = false;
      Response.ContentType = "application/csv";
      Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
      Response.BinaryWrite(BOM);
    }

    //if there are more records to process than we can process at once, we need to break up into multiple batches
    if ((items.PageSize > MaxRecordsPerBatch) && (Page.Request["mode"] == "csv"))
    {
      int advancePage = (items.PageSize % MaxRecordsPerBatch != 0) ? 1 : 0;

      int numBatches = advancePage + (items.PageSize / MaxRecordsPerBatch);
      for (int batchId = 0; batchId < numBatches; batchId++)
      {
        ExtractDataInternal(ref items, batchId + 1, MaxRecordsPerBatch);

        string strCsv = ConvertObjectToCSV(items, (batchId == 0));
        Response.Write(strCsv);
      }
    }
    else
    {
      ExtractDataInternal(ref items, items.CurrentPage, items.PageSize);
      if (Page.Request["mode"] == "csv")
      {
        string strCsv = ConvertObjectToCSV(items, true);
        Response.Write(strCsv);
      }
    }

    return true;
  }
 
  protected void Page_Load(object sender, EventArgs e)
  {
    using (new MetraTech.Debug.Diagnostics.HighResolutionTimer("GetNumberofAssociatedAccountsSvcAjax", 5000))
    {
      _objectName = String.IsNullOrEmpty(Request["Name"]) ? "" : Request["Name"];
      _accountDefProp = String.IsNullOrEmpty(Request["AccountDef"]) ? "" : Decrypt(Request["AccountDef"]);
      _subscriptionDefProp = String.IsNullOrEmpty(Request["SubscriptionDef"]) ? "" : Decrypt(Request["SubscriptionDef"]);
      _parentId = String.IsNullOrEmpty(Request["ParentId"]) ? "" : Request["ParentId"];
      _parentName = String.IsNullOrEmpty(Request["ParentName"]) ? "" : Request["ParentName"];
      _unrelatedEntityList = String.IsNullOrEmpty(Request["UnrelatedEntityList"]) ? "" : Request["UnrelatedEntityList"];
      _createRelationships = String.IsNullOrEmpty(Request["CreateRelationship"]) ? "" : Request["CreateRelationship"];
      _targetEntityIds = String.IsNullOrEmpty(Request["TargetEntityIds"]) ? "" : Request["TargetEntityIds"];

      MTList<EntityInstance> items = new MTList<EntityInstance>(); 

      SetPaging(items);
      SetSorting(items);
      SetFilters(items);

      if (!ExtractData(ref items))
      {
        return;
      }

       Response.Write(items.Items.Count); 

      Response.End();
    }
  }
}

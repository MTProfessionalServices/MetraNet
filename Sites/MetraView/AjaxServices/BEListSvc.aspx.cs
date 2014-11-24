//
// http://localhost/MetraNet/AjaxServices/BEListSvc.aspx?&Name=Core.OrderManagement.Order&Assembly=Core.OrderManagement.Entity&AccountDef=123
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class AjaxServices_BEListSvc : MTListServicePage
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
  private string _selectedIds;
  private bool _saveSelected;


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
          LoadUnrelatedEntityInstancesForParent(ref items);
        }

        else if (_createRelationships == "true")
        {
          CreateRelationships();
        }
        else
        {
          // Associate with AccountDef:  When we already have a parent we no longer need to provide the association for child entities
          LoadEntityInstancesForParent(ref items);
        }
      }
      else
      {
        if (!String.IsNullOrEmpty(_subscriptionDefProp))
        {
          // Associate with Subscription
          LoadEntityInstancesForSubscriptionDef(ref items);
        }
        else if (String.IsNullOrEmpty(_accountDefProp))
        {
          // Load entity instances
          LoadEntityInstances(ref items);
        }
        else
        {
          // Associate with AccountDef
          LoadEntityInstancesForAccountDef(ref items);
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
      Response.Write("sep=," + Environment.NewLine);
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
        if (_saveSelected)
          items = GetSelectedItemsForExport();
        var strCsv = ConvertObjectToCSV(items, true);
        Response.Write(strCsv);
      }
    }

    return true;
  }
  /// <summary>
  /// Gets selected items for export
  /// </summary>
  /// <returns></returns>
  private MTList<EntityInstance> GetSelectedItemsForExport()
  {
    var items = new MTList<EntityInstance>();
    if (!String.IsNullOrEmpty(_selectedIds))
    {
      var ids = new List<Guid>(0);
      ids.AddRange(_selectedIds.Split(',').Select(idString => new Guid(idString)));
      LoadEntityInstancesByGuids(ref items, ids.ToArray());
    }
    return items;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    using (new MetraTech.Debug.Diagnostics.HighResolutionTimer("BEListSvcAjax", 5000))
    {
      _objectName = String.IsNullOrEmpty(Request["Name"]) ? "" : Request["Name"];
      _accountDefProp = String.IsNullOrEmpty(Request["AccountDef"]) ? "" : Decrypt(Request["AccountDef"]);
      _subscriptionDefProp = String.IsNullOrEmpty(Request["SubscriptionDef"]) ? "" : Decrypt(Request["SubscriptionDef"]);
      _parentId = String.IsNullOrEmpty(Request["ParentId"]) ? "" : Request["ParentId"];
      _parentName = String.IsNullOrEmpty(Request["ParentName"]) ? "" : Request["ParentName"];
      _unrelatedEntityList = String.IsNullOrEmpty(Request["UnrelatedEntityList"]) ? "" : Request["UnrelatedEntityList"];
      _createRelationships = String.IsNullOrEmpty(Request["CreateRelationship"]) ? "" : Request["CreateRelationship"];
      _targetEntityIds = String.IsNullOrEmpty(Request["TargetEntityIds"]) ? "" : Request["TargetEntityIds"];
      _selectedIds = String.IsNullOrEmpty(Request.Form["SelectedIds"]) ? String.Empty : Request.Form["SelectedIds"];
      _saveSelected = Request.Form["CurPageOrAll"] == "Selected";
      var _isBulkUpdate = String.IsNullOrEmpty(Request["IsBulkUpdate"]) ? "" : Request["IsBulkUpdate"];
      var _bulkUpdateType = String.IsNullOrEmpty(Request["BulkUpdateType"]) ? "" : Request["BulkUpdateType"];
      var _quantityPerPage = String.IsNullOrEmpty(Request["QuantityPerPage"]) ? "" : Request["QuantityPerPage"];

      var items = new MTList<EntityInstance>();

      SetPaging(items);
      SetSorting(items);
      SetFilters(items);

      if (_isBulkUpdate == "true")
      {
        PutBulkUpdateParametersIntoSession(_selectedIds, _bulkUpdateType, items, _quantityPerPage);
      }
      else
      {
        DeleteBulkUpdateParametersFromSession();


        if (!ExtractData(ref items))
        {
          return;
        }

        if (items.Items.Count == 0)
        {
          Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
          Response.End();
          return;
        }

        #region Export to CSV file

        if (Page.Request["mode"] != "csv")
        {
          //convert BE into JSON
          var jss = new JavaScriptSerializer();
          var json = new StringBuilder();

          json.Append("{\"TotalRows\":");
          json.Append(items.TotalRows.ToString());
          json.Append(", \"Items\":[");

          int j = 0;
          foreach (var entityInstance in items.Items)
          {
            if (!(j == 0 || j == items.Items.Count))
            {
              json.Append(",");
            }

            json.Append("{");

            // add internalId to each row
            json.Append("\"internalId\":");
            json.Append("\"");
            json.Append(entityInstance.Id);
            json.Append("\",");

            int i = 0;
            foreach (PropertyInstance propertyInstance in entityInstance.Properties)
            {
              if (!(i == 0 || i == entityInstance.Properties.Count))
              {
                json.Append(",");
              }

              json.Append("\"");
              json.Append(propertyInstance.Name);
              json.Append("\":");

              object dispalyValue = null;

              if (propertyInstance.Value == null || string.IsNullOrEmpty(propertyInstance.Value.ToString()))
              {
                json.Append("null");
              }
              else
              {
                dispalyValue = (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum
                                  ? EnumHelper.GetEnumEntryName(propertyInstance.Value).ToString()
                                  : propertyInstance.Value.ToString()).EncodeForJavaScript();

                if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.String ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.DateTime ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Decimal ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Guid)
                {
                  json.Append("\"");
                }

                if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Boolean)
                {
                  // boolean is lowercase in javascript
                  json.Append(propertyInstance.Value.ToString().ToLower());
                }
                else
                {
                  json.Append(dispalyValue);
                }

                if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.String ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.DateTime ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Decimal ||
                    propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Guid)
                {
                  json.Append("\"");
                }
              }

              // Display Name
              json.Append(",");
              json.Append("\"");
              json.Append(propertyInstance.Name.EncodeForJavaScript());
              json.Append("DisplayName");
              json.Append("\":");
              json.Append("\"");
              json.Append(propertyInstance.Name.EncodeForJavaScript()); // TODO:  KAB: Localized label
              json.Append("\"");

              // Value Display Name for enums
              if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum)
              {
                json.Append(",");
                json.Append("\"");
                json.Append(propertyInstance.Name.EncodeForJavaScript());
                json.Append("ValueDisplayName");
                json.Append("\":");
                json.Append("\"");

                if (dispalyValue != null)
                {
                  json.Append(dispalyValue); // TODO:  KAB: Localized label
                }

                json.Append("\"");
              }

              i++;
            }

            json.Append("}");
            j++;
          }

          json.Append("]");
          json.Append(", \"CurrentPage\":");
          json.Append(items.CurrentPage.ToString());
          json.Append(", \"PageSize\":");
          json.Append(items.PageSize.ToString());
          //json.Append(", \"Filters\":");
          //json.Append(jss.Serialize(items.Filters));
          json.Append(", \"SortProperty\":");
          if (items.SortCriteria == null || items.SortCriteria.Count == 0)
          {
            json.Append("null");
            json.Append(", \"SortDirection\":\"");
            json.Append(SortType.Ascending.ToString());
          }
          else
          {
            json.Append("\"");
            json.Append(items.SortCriteria[0].SortProperty);
            json.Append("\"");
            json.Append(", \"SortDirection\":\"");
            json.Append(items.SortCriteria[0].SortDirection.ToString());

          }
          json.Append("\"}");

          Response.Write(json.ToString());
        }

        #endregion
      }

      Response.End();
    }
  }

  public void PutBulkUpdateParametersIntoSession(string selectedIds, string _bulkUpdateType, MTList<EntityInstance> items, string _quantityPerPage)
  {
    Session["BulkUpdateType"] = _bulkUpdateType;

    if (_bulkUpdateType == "CurPage" || _bulkUpdateType == "All")
    {
      Session["BEItemsForBulkUpdate"] = items;
      Session["NumberUpdatingRecords"] = _bulkUpdateType == "All" ? items.PageSize.ToString() : _quantityPerPage;
    }
    else
    {
      Session["IdsForBulkUpdate"] = selectedIds;
      Session["NumberUpdatingRecords"] = selectedIds.Split(',').Length;
    }
  }

  public void DeleteBulkUpdateParametersFromSession()
  {
    Session.Remove("IdsForBulkUpdate");
    Session.Remove("BulkUpdateType");
    Session.Remove("BEItemsForBulkUpdate");
    Session.Remove("NumberUpdatingRecords");
  }

  #region Private Methods

  private void LoadUnrelatedEntityInstancesForParent(ref MTList<EntityInstance> items)
  {
    var client = new EntityInstanceService_LoadUnrelatedEntityInstancesFor_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = _objectName,
                     In_forEntityId = new Guid(_parentId),
                     In_forEntityName = _parentName,
                     InOut_mtList = items
                   };
    client.Invoke();
    items = client.InOut_mtList;
  }

  private void LoadEntityInstancesForParent(ref MTList<EntityInstance> items)
  {
    var client = new EntityInstanceService_LoadEntityInstancesFor_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = _objectName,
                     In_forEntityId = new Guid(_parentId),
                     In_forEntityName = _parentName,
                     InOut_mtList = items
                   };

    client.Invoke();
    items = client.InOut_mtList;
  }

  private void LoadEntityInstancesByGuids(ref MTList<EntityInstance> items, Guid[] ids)
  {
    var client = new EntityInstanceService_LoadEntityInstancesByGuids_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = _objectName,
                     In_ids = ids,
                     InOut_entityInstances = items
                   };
    client.Invoke();
    items = client.InOut_entityInstances;
  }

  private void LoadEntityInstancesForAccountDef(ref MTList<EntityInstance> items)
  {
    var metranetEntity = new AccountDef();
    metranetEntity.AccountId = int.Parse(_accountDefProp);

    var client = new EntityInstanceService_LoadEntityInstancesForMetranetEntity_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = _objectName,
                     In_metranetEntity = metranetEntity,
                     InOut_mtList = items
                   };
    client.Invoke();
    items = client.InOut_mtList;
  }

  private void LoadEntityInstancesForSubscriptionDef(ref MTList<EntityInstance> items)
  {
    var metranetEntity = new SubscriptionDef();
    metranetEntity.SubscriptionId = int.Parse(_subscriptionDefProp);

    var client = new EntityInstanceService_LoadEntityInstancesForMetranetEntity_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = _objectName,
                     In_metranetEntity = metranetEntity,
                     InOut_mtList = items
                   };
    client.Invoke();
    items = client.InOut_mtList;
  }

  private void LoadEntityInstances(ref MTList<EntityInstance> items)
  {
    var client = new EntityInstanceService_LoadEntityInstances_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = _objectName,
                     InOut_entityInstances = items
                   };
    client.Invoke();
    items = client.InOut_entityInstances;
  }

  private void CreateRelationships()
  {
    var createRelationshipsClient = new EntityInstanceService_CreateRelationships_Client();

    var srcEntityInstance = new EntityInstance();
    var srcEntityInstanceClient = new EntityInstanceService_LoadEntityInstance_Client
                                    {
                                      UserName = UI.User.UserName,
                                      Password = UI.User.SessionPassword,
                                      In_entityName = _parentName,
                                      In_id = new Guid(_parentId)
                                    };
    srcEntityInstanceClient.Invoke();
    srcEntityInstance = srcEntityInstanceClient.Out_entityInstance;

    var reiDataList = new List<RelationshipEntityInstanceData>();

    String[] targetIds;
    targetIds = _targetEntityIds.Split(',');

    int i;
    for (i = 0; i < targetIds.Length; i++)
    {
      var reiDataItem = new RelationshipEntityInstanceData();
      var targetEntityInstance = new EntityInstance();
      var targetEntityInstanceClient = new EntityInstanceService_LoadEntityInstance_Client
                                         {
                                           UserName = UI.User.UserName,
                                           Password = UI.User.SessionPassword,
                                           In_entityName = _objectName,
                                           In_id = new Guid(targetIds[i])
                                         };
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

  #endregion
}

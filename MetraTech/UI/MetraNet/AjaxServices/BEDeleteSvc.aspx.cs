using System;
using System.Collections.Generic;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.Events;
using MetraTech.UI.Common;
using MetraTech.BusinessEntity.Service.ClientProxies;

public partial class AjaxServices_BEDeleteSvc : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string name = Request["name"];
    string id = Request["id"];
    string childGrid = String.IsNullOrEmpty(Request["ChildGrid"]) ? "" : Request["ChildGrid"];
    string _parentId = String.IsNullOrEmpty(Request["ParentId"]) ? "" : Request["ParentId"];
    string _parentName = String.IsNullOrEmpty(Request["ParentName"]) ? "" : Request["ParentName"];
    string _unRelated = String.IsNullOrEmpty(Request["UnRelated"]) ? "" : Request["UnRelated"];

    String[] idArray = id.Split(',');
    List<RelationshipEntityInstanceData> reiDataList = new List<RelationshipEntityInstanceData>();
    
      if (childGrid == "true")
      {
        var client = new EntityInstanceService_DeleteRelationships_Client();

        var srcEntityInstance = new EntityInstance();
        EntityInstanceService_LoadEntityInstance_Client srcEntityInstanceClient = new EntityInstanceService_LoadEntityInstance_Client();
        srcEntityInstanceClient.UserName = UI.User.UserName;
        srcEntityInstanceClient.Password = UI.User.SessionPassword;
        srcEntityInstanceClient.In_entityName = _parentName;
        srcEntityInstanceClient.In_id = new Guid(_parentId);
        srcEntityInstanceClient.Invoke();
        srcEntityInstance = srcEntityInstanceClient.Out_entityInstance;

        foreach (string idString in idArray)
        {
          RelationshipEntityInstanceData reiDataItem = new RelationshipEntityInstanceData();
          EntityInstance targetEntityInstance = new EntityInstance();
          EntityInstanceService_LoadEntityInstance_Client targetEntityInstanceClient =
            new EntityInstanceService_LoadEntityInstance_Client();
          targetEntityInstanceClient.UserName = UI.User.UserName;
          targetEntityInstanceClient.Password = UI.User.SessionPassword;
          targetEntityInstanceClient.In_entityName = name;
          targetEntityInstanceClient.In_id = new Guid(idString);
          targetEntityInstanceClient.Invoke();
          targetEntityInstance = targetEntityInstanceClient.Out_entityInstance;

          reiDataItem.Source = srcEntityInstance;
          reiDataItem.Target = targetEntityInstance;
          reiDataList.Add(reiDataItem);
        }

        client.UserName = UI.User.UserName;
        client.Password = UI.User.SessionPassword;
        client.In_relationshipEntityInstanceDataList = reiDataList;
        client.Invoke();

      }
      else
      {
        foreach (string idString in idArray)
        {
          // Load existing entity instance for id
          var client = new EntityInstanceService_DeleteEntityInstanceUsingEntityName_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;
          client.In_entityName = name;
          client.In_id = new Guid(idString);
          client.Invoke();
        }
      }
  

    if (UI.Subscriber.SelectedAccount != null)
    {
      InfoMessage updateMessage = new InfoMessage("UPDATE", name);
      EventManager em = new EventManager();
      em.Send(UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount.Name_Space, updateMessage);
    }

    Response.Write("OK");
    Response.End();
  }
}

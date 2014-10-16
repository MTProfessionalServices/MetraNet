using System;
using System.Collections.Generic;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Common;

public partial class BE : MTPage
{
  public List<Entity> EntitiesList
  {
    get { return ViewState["EntitiesList"] as List<Entity>; }
    set { ViewState["EntitiesList"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      EntitiesList = GetEntities();

      List<Entity> removeEntitites = new List<Entity>();
      foreach (Entity entity in EntitiesList)
      {
        // check for Read Only capability
        if (!MenuManager.CheckBECapability(entity.ExtensionName, AccessType.Read, UI.SessionContext.SecurityContext))
        {
         removeEntitites.Add(entity);
        }
      }

      foreach(Entity entity in removeEntitites)
      {
        EntitiesList.Remove(entity);  
      }

      DataList1.DataSource = EntitiesList;
      DataList1.DataBind();

      lblNoBEs.Visible = (EntitiesList.Count == 0);
    }
  }

  #region Private Methods

  private List<Entity> GetEntities()
  {
    var getEntitiesClient = new MetadataService_GetEntities_Client();
    getEntitiesClient.UserName = UI.User.UserName;
    getEntitiesClient.Password = UI.User.SessionPassword;
    getEntitiesClient.Invoke();
    return getEntitiesClient.Out_entities;
  }

  #endregion
}

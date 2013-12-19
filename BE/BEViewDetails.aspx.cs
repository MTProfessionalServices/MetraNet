using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core;
using MetraTech.Events;
using MetraTech.UI.CDT;
using MetraTech.UI.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Controls;
using System.Linq;
 
public partial class BEViewDetails : MTPage
{
  #region Properties
  public EntityInstance BE
  {
    get { return ViewState["BE"] as EntityInstance; }
    set { ViewState["BE"] = value; }
  }

  public string RouteTo
  {
    get { return ViewState["RouteTo"] as string; }
    set { ViewState["RouteTo"] = value; }
  }

  public string AccountDefProp
  {
    get { return ViewState["AccountDef"] as string; }
    set { ViewState["AccountDef"] = value; }
  }

  public string SubscriptionDefProp
  {
    get { return ViewState["SubscriptionDef"] as string; }
    set { ViewState["SubscriptionDef"] = value; }
  }

  public string Id
  {
    get { return ViewState["Id"] as string; }
    set { ViewState["Id"] = value; }
  }

  public string ParentId
  {
    get { return ViewState["ParentId"] as string; }
    set { ViewState["ParentId"] = value; }
  }

  public string ParentName
  {
    get { return ViewState["ParentName"] as string; }
    set { ViewState["ParentName"] = value; }
  }
  #endregion

  #region  Events
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      RouteTo = !String.IsNullOrEmpty(Request.QueryString["url"]) ? Decrypt(Request.QueryString["url"]) : Request.UrlReferrer.ToString();

      if (!String.IsNullOrEmpty(Request["Association"]))
      {
        if (Request["Association"].ToLower().Contains("account"))
        {
          AccountDefProp = UI.Subscriber.SelectedAccount._AccountID.ToString();
        }

        if (Request["Association"].ToLower().Contains("subscription"))
        {
          SubscriptionDefProp = Session["BESubscriptionId"].ToString();
        }
      }

      ParentName = String.IsNullOrEmpty(Request["ParentName"]) ? null : Request["ParentName"];
      ParentId = String.IsNullOrEmpty(Request["ParentId"]) ? null : Request["ParentId"];
 
      string templateName = Request.QueryString["name"];

      Id = Request.QueryString["id"];

      PageLayout layout = MTGenericForm1.GetPageLayoutByName(templateName);

      string title = layout.Header.PageTitle.GetValue();
      if (String.IsNullOrEmpty(title))
      {
        title = templateName.Substring(templateName.LastIndexOf(".") + 1);
      }

      // if we have a parent we will use that id to get the single entity
      if (!String.IsNullOrEmpty(ParentId) && !String.IsNullOrEmpty(ParentName))
      {
        bool isNewOneToMany = false;

        if (!String.IsNullOrEmpty(Request["NewOneToMany"]))
        {
          if (Request["NewOneToMany"].ToLower() == "true")
          {
            isNewOneToMany = true;
          }
        }

        if (!isNewOneToMany)
        {
          var client = new EntityInstanceService_LoadEntityInstanceFor_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;

          client.In_entityName = layout.ObjectName;
          client.In_forEntityId = new Guid(ParentId);
          client.In_forEntityName = ParentName;
          client.Invoke();
          BE = client.Out_entityInstance;
        }

        // if entity is null, we new it up, and set any associations we may have
        if(BE == null)
        {
          var createNewEntityInstanceClient = new EntityInstanceService_GetNewEntityInstance_Client();
          createNewEntityInstanceClient.UserName = UI.User.UserName;
          createNewEntityInstanceClient.Password = UI.User.SessionPassword;
          createNewEntityInstanceClient.In_entityName = layout.ObjectName;
          createNewEntityInstanceClient.Invoke();
          BE = createNewEntityInstanceClient.Out_entityInstance;
          
          if (!String.IsNullOrEmpty(AccountDefProp))
          {
            BE.SetValue(int.Parse(AccountDefProp), "AccountId");
          }

          if (!String.IsNullOrEmpty(SubscriptionDefProp))
          {
            BE.SetValue(int.Parse(SubscriptionDefProp), "SubscriptionId");
          }
        }
        else
        {
          Id = BE.Id.ToString();
        }
      }
      else
      {
        if (String.IsNullOrEmpty(Id))
        {
          // Create Business Entity Instance 
          var createNewEntityInstanceClient = new EntityInstanceService_GetNewEntityInstance_Client();
          createNewEntityInstanceClient.UserName = UI.User.UserName;
          createNewEntityInstanceClient.Password = UI.User.SessionPassword;
          createNewEntityInstanceClient.In_entityName = layout.ObjectName;
          createNewEntityInstanceClient.Invoke();
          BE = createNewEntityInstanceClient.Out_entityInstance;

          if (!String.IsNullOrEmpty(AccountDefProp))
          {
            BE.SetValue(int.Parse(AccountDefProp), "AccountId");
          }

          if (!String.IsNullOrEmpty(SubscriptionDefProp))
          {
            BE.SetValue(int.Parse(SubscriptionDefProp), "SubscriptionId");
          }
        }
        else
        {
          // Load existing entity instance for id
          EntityInstanceService_LoadEntityInstance_Client client = new EntityInstanceService_LoadEntityInstance_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;
          client.In_entityName = layout.ObjectName;
          client.In_id = new Guid(Id);
          client.Invoke();
          BE = client.Out_entityInstance;
        }
      }

      if (BE == null)
      {
        Logger.LogError("Unable to find business entity for [{0}].", templateName);
        return;
      }

      MTGenericForm1.RenderObjectInstanceName = "BE";
      MTGenericForm1.TemplateName = templateName;
      MTGenericForm1.ReadOnly = true;
      
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
      Response.Redirect(RouteTo);
  }
  
  #endregion

}


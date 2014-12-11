//
// This file is based on BEEdit.aspx.cs
//

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
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using Core.FileLandingService;
using Resources;

public partial class FileManagementTarget : MTPage
{
  #region Properties
  public string editArgumentsLink = "";
  public string argumentWarning = "";

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

  public string BEName
  {
    get { return ViewState["BEName"] as string; }
    set { ViewState["BEName"] = value; }
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
    if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
    {
      Response.End();
      return;
    }
    if (!IsPostBack)
    {
      bool isNew = false;

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
          MTTitle1.Text = Resource.TEXT_EDIT + title;
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
        if (BE == null)
        {
          MTTitle1.Text = Resource.TEXT_NEW + title;
          isNew = true;

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
          MTTitle1.Text = Resource.TEXT_NEW + title;
          isNew = true;

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
          MTTitle1.Text = Resource.TEXT_EDIT + title;

          // Load existing entity instance for id
          EntityInstanceService_LoadEntityInstance_Client client = new EntityInstanceService_LoadEntityInstance_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;
          client.In_entityName = layout.ObjectName;
          client.In_id = new Guid(Id);
          client.Invoke();
          BE = client.Out_entityInstance;

          // Get related entities
          ShowRelatedEntityLinks();
        }
      }

      if (BE == null)
      {
        Logger.LogError("Unable to find business entity for [{0}].", templateName);
        return;
      }

      MTGenericForm1.RenderObjectInstanceName = "BE";
      MTGenericForm1.TemplateName = templateName;

      // check for Read Only capability
      if (!MenuManager.CheckBECapability(BE.ExtensionName, AccessType.Write, UI.SessionContext.SecurityContext))
      {
        MTGenericForm1.ReadOnly = true;
        btnOK.Visible = false;
      }

      if (!isNew)
      {
        argumentWarning = checkTargetArguments();
      }
    }
  }


  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();

      // Save entity

      // Check for presence of "BusinessKey" and set it to a GUID 
      // Empty business key properties will automatically be provided with a new GUID by the backend
      if (BE["BusinessKey"] != null)
      {
        if (BE["BusinessKey"].Value == null)
        {
          BE["BusinessKey"].Value = Guid.NewGuid();
        }
      }

      try
      {

        if (!String.IsNullOrEmpty(ParentId) && !String.IsNullOrEmpty(ParentName) && String.IsNullOrEmpty(Id))
        {
          EntityInstanceService_CreateEntityInstanceFor_Client client = new EntityInstanceService_CreateEntityInstanceFor_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;
          client.In_forEntityId = new Guid(ParentId);
          client.In_forEntityName = ParentName;
          client.InOut_entityInstance = BE;
          client.Invoke();
          BE = client.InOut_entityInstance;
        }
        else
        {
          EntityInstanceService_SaveEntityInstance_Client client = new EntityInstanceService_SaveEntityInstance_Client();
          client.UserName = UI.User.UserName;
          client.Password = UI.User.SessionPassword;
          client.InOut_entityInstance = BE;
          client.Invoke();
          BE = client.InOut_entityInstance;
        }

        if (UI.Subscriber.SelectedAccount != null)
        {
          InfoMessage updateMessage = new InfoMessage("UPDATE", BE.EntityFullName);
          EventManager em = new EventManager();
          em.Send(UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount.Name_Space, updateMessage);
        }

      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        SetMASError(fe);
        return;
      }
      catch (Exception exp)
      {
        SetError(exp.Message);
        return;
      }

      Response.Redirect(RouteTo);
    }
  }


  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(RouteTo);
  }
  #endregion

  #region Related Entities
  /// <summary>
  /// Renders links for related entities
  /// </summary>
  private void ShowRelatedEntityLinks()
  {


    if (BE != null)
    {
      var getTargetEntitiesClient = new MetadataService_GetTargetEntities_Client();
      getTargetEntitiesClient.UserName = UI.User.UserName;
      getTargetEntitiesClient.Password = UI.User.SessionPassword;
      getTargetEntitiesClient.In_entityName = BE.EntityFullName;
      getTargetEntitiesClient.Invoke();
      List<RelatedEntity> relatedEntities = getTargetEntitiesClient.Out_targetEntities;

      if (relatedEntities.Count > 0)
      {
        foreach (RelatedEntity ent in relatedEntities)
        {
          if (ent.Multiplicity != Multiplicity.One)
          {
            MTBEList link = new MTBEList();
            link.Extension = ent.Entity.ExtensionName;
            link.ObjectName = ent.Entity.FullName;
            link.ParentId = BE.Id.ToString();
            link.ParentName = BE.EntityFullName;
            link.Text = ent.Entity.PluralName;
            string title = Server.HtmlEncode(ent.Entity.GetLocalizedLabel());

            if (String.IsNullOrEmpty(title) || !title.Contains("Argument"))
            {
              continue;
            }

            editArgumentsLink = String.Format("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='/MetraNet/MetraControl/FileManagement/FileManagementArgs.aspx?Name=Core.FileLandingService.ArgumentBE&amp;Extension=Core&amp;ParentId={0}&amp;ParentName=Core.FileLandingService.TargetBE&amp;Association='><img border='0' src='/Res/Images/Icons/grid.png'>&nbsp;Edit Target Arguments</a>",
            BE.Id.ToString()); 
        }
        }
      }
    }
  }

  /// <summary>
  /// Checks for an configuration problem with the target arguments.
  /// Returns an empty string if no problems, otherwise returns
  /// an displayable message.
  /// </summary>
  /// <returns></returns>
  private string checkTargetArguments()
  {
    bool sawFileArg = false;

    RepositoryService_LoadInstancesFor_Client client =
                                  new RepositoryService_LoadInstancesFor_Client();

    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;
    client.In_entityName = typeof(ArgumentBE).FullName;
    client.In_forEntityName = typeof(TargetBE).FullName;
    client.In_forEntityId = BE.Id;

    MTList<DataObject> argList = new MTList<DataObject>();

    client.InOut_mtList = argList;
    client.Invoke();
    argList = client.InOut_mtList;

    foreach (ArgumentBE arg in argList.Items)
    {
      if (arg._Format.ToLower().Contains("$(file)"))
      {
        sawFileArg = true;
      }
    }

    if (!sawFileArg)
    {
      return "&nbsp&nbsp " + FileManagementResources.TARGET_MISSING_DATAFILE_ARG;
    }

    return "";
  }
  #endregion

}



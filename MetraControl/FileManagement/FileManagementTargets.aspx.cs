// Usage:  http://localhost/MetraNet/BEList.aspx?Name=Core.OrderManagement.Order&Extension=Account
//         &Association=Account&ParentId=123&ParentName=Core.OrderManagement.Parent 
// Loads list of orders with the OrderTemplate.xml grid layout in the Account extension
using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.UI.Controls;

public partial class FileManagementTargets : MTPage
{

  #region Properties
  public string RelatedEntityLinksHtml
  {
    get { return ViewState["RelatedEntityLinksHtml"] as string; }
    set { ViewState["RelatedEntityLinksHtml"] = value; }
  }

  public string BEName
  {
    get { return ViewState["BEName"] as string; }
    set { ViewState["BEName"] = value; }
  }

  public string RefererUrl
  {
    get { return ViewState["RefererURL"] as string; }
    set { ViewState["RefererURL"] = value; }
  }

  public string ReturnUrl
  {
    get { return ViewState["ReturnURL"] as string; }
    set { ViewState["ReturnURL"] = value; }
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

  public string AssociationValue
  {
    get { return ViewState["AssociationValue"] as string; }
    set { ViewState["AssociationValue"] = value; }
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

  public string ReadOnly
  {
    get { return ViewState["ReadOnly"] as string; }
    set { ViewState["ReadOnly"] = value; }
  }
  #endregion

  #region Events
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
    {
      Response.End();
      return;
    }
    if (!IsPostBack) 
    {

      RefererUrl = Encrypt(Request.Url.ToString());
     
      if(!String.IsNullOrEmpty(Request["Association"]))
      {
        AssociationValue = Request["Association"];
        if (AssociationValue.ToLower().Contains("account"))
        {
          AccountDefProp = UI.Subscriber.SelectedAccount._AccountID.ToString();
        }

        if (AssociationValue.ToLower().Contains("subscription"))
        {
          Session["BESubscriptionId"] = String.IsNullOrEmpty(Request["id_sub"]) ? Session["BESubscriptionId"].ToString() : Request["id_sub"];
          SubscriptionDefProp = Session["BESubscriptionId"].ToString();
        }
      }
      
      ParentName = String.IsNullOrEmpty(Request["ParentName"]) ? null : Request["ParentName"];
      ParentId = String.IsNullOrEmpty(Request["ParentId"]) ? null : Request["ParentId"];

      if (String.IsNullOrEmpty(Request["ReturnURL"]))
      {
        if (Request.UrlReferrer.ToString().ToLower().Contains("login.aspx") ||
            Request.UrlReferrer.ToString().ToLower().Contains("default.aspx"))
        {
          ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
        }
        else
        {
          ReturnUrl = Request.UrlReferrer.ToString();
        }
      }
      else
      {
        ReturnUrl = Request["ReturnURL"].Replace("'", "").Replace("|", "?").Replace("**", "&");
      }

      BEName = Server.HtmlEncode(Request.QueryString["Name"]);

      MTTitle1.Text = BEName.Substring(BEName.LastIndexOf(".") + 1);

      MyGrid1.ExtensionName = Request.QueryString["Extension"];
      MyGrid1.TemplateFileName = BEName + ".xml";

      SetupRelatedEntityLinksHtml();
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    if (String.IsNullOrEmpty(MyGrid1.Title))
    {
      var getEntityClient = new MetadataService_GetEntity_Client();
      getEntityClient.UserName = UI.User.UserName;
      getEntityClient.Password = UI.User.SessionPassword;
      getEntityClient.In_entityName = BEName;
      getEntityClient.Invoke();
      Entity entity = getEntityClient.Out_entity;
      MyGrid1.Title = Server.HtmlEncode(entity.GetLocalizedLabel());
    }

    MTTitle1.Text = MyGrid1.Title;

    // Set additional argument for grid     
    if (!String.IsNullOrEmpty(AccountDefProp))
    {
      MyGrid1.DataSourceURL += "&AccountDef=" + Encrypt(AccountDefProp);
    }

    if (!String.IsNullOrEmpty(SubscriptionDefProp))
    {
      MyGrid1.DataSourceURL += "&SubscriptionDef=" + Encrypt(SubscriptionDefProp);
    }

    if (!String.IsNullOrEmpty(ParentName))
    {
      MyGrid1.DataSourceURL += "&ParentName=" + ParentName;
    }

    if (!String.IsNullOrEmpty(ParentId))
    {
      MyGrid1.DataSourceURL += "&ParentId=" + ParentId;
    }

    if (!MenuManager.CheckBECapability(MyGrid1.ExtensionName, AccessType.Write, UI.SessionContext.SecurityContext))
    {
      ReadOnly = "true";
      if (MyGrid1.ToolbarButtons.Count > 0)
      {
        // remove the first toolbar button which is add by default on generic page
        MyGrid1.ToolbarButtons.RemoveAt(0); 
      }
    }
    else
    {
      ReadOnly = "false";
    }

    base.OnLoadComplete(e);
  }
  #endregion

  #region RelatedEntities
  private void SetupRelatedEntityLinksHtml()
  {
    if (BEName != null)
    {
      StringWriter stringWriter = new StringWriter();
      using (HtmlTextWriter writer = new HtmlTextWriter(stringWriter))
      {
        var getTargetEntitiesClient = new MetadataService_GetTargetEntities_Client();
        getTargetEntitiesClient.UserName = UI.User.UserName;
        getTargetEntitiesClient.Password = UI.User.SessionPassword;
        getTargetEntitiesClient.In_entityName = BEName;
        getTargetEntitiesClient.Invoke();
        List<RelatedEntity> relatedEntities = getTargetEntitiesClient.Out_targetEntities;

        if (relatedEntities.Count > 0)
        {
          Literal header = new Literal();
          header.Text = "<div class=\"expanderSectionTitle\">" + Resources.Resource.TEXT_MORE_ITEMS + "</div>";
          header.RenderControl(writer);

          int i = 0;
          foreach (RelatedEntity ent in relatedEntities)
          {
            if (ent.Multiplicity == Multiplicity.One)
            {
              MTBEEdit link = new MTBEEdit();
              link.Extension = ent.Entity.ExtensionName;
              link.ObjectName = ent.Entity.FullName;
              link.ParentId = "{internalId}";
              link.ParentName = BEName;
              link.Text = ent.Entity.GetLocalizedLabel();
              link.RenderControl(writer);
            }
            else
            {
              MTBEList link = new MTBEList();
              link.Extension = ent.Entity.ExtensionName;
              link.ObjectName = ent.Entity.FullName;
              link.ParentId = "{internalId}";
              link.ParentName = BEName;
              link.Text = ent.Entity.PluralName;
              link.RenderControl(writer);
            }

            i++;
            if (i < relatedEntities.Count)
            {
              Literal spacer = new Literal();
              spacer.Text = Resources.Resource.TEXT_SPACER;
              spacer.RenderControl(writer);
            }
          }
        }

        RelatedEntityLinksHtml = stringWriter.ToString().Replace("\"", "\\\"");
      }
    }
  }
  #endregion

}


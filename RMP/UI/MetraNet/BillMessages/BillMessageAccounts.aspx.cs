// Usage:  http://localhost/MetraNet/BEList.aspx?Name=Core.OrderManagement.Order&Extension=Account
//         &Association=Account&ParentId=123&ParentName=Core.OrderManagement.Parent 
// Loads list of orders with the OrderTemplate.xml grid layout in the Account extension
using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;

public partial class BillMessageAccounts : MTPage
{

  #region Properties
 
  public string BEName
  {
    get { return ViewState["BEName"] as string; }
    set { ViewState["BEName"] = value; }
  }

  public string MultiSelect
  {
    get { return ViewState["MultiSelect"] as string; }
    set { ViewState["MultiSelect"] = value; }
  }

  public string ChildGrid
  {
    get { return ViewState["ChildGrid"] as string; }
    set { ViewState["ChildGrid"] = value; }
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

  public string Unrelated
  {
    get { return ViewState["Unrelated"] as string; }
    set { ViewState["Unrelated"] = value; }
  }

  public string RelshipType
  {
    get { return ViewState["RelshipType"] as string; }
    set { ViewState["RelshipType"] = value; }
  }

  public string CurrentSourceEntityName
  {
    get { return ViewState["CurrentSourceEntityName"] as string; }
    set { ViewState["CurrentSourceEntityName"] = value; }
  }
  
  #endregion

  #region Events
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {

      RefererUrl = Encrypt(Request.Url.ToString());

      if (!String.IsNullOrEmpty(Request["Association"]))
      {
        AssociationValue = Request["Association"];
				AssociationValue = CheckParameter(AssociationValue);

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
	  ParentName = CheckParameter(ParentName);

      ParentId = String.IsNullOrEmpty(Request["ParentId"]) ? null : Request["ParentId"];
	  ParentId = CheckParameter(ParentId);
     

      if (String.IsNullOrEmpty(Request["ReturnURL"]))
      {
        if (Request.UrlReferrer != null)
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
          ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
        }
      }
      else
      {
        ReturnUrl = Request["ReturnURL"].Replace("'", "").Replace("|", "?").Replace("**", "&");
      }

      BEName = Server.HtmlEncode(Request.QueryString["Name"]);

      MTTitle1.Text = BEName.Substring(BEName.LastIndexOf("."));

      MyGrid1.ExtensionName = Request.QueryString["Extension"];
      MyGrid1.TemplateFileName = BEName + ".xml";

      GetRelatedEntities();
    }
  }

	private string CheckParameter(string parameter)
	{
		string result = string.Empty;
		try
		{
            // SECENG: Allow empty parameters
            if (!string.IsNullOrEmpty(parameter))
            {
                ApiInput input = new ApiInput(parameter);
                SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input).ToString();
            }

			result = parameter;
		}
		catch (AccessControllerException accessExp)
		{
			Session[Constants.ERROR] = accessExp.Message;
			result = string.Empty;
		}
		catch (Exception exp)
		{
			Session[Constants.ERROR] = exp.Message;
			throw exp;
		}

		return result;
	}

  protected override void OnLoadComplete(EventArgs e)
  {

    MultiSelect = String.IsNullOrEmpty(Request["MultiSelect"]) ? "false" : Request["MultiSelect"];
    ChildGrid = String.IsNullOrEmpty(Request["ChildGrid"]) ? "false" : Request["ChildGrid"];
    Unrelated = String.IsNullOrEmpty(Request["Unrelated"]) ? "false" : Request["Unrelated"];
    RelshipType = String.IsNullOrEmpty(Request["RelshipType"]) ? "false" : Request["RelshipType"];

    if (String.IsNullOrEmpty(MyGrid1.Title))
    {
      var getEntityClient = new MetadataService_GetEntity_Client();
      getEntityClient.UserName = UI.User.UserName;
      getEntityClient.Password = UI.User.SessionPassword;
      getEntityClient.In_entityName = BEName;
      getEntityClient.Invoke();
      Entity entity = getEntityClient.Out_entity;
      MyGrid1.Title = Server.HtmlEncode(entity.GetLocalizedLabel());
     
      if (ChildGrid != "true")
      {
        foreach (Relationship rs in entity.Relationships)
        {
          srcRelationshipType.Value = srcRelationshipType.Value + ",";
          srcRelationshipType.Value = srcRelationshipType.Value + rs.End1.Multiplicity;
          if(RelshipType == "false")
          {
            RelshipType = srcRelationshipType.Value;
          }
        }
      }

    }

    MTTitle1.Text = MyGrid1.Title;

    if(ReturnUrl.Contains("MetraNet"))
    {
      if (MyGrid1.GridButtons.Count > 0)
      {
        MyGrid1.GridButtons.RemoveAt(0);
      }
    }

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
      //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
      MyGrid1.DataSourceURL += "&ParentName=" + Utils.EncodeForJavaScript(Utils.EncodeForHtml(ParentName));
    }

    if (!String.IsNullOrEmpty(ParentId))
    {
      //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
      MyGrid1.DataSourceURL += "&ParentId=" + Utils.EncodeForJavaScript(Utils.EncodeForHtml(ParentId));
    }

    if (!MenuManager.CheckBECapability(MyGrid1.ExtensionName, MetraTech.BusinessEntity.Core.AccessType.Write, UI.SessionContext.SecurityContext))
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

    if (ChildGrid == "true")
    {
      CurrentSourceEntityName = String.IsNullOrEmpty(Request["CurrentSrcEntityName"]) ? null : Request["CurrentSrcEntityName"].ToString();
      MTTitle1.Visible = false;
      BreadCrumb1.Visible = false;
     // MyGrid1.Title = ParentName.Substring(BEName.LastIndexOf(".") + 1) + "--" + MyGrid1.Title + " (" + RelshipType + ") ";
      //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
      MyGrid1.Title = Resources.Resource.TEXT_RELATIONSHIP + " (" +  Utils.EncodeForHtml(RelshipType) + ") ";
        
        if (MultiSelect == "true")
        {
          MyGrid1.MultiSelect = true;
          MyGrid1.SelectionModel = MTGridSelectionModel.Checkbox;
          MTGridButton gridButton1 = new MTGridButton();
          gridButton1.ButtonID = "Remove";
          gridButton1.ButtonText = Resources.Resource.TEXT_REMOVE_RELSHIP;
          gridButton1.ToolTip = Resources.Resource.TEXT_REMOVE_RELSHIP;
          gridButton1.JSHandlerFunction = "onDelete";
          gridButton1.IconClass = "remove";
          this.MyGrid1.ToolbarButtons.Add(gridButton1);
        }
        else
        {
           if(RelshipType != "One--One")
           {
             MyGrid1.MultiSelect = false;
             MyGrid1.SelectionModel = MTGridSelectionModel.Checkbox;
           }
        }
    }
    else
    {
      MTGridButton gridButton1 = new MTGridButton();
      gridButton1.ButtonID = "Delete";
      gridButton1.ButtonText = Resources.Resource.TEXT_DELETE;
      gridButton1.ToolTip = Resources.Resource.TEXT_DELETE;
      gridButton1.JSHandlerFunction = "onDelete";
      gridButton1.IconClass = "remove";
      this.MyGrid1.ToolbarButtons.Add(gridButton1);

      MTGridButton gridButton2 = new MTGridButton();
      gridButton2.ButtonID = "ViewRel";
      gridButton2.ButtonText = "View Relationships";
      gridButton2.ToolTip = "View Relationships";
      gridButton2.JSHandlerFunction = "onViewRel";
      gridButton2.IconClass = "viewrelationship";
     // this.MyGrid1.ToolbarButtons.Add(gridButton2);

      MyGrid1.MultiSelect = true;
      MyGrid1.SelectionModel = MTGridSelectionModel.Checkbox;
    }


    if (BEName != "Core.UI.Site")
    {
      MyGrid1.Buttons = MTButtonType.None;
    }


    base.OnLoadComplete(e);
  }
  #endregion


  #region RelatedEntities
  private void GetRelatedEntities()
  {
    if (BEName != null)
    {
      var getTargetEntitiesClient = new MetadataService_GetTargetEntities_Client();
      getTargetEntitiesClient.UserName = UI.User.UserName;
      getTargetEntitiesClient.Password = UI.User.SessionPassword;
      getTargetEntitiesClient.In_entityName = BEName;
      getTargetEntitiesClient.Invoke();
      List<RelatedEntity> relatedEntities = getTargetEntitiesClient.Out_targetEntities;

     if (relatedEntities.Count > 0)
      {
        foreach (RelatedEntity ent in relatedEntities)
        {
          relatedEntityTypeFullName.Value = relatedEntityTypeFullName.Value + ",";
          //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
          relatedEntityTypeFullName.Value = relatedEntityTypeFullName.Value + Utils.EncodeForHtmlAttribute(ent.Entity.FullName);

          relatedEntityTypeName.Value = relatedEntityTypeName.Value + ",";
          string[] nameArray = ent.Entity.FullName.Split('.');
          //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
          relatedEntityTypeName.Value = relatedEntityTypeName.Value + Utils.EncodeForHtmlAttribute(nameArray[2]);

          targetRelationshipType.Value = targetRelationshipType.Value + ",";
          targetRelationshipType.Value = targetRelationshipType.Value + ent.Multiplicity;
        }
      }

    }
  }
  #endregion
}


// Usage:  http://localhost/MetraNet/BEList.aspx?Name=Core.OrderManagement.Order&Extension=Account
//         &Association=Account&ParentId=123&ParentName=Core.OrderManagement.Parent 
// Loads list of orders with the OrderTemplate.xml grid layout in the Account extension
using System;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.CDT;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Controls.CDT;
using MetraTech.UI.Tools;
using System.Linq;

public partial class BEList : MTPage
{
  #region Variables

  protected const Int32 LIMIT_NUMBER = 500;
  protected string limitDownSearch;

  #endregion

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

  public bool IsRelationshipCase
  {
    get
    {
      var isRelationshipCase = false;
      Boolean.TryParse(Request.QueryString["IsRelationshipCase"], out isRelationshipCase);
      return isRelationshipCase;
    }
  }

  #endregion

  #region Events

  private string GetBMELocalizedName(string bmename)
  {
    var BMEInstanceForm = new MTGenericForm();
    PageLayout layout = BMEInstanceForm.GetPageLayoutByName(BEName);
    if (layout == null)
      return bmename;
    return layout.Header.PageTitle.GetValue();
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      RefererUrl = Encrypt(Request.Url.ToString());

      ResolveAssociation();

      ResolveParent();

      ResolveReturnURL();

      BEName = Server.HtmlEncode(Request.QueryString["Name"]);

      MTTitle1.Text = GetBMELocalizedName(BEName);

      BMEGrid.IsRelationshipCase = IsRelationshipCase;
      var jsConstsLimitDownSearch = GetGlobalResourceObject("JSConsts", "TEXT_LIMIT_DOWN_SEARCH_TO_BULKUPDATE");
      if (jsConstsLimitDownSearch != null)
        limitDownSearch = string.Format(jsConstsLimitDownSearch.ToString(), LIMIT_NUMBER);

      BMEGrid.ExtensionName = Request.QueryString["Extension"];
      BMEGrid.TemplateFileName = string.Concat(BEName, ".xml");
    }
  }

  private string CheckParameter(string parameter)
  {
    string result;
    try
    {
      // SECENG: Allow empty parameters
      if (!string.IsNullOrEmpty(parameter))
      {
        var input = new ApiInput(parameter);
        SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input);
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
    Entity entity = GetEntity();
    
    BMEGrid.Title = MTTitle1.Text;

    if (ChildGrid != "true")
    {
      WriteRelationshipsToHiddenFields(entity);
    }
    
    MTTitle1.Text = BMEGrid.Title;

    SetAdditionalArgumentsForGrid();

    if (!MenuManager.CheckBECapability(BMEGrid.ExtensionName, MetraTech.BusinessEntity.Core.AccessType.Write, UI.SessionContext.SecurityContext) ||
      BEName == "Core.BillMessages.BillMessageAccount" || BEName == "Core.BillMessages.BillMessage" /*CORE-5806 need to suppress the Add button when viewing relationships for Bill Messages in MetraOffer*/)
    /* CORE-5830 need to suppress the Add button on Bill Message Grid when viewing relationships for Bill Message Accounts in MetraCare*/
    {
      ReadOnly = "true";
      if (BMEGrid.ToolbarButtons.Count > 0)
      {
        // remove the first toolbar button which is add by default on generic page
        BMEGrid.ToolbarButtons.RemoveAll(b => b.ButtonID.ToLower() == "add");
      }
    }
    else
    {
      ReadOnly = "false";
    }

    if (ChildGrid == "true")
    {
      SetChildGrid(entity);
    }
    else
    {

      BMEGrid.MultiSelect = true;
      BMEGrid.SelectionModel = MTGridSelectionModel.Checkbox;
    }

    if (!String.IsNullOrEmpty(ParentName) && !String.IsNullOrEmpty(ParentId))
    {
      BMEGrid.ToolbarButtons.RemoveAll(b => b.ButtonID.ToLower() == "bulkupdate" || b.ButtonID.ToLower() == "delete");
    }

    base.OnLoadComplete(e);
  }

  #endregion

  #region Private Methods

  private void ResolveParent()
  {
    ParentName = String.IsNullOrEmpty(Request["ParentName"]) ? null : Request["ParentName"];
    ParentName = CheckParameter(ParentName);

    ParentId = String.IsNullOrEmpty(Request["ParentId"]) ? null : Request["ParentId"];
    ParentId = CheckParameter(ParentId);
  }

  private void ResolveAssociation()
  {
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
  }

  private void ResolveReturnURL()
  {
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
  }

  private void SetMultiSelect()
  {
    BMEGrid.MultiSelect = true;
    BMEGrid.SelectionModel = MTGridSelectionModel.Checkbox;

    MTGridButton gridButton1 = new MTGridButton
                                 {
                                   ButtonID = "Remove",
                                   ButtonText = Resources.Resource.TEXT_REMOVE_RELSHIP,
                                   ToolTip = Resources.Resource.TEXT_REMOVE_RELSHIP,
                                   JSHandlerFunction = "onDelete",
                                   IconClass = "remove"
                                 };

    BMEGrid.ToolbarButtons.Add(gridButton1);
  }

  private string GetLocalizaedRelationType(string relshipType)
  {
    switch (relshipType)
    {
      case "One--One": return Resources.Resource.TEXT_ONE + "--" + Resources.Resource.TEXT_ONE;
      case "Many--Many": return Resources.Resource.TEXT_MANY + "--" + Resources.Resource.TEXT_MANY;
      case "One--Many": return Resources.Resource.TEXT_ONE + "--" + Resources.Resource.TEXT_MANY;
      case "Many--One": return Resources.Resource.TEXT_MANY + "--" + Resources.Resource.TEXT_ONE;
      default: return relshipType;
    }
  }

  private void SetChildGrid(Entity entity)
  {
    CurrentSourceEntityName = String.IsNullOrEmpty(Request["CurrentSrcEntityName"]) ? null : Request["CurrentSrcEntityName"];
    MTTitle1.Visible = false;
    BreadCrumb1.Visible = false;
    //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
    var relationTypeLocalizaed = GetLocalizaedRelationType(RelshipType);
    BMEGrid.Title = string.Concat(Resources.Resource.TEXT_RELATIONSHIP, " (", Utils.EncodeForHtml(relationTypeLocalizaed), ") ");

    if (entity != null)  //hide Add button for 1-to-1 end entity. 
    {
      var relation = entity.Relationships.First(rel => rel.End2.EntityTypeName == ParentName);

      if ((relation.End1.Multiplicity == Multiplicity.One) &&
          (relation.End2.Multiplicity == Multiplicity.One) &&
          (relation.Target.EntityTypeName == ParentName))
        BMEGrid.ToolbarButtons.RemoveAt(0);

    }
    if (MultiSelect == "true")
    {
      SetMultiSelect();
    }
    else
    {
      if (RelshipType != "One--One")
      {
        BMEGrid.MultiSelect = false;
        BMEGrid.SelectionModel = MTGridSelectionModel.Checkbox;
      }
    }
  }

  private Entity GetEntity()
  {
    var getEntityClient = new MetadataService_GetEntity_Client
                            {
                              UserName = UI.User.UserName,
                              Password = UI.User.SessionPassword,
                              In_entityName = BEName
                            };
    getEntityClient.Invoke();
    return getEntityClient.Out_entity;
  }

  private void SetAdditionalArgumentsForGrid()
  {
    // Set additional argument for grid     
    if (!String.IsNullOrEmpty(AccountDefProp))
    {
      BMEGrid.DataSourceURL = string.Concat(BMEGrid.DataSourceURL, "&AccountDef=", Encrypt(AccountDefProp));
    }

    if (!String.IsNullOrEmpty(SubscriptionDefProp))
    {
      BMEGrid.DataSourceURL = string.Concat(BMEGrid.DataSourceURL, "&SubscriptionDef=", Encrypt(SubscriptionDefProp));
    }

    if (!String.IsNullOrEmpty(ParentName))
    {
      //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
      BMEGrid.DataSourceURL = string.Concat(BMEGrid.DataSourceURL, "&ParentName=", Utils.EncodeForJavaScript(Utils.EncodeForHtml(ParentName)));
    }

    if (!String.IsNullOrEmpty(ParentId))
    {
      //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
      BMEGrid.DataSourceURL = string.Concat(BMEGrid.DataSourceURL, "&ParentId=", Utils.EncodeForJavaScript(Utils.EncodeForHtml(ParentId)));
    }
  }

  private void WriteRelationshipsToHiddenFields(Entity entity)
  {
    foreach (Relationship rs in entity.Relationships)
    {
      srcRelationshipType.Value = string.Concat(srcRelationshipType.Value, ",", rs.End1.Multiplicity);
      targetRelationshipType.Value = string.Concat(targetRelationshipType.Value, ",", rs.End2.Multiplicity);

      relatedEntityTypeFullName.Value = string.Concat(relatedEntityTypeFullName.Value, ",", Utils.EncodeForHtmlAttribute(rs.End2.EntityTypeName));
      //relatedEntityTypeFullName.Value = string.Concat(Utils.EncodeForHtmlAttribute(GetBMELocalizedName(relatedEntityTypeFullName.Value)), ",", Utils.EncodeForHtmlAttribute(GetBMELocalizedName(rs.End2.EntityTypeName)));

      relatedEntityTypeName.Value = string.Concat(relatedEntityTypeName.Value, ",", Utils.EncodeForHtmlAttribute(rs.End2.EntityTypeName.Split('.').Last()));

      if (RelshipType == "false")
      {
        RelshipType = srcRelationshipType.Value;
      }
    }
  }

  #endregion
}
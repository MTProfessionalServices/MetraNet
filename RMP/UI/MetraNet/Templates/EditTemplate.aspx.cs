using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Reflection;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;
using MetraTech.ActivityServices.Common;

public partial class Templates_EditTemplate : MTPage
{
  private List<string> skipProperties = new List<string>();
  private void SetupSkipProperties()
  {
    skipProperties.Add("username");
    skipProperties.Add("password_");
    skipProperties.Add("accountstartdate");
    skipProperties.Add("applydefaultsecuritypolicy");
    skipProperties.Add("accounttype");
  }

  public Account TempAccount
  {
    get { return ViewState["TempAccount"] as Account; }
    set { ViewState["TempAccount"] = value; }
  }

  public AccountTemplate AccountTemplateInstance
  {
    get { return ViewState["AccountTemplateInstance"] as AccountTemplate; }
    set { ViewState["AccountTemplateInstance"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      TempAccount = PageNav.Data.Out_StateInitData["TempAccount"] as Account;
      // CORE-6188: Templates: Saving empty values to 'nm_value' instead of deleting them
      // Remove all predefined default properties in all account views 
      // because this property shouldn't be saved in template until this property 
      // is changed manually in form.
      if (TempAccount != null)
      {
        // CORE-6643.
        // If it is not the first access to this page properties may have temporary user input that should not be erased.
        // [TODO]: Implement better way to detect first access to this page by using Query String or View State, as UrlReferrer may be another in future.
        bool isTheFirtsAccess = Request.UrlReferrer.AbsoluteUri.Contains("AddTemplate.aspx") || Request.UrlReferrer.AbsoluteUri.Contains("TemplateSummary.aspx");
        if (isTheFirtsAccess)
        {
          Dictionary<string, List<MetraTech.DomainModel.BaseTypes.View>> vws = TempAccount.GetViews();
          foreach (string key in vws.Keys)
          {
            var lst = vws[key];
            foreach (var view in lst)
            {
              List<PropertyInfo> viewProps = view.GetMTProperties();
              List<PropertyInfo> keyProps = MetraTech.DomainModel.BaseTypes.View.GetKeyProperties(view.ViewName);

              foreach (PropertyInfo viewProp in viewProps)
              {
                if (!keyProps.Contains(viewProp))
                  view.SetValue(viewProp, DBNull.Value);
              }
              view.ResetDirtyFlag();
            }
          }
        }
      }
      AccountTemplateInstance = PageNav.Data.Out_StateInitData["AccountTemplateInstance"] as AccountTemplate;
      // CORE-6188: Templates: Saving empty values to 'nm_value' instead of deleting them
      // Apply all earlier saved properties from template because all properties 
      // were cleared in previous step.
      if (AccountTemplateInstance != null)
      {
        AccountTemplateInstance.ApplyTemplatePropsToAccount(TempAccount);
      }
      MTGenericFormProperties.DataBinderInstanceName = "MTDataBinder1";
      if (TempAccount != null) MTGenericFormProperties.RenderObjectType = TempAccount.GetType();
      MTGenericFormProperties.RenderObjectInstanceName = "TempAccount";
      MTGenericFormProperties.TemplateName = MTGenericFormProperties.RenderObjectType.Name + "_Template";
      MTGenericFormProperties.TemplatePath = TemplatePath;
      MTGenericFormProperties.ReadOnly = false;
      SetupSkipProperties();
      MTGenericFormProperties.IgnoreProperties = skipProperties;

      MTGenericFormAccountTemplate.DataBinderInstanceName = "MTDataBinder1";
      if (AccountTemplateInstance != null) MTGenericFormAccountTemplate.RenderObjectType = AccountTemplateInstance.GetType();
      MTGenericFormAccountTemplate.RenderObjectInstanceName = "AccountTemplateInstance";
      MTGenericFormAccountTemplate.TemplateName = MTGenericFormAccountTemplate.RenderObjectType.Name + "_Template";
      MTGenericFormAccountTemplate.TemplatePath = TemplatePath;
      MTGenericFormAccountTemplate.ReadOnly = false;

      MTDataBinder1.UseMinimalBinding = true;
      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }

    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();

      TemplateEvents_OKEditTemplate_Client add = new TemplateEvents_OKEditTemplate_Client();
      add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      add.In_TempAccount = TempAccount;
      add.In_AccountTemplateInstance = AccountTemplateInstance;
      PageNav.Execute(add);
    }
  }
  
  protected void btnSaveAndApply_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();

      TemplateEvents_SaveAndApplyTemplate_Client add = new TemplateEvents_SaveAndApplyTemplate_Client();
      add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      add.In_TempAccount = TempAccount;
      add.In_AccountTemplateInstance = AccountTemplateInstance;

      PageNav.Execute(add);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    TemplateEvents_CancelEditTemplate_Client cancel = new TemplateEvents_CancelEditTemplate_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    if (PageNav != null) PageNav.Execute(cancel);
  }

  protected void btnAddSubscription_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();

      TemplateEvents_AddSubscription_Client add = new TemplateEvents_AddSubscription_Client();
      add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      add.In_TempAccount = TempAccount;
      add.In_AccountTemplateInstance = AccountTemplateInstance;
      if (PageNav != null) PageNav.Execute(add);
    }
  }
  protected void btnAddGroupSubscription_Click(object sender, EventArgs e)
  {
    Page.Validate();
    if (Page.IsValid)
    {
      MTDataBinder1.GetDataBindingItem("tbAccountID").BindingMode = BindingModes.None;
      MTDataBinder1.Unbind();

      TemplateEvents_AddGroupSubscription_Client add = new TemplateEvents_AddGroupSubscription_Client();
      add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      add.In_TempAccount = TempAccount;
      add.In_AccountTemplateInstance = AccountTemplateInstance;
      if (PageNav != null) PageNav.Execute(add);
    }
  }

}
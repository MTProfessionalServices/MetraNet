using System;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;

//TODO: Need to be ref-factoring on using the only AddAccount, after that AddAccountWorkflow and all other
//TODO: GenericAddAccount.aspx/GenericUpdateAccount.aspx/GenericAccountSummary.aspx can be thrown from MetraNet project
public partial class Account_GenericAccountSummary : MTPage
{

  public Account ActiveAccount
  {
    get
    {
      return UI.Subscriber.SelectedAccount;
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = ActiveAccount.GetType();
      MTGenericForm1.RenderObjectInstanceName = "ActiveAccount";
      MTGenericForm1.TemplatePath = TemplatePath;
      MTGenericForm1.ReadOnly = true;
      var Properties = ActiveAccount.GetType().GetProperties();
      foreach (var property in Properties)
      {
        object Result = property.GetValue(ActiveAccount, null);
        if (Result == null)
        {
          try
          {
            Type type = property.PropertyType;
            if (!type.ToString().Contains("System."))
              property.SetValue(ActiveAccount, Activator.CreateInstance(type), null);
          }
          catch (Exception exp)
          {
            Logger.LogWarning(exp.Message);
          }
        }
      }
    }
  }

  protected void MTDataBinder1_AfterBindControl(MTDataBindingItem Item)
  {
    // Go get pricelist display name
    if (Item.BindingSourceMember.ToLower() == "pricelist")
    {
      using (var ipl = new MetraTech.Core.Services.ClientProxies.PriceListServiceClient())
      {

        try
        {

          if (ipl.ClientCredentials != null)
          {
            ipl.ClientCredentials.UserName.UserName = UI.User.UserName;
            ipl.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }

          int? pricelistId = ((InternalView)ActiveAccount.GetInternalView()).PriceList;
          if (pricelistId != null)
          {
            PriceList plobject;
            ipl.GetPriceList(Convert.ToInt32(pricelistId), out plobject);
            var priceListCtl = FindControlRecursive(MTGenericForm1, "tbInternal_PriceList") as MTTextBoxControl;
            if (priceListCtl != null)
            {
              priceListCtl.Text = plobject.Name;
              MTDataBinder1.GetDataBindingItem(priceListCtl).BindingMode = BindingModes.None;
            }
          }
        }
        catch (Exception exp)
        {
          Logger.LogWarning(exp.Message);
        }
      }
    }
  }
}
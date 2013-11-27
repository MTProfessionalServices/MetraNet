using System;
using System.Reflection;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;

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
            MTGenericForm1.TemplatePath = TemplatePath;  // +@"\AccountSummary\";
            MTGenericForm1.TemplateName = MTGenericForm1.RenderObjectType.Name;
            MTGenericForm1.ReadOnly = true;
            var Properties = ActiveAccount.GetType().GetProperties();
            foreach (var property in Properties)
            {
              object Result = ((PropertyInfo)property).GetValue(ActiveAccount, null);
              if (Result == null)
              {
                try
                {
                  Type type = ((PropertyInfo) property).PropertyType;
                  if (!type.ToString().Contains("System."))
                    property.SetValue(ActiveAccount, Activator.CreateInstance(type), null);
                }
                catch (Exception )
                {

                }
              }
            }
          }     
        }

    protected void MTDataBinder1_AfterBindControl(MTDataBindingItem Item)
    {
        // Go get pricelist display name
        MetraTech.Core.Services.ClientProxies.PriceListServiceClient ipl = null;

        try
        {
            if (Item.BindingSourceMember.ToLower() == "pricelist")
            {

                ipl = new MetraTech.Core.Services.ClientProxies.PriceListServiceClient();

                ipl.ClientCredentials.UserName.UserName = UI.User.UserName;
                ipl.ClientCredentials.UserName.Password = UI.User.SessionPassword;

                int? pricelistId = ((InternalView)ActiveAccount.GetInternalView()).PriceList;
                if (pricelistId != null)
                {
                  PriceList plobject;
                  ipl.GetPriceList(Convert.ToInt32(pricelistId), out plobject);
                  MTTextBoxControl priceListCtl = FindControlRecursive(MTGenericForm1, "tbInternal_PriceList") as MTTextBoxControl;
                  if (priceListCtl != null)
                  {
                    priceListCtl.Text = plobject.Name;
                    MTDataBinder1.GetDataBindingItem(priceListCtl).BindingMode = BindingModes.None;
                  }
                }                
            }

              
        }
        catch (Exception exp)
        {
            Logger.LogWarning(exp.Message);
        }
        finally
        {
            if (ipl != null)
            {
                if (ipl.State == System.ServiceModel.CommunicationState.Opened)
                {
                    ipl.Close();
                }
                else
                {
                    ipl.Abort();
                }
            }
        }
    }
}
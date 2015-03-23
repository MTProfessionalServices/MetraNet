using System;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;

namespace MetraNet.MetraOffer.PriceLists
{
  public partial class CreateSharedPriceList : MTPage
  {
    public PriceList SharedPriceList
    {
      get { return ViewState["sharedpricelist"] as PriceList; } //The ViewState labels are immaterial here..
      set { ViewState["sharedpricelist"] = value; }
    }

    public bool IsPartition { get { return PartitionLibrary.PartitionData.isPartitionUser; } }

    protected void Page_Load(object sender, EventArgs e)
    {
      if (IsPostBack) return;
      try
      {
        SharedPriceList = new PriceList();

        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        MTGenericForm1.RenderObjectType = SharedPriceList.GetType();

        //This should be same as the public property defined above 
        MTGenericForm1.RenderObjectInstanceName = "sharedpricelist";

        //This is the Page Layout Template name
        MTGenericForm1.TemplateName = "Core.UI.CreateSharedPriceList";
        MTGenericForm1.ReadOnly = false;

        //MTTextBoxControl tbPLPartitionId = FindControlRecursive(MTGenericForm1, "tbPLPartitionId") as MTTextBoxControl;
        //tbPLPartitionId.ReadOnly = true;

        SharedPriceList.PLPartitionId = PartitionLibrary.PartitionData.isPartitionUser
                                          ? PartitionLibrary.PartitionData.PLPartitionId
                                          : 1;

        if (!MTDataBinder1.DataBind())
        {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
        }
      }
      catch (Exception ex)
      {
        Logger.LogError(ex.ToString());
      }
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
      if (!MTDataBinder1.Unbind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }

      using (var client = new PriceListServiceClient())
        try
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }

          var mypl = SharedPriceList;
          client.SaveSharedPriceList(ref mypl);
          Response.Redirect("PriceListsList.aspx", false);
        }
        catch (Exception ex)
        {
          SetError(ex.Message);
          Logger.LogError(ex.Message);
          client.Abort();
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("PriceListsList.aspx?PreviousResultView=True");
    }

  }
}
using System;

using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;

public partial class Tax_SaveBillSoftOverride : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
     
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
      int accountId = System.Convert.ToInt32(tbIdAcc.Text);
      bool applyToDescendents = false;
      if (cbApplyDescendents.Checked)
      {
        applyToDescendents = true;
      }

      BillSoftOverride billSoftOverride = null;
      TaxServiceClient client = null;

      try
      {
        client = new TaxServiceClient();
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        client.Open();
        client.CreateBillSoftOverride(accountId, applyToDescendents, out billSoftOverride);
        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        SetError(ex.ToString());
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

      ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_CREATED_TITLE")),
                     String.Format("{0}", GetLocalResourceObject("TEXT_CREATED")),
                     billSoftOverride != null ? String.Format("Tax/EditBillSoftOverrides.aspx?OverrideId={0}", billSoftOverride.UniqueId) : null);
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("BillSoftOverrides.aspx");
    }
}
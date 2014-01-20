using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;

public partial class Tax_SaveBillSoftExemption : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
      int accountId = System.Convert.ToInt32(tbIdAcc.Text);
      bool applyToDescendents = false;
      if (cbApplyDescendents.Checked)
        applyToDescendents = true;

      BillSoftExemption billSoftExemption = null;
      TaxServiceClient client = null;

      try
      {
        client = new TaxServiceClient();
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        client.Open();
        client.CreateBillSoftExemption(accountId, applyToDescendents, out billSoftExemption);
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
                     billSoftExemption != null ? String.Format("Tax/EditBillSoftExemptions.aspx?Action=Edit&ExemptionId={0}", billSoftExemption.UniqueId) : null);
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("BillSoftExemptions.aspx");
    }
}
using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI.WebControls;
using MetraTech;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;

public partial class Tax_EditBillSoftExemptions : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {

      string exemptionId = Request["ExemptionId"];
      tbExemptionId.Value = exemptionId;

      int id = System.Convert.ToInt32(exemptionId);

      TaxServiceClient client = null;
      BillSoftExemption exemption = null;

      try
      {
        client = new TaxServiceClient();
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        client.Open();
        client.GetBillSoftExemption(id, out exemption);
        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        SetError(ex.ToString());
        exemption = null;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

      if (exemption != null)
      {
        tbIdAcc.Text = exemption.AccountId.ToString();
        tbPcode.Text = exemption.PermanentLocationCode.ToString();
        tbCertificateId.Text = exemption.CertificateId;
        tbTaxType.Text = exemption.TaxType.ToString();
        cbApplyDescendents.Checked = exemption.ApplyToAccountAndDescendents;
        dpStartDate.Text = exemption.StartDate.ToString();
        dpEndDate.Text = exemption.EndDate.ToString();

        ddTaxLevel.EnumSpace = "metratech.com/tax";
        ddTaxLevel.EnumType = "BillSoftTaxLevel";

        var enumType = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType("metratech.com/tax",
                                                                                   "BillSoftTaxLevel",
                                                                                   Path.GetDirectoryName(
                                                                                     new Uri(
                                                                                       this.GetType().Assembly.CodeBase)
                                                                                       .AbsolutePath));
        if (enumType != null)
        {
          List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

          foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
          {
            ListItem itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
            ddTaxLevel.Items.Add(itm);
          }
        }

        ddTaxLevel.SelectedValue = exemption.TaxLevel.ToString();
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    BillSoftExemption exemption = new BillSoftExemption();
    exemption.UniqueId = System.Convert.ToInt32(tbExemptionId.Value);
    exemption.AccountId = System.Convert.ToInt32(tbIdAcc.Text);
    exemption.CertificateId = tbCertificateId.Text;
    exemption.PermanentLocationCode = System.Convert.ToInt32(tbPcode.Text);
    exemption.TaxLevel =
      (BillSoftTaxLevel)EnumHelper.GetGeneratedEnumByEntry(typeof(BillSoftTaxLevel), ddTaxLevel.SelectedValue);
    exemption.TaxType = System.Convert.ToInt32(tbTaxType.Text.ToString());
    exemption.ApplyToAccountAndDescendents = cbApplyDescendents.Checked;
    exemption.StartDate = System.Convert.ToDateTime(dpStartDate.Text);
    exemption.EndDate = System.Convert.ToDateTime(dpEndDate.Text);
    exemption.UpdateDate = MetraTime.Now;

    TaxServiceClient client = null;
    try
    {
      client = new TaxServiceClient();
      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      client.Open();
      client.SaveBillSoftExemption(exemption);
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

    ConfirmMessage(String.Format("{0}", GetLocalResourceObject("TEXT_UPDATED_TITLE")),
                   String.Format("{0}", GetLocalResourceObject("TEXT_UPDATED")),
                   "Tax/BillSoftExemptions.aspx");
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("BillSoftExemptions.aspx");
  }
}
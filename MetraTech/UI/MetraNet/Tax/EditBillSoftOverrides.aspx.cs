using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;

public partial class Tax_EditBillSoftOverrides : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      if (!IsPostBack)
      {
        int overrideId = System.Convert.ToInt32(Request["OverrideId"]);
        tbOverrideId.Value = overrideId.ToString();

        MTDropDownScope.EnumSpace = "metratech.com/tax";
        MTDropDownScope.EnumType = "BillSoftTaxLevel";

        MTDropDownTaxLevel.EnumSpace = "metratech.com/tax";
        MTDropDownTaxLevel.EnumType = "BillSoftTaxLevel";

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
            MTDropDownScope.Items.Add(itm);

            // CORE-6020 Must use distinct ListItems for different dropdowns.
            itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
            MTDropDownTaxLevel.Items.Add(itm);
          }
        }

        BillSoftOverride bsOverride = null;
        TaxServiceClient client = null;
        try
        {
          client = new TaxServiceClient();
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          client.Open();
          client.GetBillSoftOverride(overrideId, out bsOverride);
          client.Close();
          client = null;
        }
        catch (Exception ex)
        {
          SetError(ex.ToString());
          bsOverride = null;
        }
        finally
        {
          if (client != null)
          {
            client.Abort();
          }
        }

        if (bsOverride != null)
        {
          tbExcessTaxRate.Text = bsOverride.ExcessTaxRate.ToString();
          tbIdAcc.Text = bsOverride.AccountId.ToString();
          tbLimitIndicator.Text = bsOverride.LimitIndicator.ToString();
          tbPcode.Text = bsOverride.PermanentLocationCode.ToString();
          tbTaxRate.Text = bsOverride.TaxRate.ToString();
          tbTaxType.Text = bsOverride.TaxType.ToString();
          cbApplyDescendents.Checked = bsOverride.ApplyToAccountAndDescendents;
          MTReplaceTaxLevel1.Checked = bsOverride.ReplaceTaxLevel;
          MTDropDownScope.SelectedValue = bsOverride.Scope.ToString();
          MTDropDownTaxLevel.SelectedValue = bsOverride.TaxLevel.ToString();

          if (bsOverride.EffectiveDate != null)
          {
            dpStartDate.Text = bsOverride.EffectiveDate.ToString();
          }
        }
      }
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
      
      BillSoftOverride bsOverride = new BillSoftOverride();
      bsOverride.UniqueId = System.Convert.ToInt32(tbOverrideId.Value);

      TaxServiceClient client = null;
      try
      {
        client = new TaxServiceClient();
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        client.Open();

        // CORE-5960: "Disabling" Excess Tax Rate and Limit Indicator at UI level for Release 6.8.1.
        //bsOverride.ExcessTaxRate = System.Convert.ToDecimal(tbExcessTaxRate.Text);
        //bsOverride.LimitIndicator = System.Convert.ToDecimal(tbLimitIndicator.Text);
        bsOverride.AccountId = System.Convert.ToInt32(tbIdAcc.Text);
        bsOverride.PermanentLocationCode = System.Convert.ToInt32(tbPcode.Text);
        bsOverride.TaxRate = System.Convert.ToDecimal(tbTaxRate.Text);
        bsOverride.TaxType = System.Convert.ToInt32(tbTaxType.Text);
        bsOverride.ApplyToAccountAndDescendents = cbApplyDescendents.Checked;
        bsOverride.ReplaceTaxLevel = MTReplaceTaxLevel1.Checked;
        bsOverride.Scope = (BillSoftTaxLevel)EnumHelper.GetGeneratedEnumByEntry(typeof(BillSoftTaxLevel), MTDropDownScope.SelectedValue);
        bsOverride.TaxLevel = (BillSoftTaxLevel)EnumHelper.GetGeneratedEnumByEntry(typeof(BillSoftTaxLevel), MTDropDownTaxLevel.SelectedValue);
        bsOverride.EffectiveDate = System.Convert.ToDateTime(dpStartDate.Text);

        client.SaveBillSoftOverride(bsOverride);
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
                     "Tax/BillSoftOverrides.aspx");
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("BillSoftOverrides.aspx");
    }
}
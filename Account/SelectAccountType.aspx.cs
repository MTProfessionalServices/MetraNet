using System;
using System.Collections;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.ActivityServices.Common;

public partial class Account_SelectAccountType : MTPage
{

    public ArrayList AccountTypes
    {
        get { return ViewState["AccountTypes"] as ArrayList; }
        set { ViewState["AccountTypes"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            AccountTypes = PageNav.Data.Out_StateInitData["AccountTypes"] as ArrayList;

            if (!MTDataBinder1.DataBind())
            {
                Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
            }

            // Remove "Partition" account type from dropdown
            ddAccountTypes.Items.Remove("Partition");

            // Partitions should never be allowed to add accounts out of the hierarchy
            if (PartitionLibrary.IsPartition)
            {
                ddAccountTypes.Items.Remove("IndependentAccount");
            }
        }
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
        Page.Validate();
        if (Page.IsValid)
        {
            MTDataBinder1.Unbind();

            AddAccountEvents_SelectAccountType_Client selectedAccountType = new AddAccountEvents_SelectAccountType_Client();
            selectedAccountType.In_SelectedAccountType = ddAccountTypes.SelectedValue;
            selectedAccountType.In_AccountId = new AccountIdentifier(UI.User.AccountId);
            PageNav.Execute(selectedAccountType);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        AddAccountEvents_CancelAddAccount_Client cancel = new AddAccountEvents_CancelAddAccount_Client();
        cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        PageNav.Execute(cancel);
    }
}

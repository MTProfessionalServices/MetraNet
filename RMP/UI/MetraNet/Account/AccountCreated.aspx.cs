using System;
using MetraTech.UI.Common;
using MetraTech.DomainModel.BaseTypes;

public partial class Account_AccountCreated : MTPage
{

  public int defAcctId = -1;
  public int NewAccountId
  {
    get
    {
      if (ViewState["NewAccountId"] != null)
        return int.Parse(ViewState["NewAccountId"].ToString());
      else
        return defAcctId;
    }         
    set { ViewState["NewAccountId"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
     /* NewAccountId = int.Parse(PageNav.Data.Out_StateInitData["NewAccountId"].ToString());

      Account acc = PageNav.Data.Out_StateInitData["Account"] as Account;

      if (acc.AccountStartDate.HasValue)
      {
        if (acc.AccountStartDate.Value > ApplicationTime)
        {
          btnManage.Visible = false;
          lblFutureAccount.Visible = true;
          lblFutureAccount.Text = string.Format(lblFutureAccount.Text, acc.AccountStartDate.Value.ToShortDateString());
        }
      }*/

    if(PageNav != null)
    {
      try      
      {
          if(PageNav.Data != null)
          {
           NewAccountId = int.Parse(PageNav.Data.Out_StateInitData["NewAccountId"].ToString());
           Account acc = PageNav.Data.Out_StateInitData["Account"] as Account;

	           if (acc.AccountStartDate.HasValue)
             {
                if (acc.AccountStartDate.Value > ApplicationTime)
                {
                  btnManage.Visible = false;
                  lblFutureAccount.Visible = true;
                  lblFutureAccount.Text = string.Format(lblFutureAccount.Text, acc.AccountStartDate.Value.ToShortDateString());
                }
			       }
           
           }
	   }
	   catch(Exception ex)
	   {
       SetError(ex.Message);
	   }
    
    }
   }
  }
}

using System;
using MetraTech.UI.Common;

/// <summary>
/// 
/// </summary>
public partial class RevRecReport : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Create CSR Accounts"))
      Response.End();
  }
}

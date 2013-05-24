using System;
using MetraTech.UI.Common;

public partial class MasterPages_PageExt : System.Web.UI.MasterPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    MTPage p = Page as MTPage;
    if (p == null) return;
    if (p.UI == null || p.PageNav == null) return;

    if (p.UI.Subscriber.SelectedAccount == null)
    {
      PanelActiveAccount.Visible = false;
    }
  }

  /// <summary>
  /// Return the current HelpPage.
  /// </summary>
  public string HelpPage
  {
    get { return Session[Constants.HELP_PAGE] as string; }
  }

  /// <summary>
  /// Return the current workflow state.
  /// </summary>
  public string CurrentState
  {
    get
    {
      MTPage p = Page as MTPage;
      if (p == null) return String.Empty;

      if (p.UI != null && p.PageNav != null)
      {
        return p.PageNav.State;
      }

      return String.Empty;
    }
  }

  /// <summary>
  /// Return the current workflow processor Id.
  /// </summary>
  public string ProcessorId
  {
    get
    {
      MTPage p = Page as MTPage;
      if (p == null) return String.Empty;

      if (p.UI != null && p.PageNav != null)
      {
        return p.PageNav.ProcessorId.ToString();
      }

      return String.Empty;
    }
  }

  /// <summary>
  /// Return the name of the last interface called
  /// </summary>
  public string InterfaceName
  {
    get
    {
      MTPage p = Page as MTPage;
      if (p == null) return String.Empty;

      if (p.UI != null && p.PageNav != null)
      {
        return p.PageNav.InterfaceName;
      }

      return String.Empty;
    }
  }

}

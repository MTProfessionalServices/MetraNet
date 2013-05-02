using System;
using System.Text;
using System.Web;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;

public static class MenuRenderer
{
  public static string Render(Menu menu, UIManager ui)
  {
    if (menu.Type.Equals(MenuManager.MenuType.Vertical))
    {
      return RenderMenuVertical(menu, ui);
    }
    else
    {
      return RenderMenuHorizontal(menu, ui);
    }
  }

  /// <summary>
  /// Renders a horizontal menu loaded from config.
  /// </summary>
  /// <param name="menu"></param>
  /// <param name="ui"></param>
  /// <returns></returns>
  public static string RenderMenuHorizontal(Menu menu, UIManager ui)
  {
    StringBuilder sb = new StringBuilder();

    foreach (var menuSection in menu.MenuSections)
    {
      if(menu.ID == "AdminMenu")
      {
        sb.Append("<ul id=\"adminnavlist\">");
      }
      else
      {
        sb.Append("<ul id=\"navlist\">");  
      }
      
      foreach (var menuItem in menuSection.MenuItems)
      {
        if (MenuManager.IsMenuItemVisible(ui.SessionContext.SecurityContext, menuItem))
        {
          string caption = menuItem.Caption.GetValue();
          if (caption == null)
          {
            caption = menuItem.Caption + " {NL}";
          }
          //caption = HttpContext.Current.Server.HtmlEncode(caption);

          string style = string.Empty;

          if (menuItem.IsRenderDependFromLocalization)
          {
            switch (System.Threading.Thread.CurrentThread.CurrentUICulture.Name)
            {
              case "pt-BR":
              case "de-DE":
              case "de":
              case "it":
                // Adjust padding to accommodate two-line tab labels.
                style = "style=\"padding:2px 20px 0px 12px;\"";
                break;
            }
          }

          string listItem = "<li class=\"{0}\">";
          string linkItem = "<a id=\"{0}\" href=\"{1}\" alt=\"{2}\" target=\"{3}\" {4}>{2}</a>";
          if (HttpContext.Current.Session[SiteConstants.ActiveMenu].ToString() == menuItem.ID)
          {
            listItem = String.Format(listItem, "on");
          }
          else
          {
            listItem = String.Format(listItem, "off");
          }
          linkItem = String.Format(linkItem, "link" + menuItem.ID, GetLink(menuItem.Link, ui), caption, menuItem.Target, style);
          sb.Append(listItem);
          sb.Append(linkItem);
          sb.Append("</li>");
        }
      }
      sb.Append("</ul>");
    }

    return sb.ToString();
  }


  /// <summary>
  /// Renders a Vertical Ext menu, loaded from config.
  /// </summary>
  /// <param name="menu"></param>
  /// <param name="ui"></param>
  /// <returns></returns>
  public static string RenderMenuVertical(Menu menu, UIManager ui)
  {
    StringBuilder sb = new StringBuilder();
    sb.Append("not implemented...");
    return sb.ToString();
  }

  /// <summary>
  /// Returns either the link, or the link resolved by dictionary key wrapped in [ ]
  /// </summary>
  /// <param name="link"></param>
  /// <param name="ui"></param>
  /// <returns></returns>
  public static string GetLink(string link, UIManager ui)
  {
    if (link.StartsWith("["))
    {
      string dictionaryKey = Utils.ExtractString(link, "[", "]");
      link = ui.DictionaryManager[dictionaryKey].ToString();
    }

    // TODO: support starts with http or https or / otherwise add virtual dir

    return link;  
  }
}

using System;
using System.Text;
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
		else if (menu.Type.Equals(MenuManager.MenuType.Context))
		{
			return RenderMenuContext(menu, ui);
		}
    else
    {
      return RenderMenuHorizontal(menu, ui);
    }
  }

  /// <summary>
  /// Renders a horizontal Ext menu loaded from config.
  /// </summary>
  /// <param name="menu"></param>
  /// <param name="ui"></param>
  /// <returns></returns>
  public static string RenderMenuHorizontal(Menu menu, UIManager ui)
  {
    StringBuilder sb = new StringBuilder();

    sb.Append("<div id=\"container\">");
    sb.Append("<div id=\"toolbar\"></div>");
    sb.Append("</div>");

    sb.Append("<script language=\"javascript\" type=\"text/javascript\">");
    sb.Append("Ext.onReady(function(){");
    sb.Append("Ext.QuickTips.init();");

    sb.Append("var tbPanel = new Ext.Panel({autoShow: true});");
    sb.Append("var tb = new Ext.Toolbar({enableOverflow: true});");

    foreach (MenuSection menuSection in menu.MenuSections)
    {
      if (MenuManager.IsMenuSectionVisible(ui.SessionContext.SecurityContext, menuSection))
      {
        // create empty Ext menu with menuSection.ID
        sb.Append("var menu");
        sb.Append(menuSection.ID);
        sb.Append(" = new Ext.menu.Menu({id: '");
        sb.Append(menuSection.ID);
        sb.Append("'});");

        // Add menu section to toolbar
        sb.Append("tb.add({");
        sb.Append("  cls: 'x-btn-text-icon bmenu',");
        sb.Append("  text:'");

        string caption = menuSection.Caption.GetValue();
        if (caption != null)
        {
          sb.Append(caption);
        }
        else
        {
          sb.Append(menuSection.Caption + " {NL}");
        }

        sb.Append("', ");
        sb.Append("menu: menu");
        sb.Append(menuSection.ID);
        sb.Append("}); ");
      }
    }

    // add menu items to each visible menu section
    foreach (MenuSection menuSection in menu.MenuSections)
    {
      if (MenuManager.IsMenuSectionVisible(ui.SessionContext.SecurityContext, menuSection))
      {
        foreach (MenuItem menuItem in menuSection.MenuItems)
        {
          if (MenuManager.IsMenuItemVisible(ui.SessionContext.SecurityContext, menuItem))
          {
            // Add menu item 
            sb.Append("menu");
            sb.Append(menuSection.ID);
            sb.Append(".add({");

            // menu item id
            sb.Append("id: '");
            sb.Append(menuItem.ID);
            sb.Append("',");

            // menu item link
            sb.Append("href: ");
            sb.Append("'");
            sb.Append(GetLink(menuItem.Link, ui));
            sb.Append("',");

            // menu item target
            if (menuItem.Target != String.Empty)
            {
              sb.Append("target: ");
              sb.Append("'");
              sb.Append(menuItem.Target);
              sb.Append("',");
            }

            //menu item icon
            if (menuItem.Icon != String.Empty)
            {
              sb.Append("icon: '");
              sb.Append(menuItem.Icon);
              sb.Append("',");
            }

            // menu item text
            string menuItemCaption = menuItem.Caption.GetValue();
            sb.Append("text: '");
            if (menuItemCaption != null)
            {
              sb.Append(menuItemCaption);
            }
            else
            {
              sb.Append(menuItem.Caption + " {NL}");
            }

            sb.Append("'});");
          }

        }
      }
      
    }

    sb.Append("tbPanel.render(Ext.get('toolbar'));"); 
    sb.Append("tbPanel.add(tb);");
    sb.Append("tbPanel.doLayout();");

    sb.Append("});");
    sb.Append("</script>");

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

    foreach (MenuSection menuSection in menu.MenuSections)
    {

      if (MenuManager.IsMenuSectionVisible(ui.SessionContext.SecurityContext, menuSection))
      {
        sb.Append("<div id=\"container" + menuSection.ID + "\"></div>");
        sb.Append("<div id=\"content" + menuSection.ID + "\" class=\"x-menu\">");

        // menu content  
        sb.Append("<ul class=\"x-menu-list\">");

        foreach (MenuItem menuItem in menuSection.MenuItems)
        {
          if (MenuManager.IsMenuItemVisible(ui.SessionContext.SecurityContext, menuItem))
          {
            sb.Append("<li class=\"x-menu-list-item\"><a class=\"x-menu-item\"");
            menuItem.Link = GetLink(menuItem.Link, ui);
            sb.Append(" id=\""); sb.Append(menuItem.ID); sb.Append("\"");
            sb.Append(" href=\"");
            sb.Append(menuItem.Link);
            sb.Append("\"");
            sb.Append(" target=\""); sb.Append(menuItem.Target); sb.Append("\"");
            sb.Append(">");
            if (menuItem.Icon != String.Empty)
            {
              sb.Append("<img class=\"x-menu-item-icon\"");
              sb.Append(" src=\""); sb.Append(menuItem.Icon); sb.Append("\"");
              sb.Append("/>");
            }
            string menuItemCaption = menuItem.Caption.GetValue();
            if (menuItemCaption != null)
            {
              sb.Append(menuItemCaption);
            }
            else
            {
              sb.Append(menuItem.Caption + " {NL}");
            }
            sb.Append("</a></li>");
          }
        }

        sb.Append("</ul>");
        sb.Append("</div>");
      }
    }

    sb.Append("<script type=\"text/javascript\">");
    sb.Append("Ext.onReady(function(){");
    sb.Append("Ext.get(document.body).mask('Loading...');");
	bool first = true;
    foreach (MenuSection menuSection in menu.MenuSections)
    {
      if (MenuManager.IsMenuSectionVisible(ui.SessionContext.SecurityContext, menuSection))
      {
        string menuSectionCaption = menuSection.Caption.GetValue();
        if (menuSectionCaption == null)
        {
          menuSectionCaption = menuSection.Caption + " {NL}";
        }

        sb.Append("var menuPanel" + menuSection.ID + " = new Ext.Panel({");
        sb.Append("title: '&nbsp;&nbsp;&nbsp;&nbsp;" + menuSectionCaption + "',");
        sb.Append("layout:'fit',");
        sb.Append("collapsible:true,");
		if (first)
		{
          sb.Append("collapsed:false,");
		}
		else
		{
          sb.Append("collapsed:true,");
		}
        sb.Append("titleCollapse : true,");
        sb.Append("renderTo: 'container" + menuSection.ID + "',");
        sb.Append("contentEl: 'content" + menuSection.ID + "'");
        sb.Append("});");
		first = false;
      }
    }

    sb.Append("Ext.get(document.body).unmask();");
    sb.Append("});");
    sb.Append("</script>");

    return sb.ToString();
  }

	public static string RenderMenuContext(Menu menu, UIManager ui)
	{
		StringBuilder sb = new StringBuilder();
		sb.AppendLine("new Ext.menu.Menu({");
		sb.AppendFormat("id : '{0}',", menu.ID);
        sb.AppendLine();
        bool firstItem = true;
        sb.AppendLine("items: [");
		foreach (MenuSection menuSection in menu.MenuSections)
		{
			//Check capabilities for menu section
			if (MenuManager.IsMenuSectionVisible(ui.SessionContext.SecurityContext, menuSection))
			{
				foreach (MenuItem menuItem in menuSection.MenuItems)
				{
					//Check capabilities for menu items
					if (MenuManager.IsMenuItemVisible(ui.SessionContext.SecurityContext, menuItem))
					{
                        sb.Append(firstItem ? string.Empty : ",");
                        sb.AppendLine("{");
						sb.AppendFormat("id : '{0}',", menuItem.ID);
						sb.AppendLine();
                        sb.AppendFormat("text : '{0}',", menuItem.Caption.GetValue());
                        sb.AppendLine();
                        
						//Set action for menu item.
						if (!menuItem.Link.StartsWith("javascript:"))
						{
							string link = GetLink(menuItem.Link, ui);
							sb.AppendFormat("href : '{0}',", link);
						}
						else
						{
                            sb.AppendFormat("listeners: {{ click :  function (item, e) {{ {0} }} }},", menuItem.Link.Replace("javascript:", string.Empty));
						}

                        sb.AppendLine();

						sb.AppendFormat("hrefTarget : '{0}',", menuItem.Target);
						sb.AppendLine();
						sb.AppendFormat("icon : '{0}'", menuItem.Icon);
						sb.AppendLine();
						sb.Append("}");
						sb.AppendLine();
                        firstItem = false;
					}
				}
			}
		}
        sb.AppendLine("],");
        sb.AppendLine("listeners: { hide: function(e){e.destroy();} }");
        sb.AppendLine("});");

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
    return link;  
  }
}

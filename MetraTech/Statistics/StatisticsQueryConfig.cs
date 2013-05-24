using System.Runtime.InteropServices;

[assembly: Guid("2d472c21-0c43-4269-91a4-4068a9519315")]

namespace MetraTech.Statistics
{
	using System;
	using System.Collections;
  using System.Web;
  using System.Text;
	using System.Xml;
  
  using MetraTech.Xml;
  using MetraTech.Interop.RCD;


	//using MetraTech.Interop.MTUsageServer;
	[Guid("e279b868-4c68-4b14-acd6-b558821b6248")]
	public interface IStatisticsQueryConfig 
  {
    string GetMenuXML(string classification, string menuLink, string menuLinkTarget);
  }

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("0d2dcaad-d4f2-4d9d-8008-990f348e4511")]
  public class StatisticsQueryConfig : IStatisticsQueryConfig
  {
    public string GetMenuXML(string classification, string menuLink, string menuLinkTarget)
    {
      
      //Replace any '&' in the link with '&amp;' for the xml
      StringBuilder utilString = new StringBuilder(menuLink);
      utilString.Replace("&", "&amp;");
      menuLink = utilString.ToString();

      ArrayList alMenuItems = new ArrayList();
      MenuGroup root = new MenuGroup("root");

      // start building the xml
      string sXML;
      sXML  = "<?xml version=\"1.0\"?><MetraTech>\n";

      // find all querylist.xml files
      IMTRcd rcd = (IMTRcd) new MTRcd();
      IMTRcdFileList fileList = rcd.RunQuery("config\\Statistics\\querylist.xml", true);

      foreach (string fileName in fileList)
      {
        //load file
        sXML+= "<!-- File[" + fileName + "] -->";
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(fileName);

        foreach (XmlNode queryNode in doc.SelectNodes("/xmlconfig/StatisticsQuery"))
        {
          //Only add this node if the classification property from the xml matches what was requested
          string sClassification=queryNode.SelectSingleNode("Classification").InnerText;
          if (sClassification.CompareTo(classification)==0)
          {
            string sQueryTag=queryNode.SelectSingleNode("QueryTag").InnerText;
            string sMenuEntry=queryNode.SelectSingleNode("MenuEntry").InnerText;
          
            string sLink = menuLink + "QueryTag=" + sQueryTag +"&amp;QueryTitle=" + HttpUtility.UrlEncode(sMenuEntry);
          
            alMenuItems.Add(new MenuItem(sMenuEntry,sLink,menuLinkTarget));

            root.AddMenuItem(sMenuEntry,sLink,menuLinkTarget);
          }
        }
      }

      sXML += root.GetXML();

      sXML += "</MetraTech>";

      return sXML;
    }
  }
	
  //Menus are made of MenuItems and MenuGroups encapsulated by these classes(MenuItem and MenuGroup)
  class MenuItem : IComparable
  {
    public string name;
    public string link;
    public string target;

    public MenuItem (string incName, string incLink, string incTarget)
    {
      name = incName;
      link = incLink;
      target = incTarget;
    }

    public int CompareTo (object o) 
    {
      if (!(o is MenuItem)) throw new ArgumentException ("o must be of type 'MenuItem'");

      MenuItem v = (MenuItem) o;
      return String.Compare(name,v.name);
    }

    public string GetXML()
    {
      return "<item><name>" + name + "</name>	<link>" + link + "</link><target>" + target + "</target></item>\n";
    }

  }

  class MenuGroup : IComparable
  {
    public string name;
    public Hashtable mItems = new Hashtable();
    public Hashtable mGroups = new Hashtable();

    public MenuGroup (string incName)
    {
      name = incName;
    }

    public int CompareTo (object o) 
    {
      if (!(o is MenuGroup)) throw new ArgumentException ("o must be of type 'MenuGroup'");

      MenuGroup v = (MenuGroup) o;
      return String.Compare(name,v.name);
    }

    public int AddMenuItem (string incPathName, string incLink, string incTarget)
    {
      //Get the folder name
      int iPos = incPathName.IndexOf("\\");
      if (iPos==-1)
      {
        //Add this to my list of items
        mItems.Add(incPathName,new MenuItem(incPathName, incLink, incTarget));
        return 1;
      }
      else
      {
        string sGroupName = incPathName.Substring(0,iPos);
        string sRemainingPath = incPathName.Substring(iPos+1,incPathName.Length-(iPos+1));
        
        MenuGroup group;
        if (!mGroups.Contains(sGroupName))
        {
          group = new MenuGroup(sGroupName);
          mGroups.Add(sGroupName, group);
        }
        else
        {
          group = (MenuGroup) mGroups[sGroupName];
        }

        return group.AddMenuItem(sRemainingPath, incLink, incTarget);
      }
    }

      public string GetXML()
      {
        string sXML = "";

        Array arMenuItems = Array.CreateInstance( typeof(MenuItem), mItems.Count );;
        mItems.Values.CopyTo(arMenuItems,0);
        Array.Sort(arMenuItems);
        
        foreach (MenuItem item in arMenuItems)
        {
          //sXML += "<item><name>" + item.name + "</name>	<link>" + item.link + "</link><target>" + item.target + "</target></item>\n";
          sXML += item.GetXML();
        }

        Array arMenuGroups = Array.CreateInstance( typeof(MenuGroup), mGroups.Count );;
        mGroups.Values.CopyTo(arMenuGroups,0);
        Array.Sort(arMenuGroups);

        foreach (MenuGroup group in arMenuGroups)
        {
          sXML += "<MenuGroup><name>" + group.name + "</name>\n";
          sXML += group.GetXML();
          sXML += "</MenuGroup>\n";
        }

        return sXML;
      }

  }



}

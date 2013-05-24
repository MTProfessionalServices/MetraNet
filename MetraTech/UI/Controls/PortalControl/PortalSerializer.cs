using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.UI.Controls.Layouts;
using System.IO;
using System.Xml.Serialization;
using System.Web.UI;
using System.Web;
using System.Configuration;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Common;

using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.UI.Controls
{
  public class PortalSerializer
  {
    private MetraTech.Logger mtLog = new Logger("[Dashboard]");

    #region caching methods
    protected DashboardLayout GetCachedLayout(string layoutFile, HttpApplicationState app)
    {
      if ((app == null) || (app.Keys == null) || (app.Keys.Count <= 0))
      {
        return null;
      }

      Dictionary<string, DashboardLayout> layoutDictionary;
      DashboardLayout layout = null;

      try
      {
        layoutDictionary = (Dictionary<string, DashboardLayout>)app.Get("PortalLayouts");
      }
      catch
      {
        return null;
      }

      if (layoutDictionary == null)
      {
        return null;
      }

      if (layoutDictionary.ContainsKey(layoutFile))
      {
        if (!layoutDictionary.TryGetValue(layoutFile, out layout))
        {
          return null;
        }
      }

      return layout;
    }

    protected void SaveLayoutToCache(string layoutFile, DashboardLayout layout, HttpApplicationState app)
    {
      Dictionary<string, DashboardLayout> layoutDictionary = new Dictionary<string, DashboardLayout>();

      if ((app == null) || (app.Keys == null) || (app.Keys.Count <= 0))
      {
        app.Add("PortalLayouts", layoutDictionary);
      }

      layoutDictionary = (Dictionary<string, DashboardLayout>)app.Get("PortalLayouts");
      if (layoutDictionary == null)
      {
        lock (typeof(Dictionary<string, DashboardLayout>))
        {
          layoutDictionary = new Dictionary<string, DashboardLayout>();
        }
      }

      lock (layoutDictionary)
      {
        //update the value in dictionary by resetting it
        if (layoutDictionary.ContainsKey(layoutFile))
        {
          layoutDictionary.Remove(layoutFile);
        }
        layoutDictionary.Add(layoutFile, layout);

        //update the app variable by setting the updated dictionary
        app.Set("PortalLayouts", layoutDictionary);
      }
    }
    #endregion

    #region Serialization methods
    public DashboardLayout Load(string layoutFile)
    {
      DashboardLayout pl = null;

      if (String.IsNullOrEmpty(layoutFile))
      {
        return pl;
      }

      if (!File.Exists(layoutFile))
      {
        return pl;
      }

      using (FileStream fileStream = File.Open(layoutFile, FileMode.Open, FileAccess.Read, FileShare.Read))
      {
        XmlSerializer s = new XmlSerializer(typeof(DashboardLayout));
        pl = (DashboardLayout)s.Deserialize(fileStream);
      }

      return pl;
    }

    public void PopulatePortalFromLayout(
      MetraTech.UI.Controls.Dashboard portal, 
      string layoutFile, Page page)
    {/*
      HttpApplicationState app = page.Application;

      DashboardLayout pl;

      //load from cache only if not in demo mode.  If demo mode, always load from file.
      String isDemoMode = ConfigurationSettings.AppSettings["DemoMode"];

      if (!String.IsNullOrEmpty(isDemoMode) && (isDemoMode.ToLower() == "true"))
      {
        pl = Load(layoutFile);
      }
      //load from cache
      else
      {
        pl = this.GetCachedLayout(layoutFile, app);
        if (pl == null)
        {
          pl = Load(layoutFile);
          SaveLayoutToCache(layoutFile, pl, app);
        }
      }
      if (pl == null)
      {
        return;
      }
      */

      //prepare the service client
      var client = new RepositoryService_LoadInstanceByBusinessKey_Client();
      client.UserName = ((MTPage)page).UI.User.UserName;
      client.Password = ((MTPage)page).UI.User.SessionPassword;
      client.In_entityName = typeof(Core.UI.Dashboard).FullName;


      client.In_businessKey = new Core.UI.DashboardBusinessKey() { Name = portal.Name };
  
      client.Invoke();

      Core.UI.Dashboard dashboard = (Core.UI.Dashboard)client.Out_dataObject;
      if (dashboard == null)
      {
        mtLog.LogWarning("Unable to find dashboard " + portal.Name);
        return;
      }

      DashboardLayout dl = new DashboardLayout();
      dl.CssClass = dashboard.CssClass;
      dl.DashboardID = dashboard.Id;
      dl.Description = dashboard.Description;
      dl.Name = dashboard.BusinessKey.Name;
      dl.Style = dashboard.Style;
      dl.Title = dashboard.Title;
     
      //add columns
      var clientCols = new RepositoryService_LoadInstancesFor_Client();
      clientCols.UserName = ((MTPage)page).UI.User.UserName;
      clientCols.Password = ((MTPage)page).UI.User.SessionPassword;
      clientCols.In_entityName = typeof(Core.UI.Column).FullName;
      clientCols.In_forEntityId = dashboard.Id;
      clientCols.In_forEntityName = typeof(Core.UI.Dashboard).FullName;
      MTList<DataObject> cols = new MTList<DataObject>();
      clientCols.InOut_mtList = cols;

      clientCols.Invoke();

      foreach (Core.UI.Column column in clientCols.InOut_mtList.Items)
      {
        DashboardColumnLayout dcl = new DashboardColumnLayout();
        dcl.CssClass = column.CssClass;
        dcl.Description = column.Description;
        dcl.ID = column.Id;
        dcl.Name = column.Name;
        dcl.Position = column.Position;
        dcl.Style = column.Style;
        dcl.Title = column.Title;
        dcl.Width = column.Width;

        dl.Columns.Add(dcl);

        //retrieve widgets for this column
        var clientWidget = new RepositoryService_LoadInstancesFor_Client();
        clientWidget.UserName = ((MTPage)page).UI.User.UserName;
        clientWidget.Password = ((MTPage)page).UI.User.SessionPassword;
        clientWidget.In_entityName = typeof(Core.UI.Widget).FullName;
        clientWidget.In_forEntityId = column.Id;
        clientWidget.In_forEntityName = typeof(Core.UI.Column).FullName;
        clientWidget.InOut_mtList = new MTList<DataObject>();

        clientWidget.Invoke();

        //iterate through returned widgets and create a layout items for each of them
        foreach (Core.UI.Widget widget in clientWidget.InOut_mtList.Items)
        {
          WidgetLayout wl = new WidgetLayout();
          wl.CssClass = widget.CssClass;
          wl.Description = widget.Description;
          //wl.Height = widget.Height;
          wl.ID = widget.Id;
          wl.Name = widget.Name;
          wl.Path = widget.WidgetPath;
          wl.Position = widget.Position;
          wl.Style = widget.Style;
          wl.Title = widget.Title;
          wl.Type = widget.WidgetType;
          wl.Height = widget.Height;

          dcl.Widgets.Add(wl);

          //get the parameters for the current widget
          var clientParam = new RepositoryService_LoadInstancesFor_Client();
          clientParam.UserName = ((MTPage)page).UI.User.UserName;
          clientParam.Password = ((MTPage)page).UI.User.SessionPassword;
          clientParam.In_entityName = typeof(Core.UI.Parameter).FullName;
          clientParam.In_forEntityId = widget.Id;
          clientParam.In_forEntityName = typeof(Core.UI.Widget).FullName;
          clientParam.InOut_mtList = new MTList<DataObject>();

          clientParam.Invoke();

          //iterate through params and add them
          foreach (Core.UI.Parameter param in clientParam.InOut_mtList.Items)
          {
            WidgetParameterLayout wpl = new WidgetParameterLayout();
            wpl.Description = param.Description;
            wpl.Name = param.Name;
            wpl.Value = param.Value;
            wpl.Required = (param.IsRequired.HasValue) ? param.IsRequired.Value : false;

            wl.Parameters.Add(wpl);
          }
        }
      }

      portal.LoadFromLayout(dl);
      
      //LOADING DUMMY DATA
      /*
      DashboardLayout pl = new DashboardLayout();
      pl.Name = "dashboard1";
      pl.Title = "My Dashboard";
      pl.DashboardID = Guid.NewGuid();

      DashboardColumnLayout col1 = new DashboardColumnLayout();
      col1.Title = "Column One";
      col1.Width = "300px";
      col1.Name = "ColumnOne";
      col1.ID = Guid.NewGuid();
      pl.Columns.Add(col1);

      WidgetLayout wid1 = new WidgetLayout();
      wid1.Title = "Widget One";
      wid1.Position = 1;
      wid1.ID = new Guid();
      wid1.Name = "WidgetOne";
      wid1.Path = "/MetraCare/UserControls/testControl.ascx";
      col1.Widgets.Add(wid1);

      WidgetParameterLayout p1 = new WidgetParameterLayout();
      p1.Name = "ExposedProperty";
      p1.Value = "Hello World";
      wid1.Parameters.Add(p1);

      WidgetLayout wid2 = new WidgetLayout();
      wid2.Title = "Widget Two";
      wid2.Position = 2;
      wid2.ID = new Guid();
      wid2.Name = "WidgetTwo";
      wid2.Path = "/MetraCare/UserControls/testControl.ascx";
      col1.Widgets.Add(wid2);

      WidgetLayout wid3 = new WidgetLayout();
      wid3.Title = "Widget 3";
      wid3.Position = 2;
      wid3.ID = new Guid();
      wid3.Name = "WidgetThree";
      wid3.Path = "/MetraCare/UserControls/testControl.ascx";
      col1.Widgets.Add(wid3);

      WidgetParameterLayout p2 = new WidgetParameterLayout();
      p2.Name = "ExposedProperty";
      p2.Value = "Is that Right??";
      wid2.Parameters.Add(p2);
      
      DashboardColumnLayout col2 = new DashboardColumnLayout();
      col2.Title = "Column 2";
      col2.Width = "300px";
      col2.ID = Guid.NewGuid();
      col2.Name = "ColumnTwo";
      pl.Columns.Add(col2);

      WidgetLayout wid4 = new WidgetLayout();
      wid4.Title = "Widget 4";
      wid4.Position = 1;
      wid4.ID = new Guid();
      wid4.Name = "WidgetFour";
      wid4.Path = "/MetraCare/UserControls/testControl.ascx";
      col2.Widgets.Add(wid4);
      //End Dummy Data
      */

      
    }


    #endregion
  }
}

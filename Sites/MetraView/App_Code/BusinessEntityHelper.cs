using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Web;
using Core.UI;
using Core.UI.Interface;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.UI;
using MetraTech.Interop.MTServerAccess;

/// <summary>
/// BusinessEntityHelper - Used to load Site wide business entities
///                        for configuration and user profile information.
/// </summary>
public static class BusinessEntityHelper
{
  static private MTServerAccessData _superUser;
  static readonly private Object Locker = new object();

  /// <summary>
  /// Loads the sites main configuration, and creates a new basic one if it can't be found.
  /// It loads all config options in a cascading manner.
  /// </summary>
  /// <returns></returns>
  static public Site LoadSiteConfiguration()
  {
    var site = new Site();

    try
    {
      MTServerAccessData su = GetSuperUser(); // We load configuration before the user is logged in so we use su

      // try and load site config based on the virtual directory as the site name
      var loadClient = new RepositoryService_LoadInstanceByBusinessKey_Client
                         {
                           UserName = su.UserName,
                           Password = su.Password,
                           In_entityName = site.GetType().FullName
                         };

      var path = AppDomain.CurrentDomain.FriendlyName;
      path = path.Substring(path.LastIndexOf("/"));
      path = path.Substring(0, path.IndexOf("-"));
      var RootUrl = path;

      var key = new SiteBusinessKey
                  {
                    SiteName = path
                  };
      loadClient.In_businessKey = key;
      loadClient.Invoke();
      site = loadClient.Out_dataObject as Site;

      // if we couldn't load the site, create a new basic site config
      if (site == null)
      {
        site = new Site
                 {
                   SiteBusinessKey = key,
                   Culture = "en-US",
                   Description = "Generated site config...",
                   RootUrl = RootUrl,
                   Theme = "blue",
                   Timezone = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_,
                   LogoImage = "Images/metratech-logo.gif"
                 };
        var createClient = new RepositoryService_SaveInstance_Client
                             {
                               UserName = su.UserName,
                               Password = su.Password,
                               InOut_dataObject = site
                             };
        createClient.Invoke();
        site = createClient.InOut_dataObject as Site;

        var dashboards = new List<IDashboard>();
        dashboards.Add(CreateSiteDashboard(site));
      }
      if (site != null)
      {
        site.Dashboards = LoadSiteDashboards(site);
        site.BillSetting = LoadBillSetting(site);
        site.ProductViewMappings = LoadProductViewMappings(site);
        site.EntryPoints = LoadEntryPoints(site);
      }

      if (site != null && site.BillSetting == null)
      {
        var billSetting = new BillSetting
                            {
                              AllowOnlinePayment = true,
                              AllowSavedReports = true,
                              InlineAdjustments = false,
                              InlineTax = false,
                              AllowSelfCare = true,
                              ShowSecondPassData = false
                            };
        var createClient2 = new RepositoryService_CreateInstanceFor_Client()
                              {
                                In_forEntityId = site.Id,
                                In_forEntityName = site.GetType().FullName,
                                UserName = su.UserName,
                                Password = su.Password,
                                InOut_dataObject = billSetting
                              };

        createClient2.Invoke();


        site.BillSetting = createClient2.InOut_dataObject as BillSetting;
      }
    }
    catch (Exception exp)
    {
      MetraTech.UI.Tools.Utils.CommonLogger.LogException("Unable to get site configuration.  You probably need to start ActivityServices. *** net start activityservices ***", exp);
    }

    return site;
  }

  /// <summary>
  /// Loads all product view mappings related to the site
  /// </summary>
  /// <param name="site"></param>
  /// <returns></returns>
  private static List<IProductViewMapping> LoadProductViewMappings(Site site)
  {
    var pvMappings = new MTList<DataObject>();

    MTServerAccessData su = GetSuperUser();

    // try and load site config based on the virtual directory as the site name
    var loadClient = new RepositoryService_LoadInstancesFor_Client
                        {
                          UserName = su.UserName,
                          Password = su.Password,
                          In_forEntityName = site.GetType().FullName,
                          In_forEntityId = site.Id,
                          In_entityName = typeof(ProductViewMapping).FullName,
                          InOut_mtList = pvMappings
                        };

    loadClient.Invoke();
    pvMappings = loadClient.InOut_mtList;

    return pvMappings.Items.Select(pv => pv as ProductViewMapping).Cast<IProductViewMapping>().ToList(); 
  }

  /// <summary>
  /// Loads all entry points related to the site
  /// </summary>
  /// <param name="site"></param>
  /// <returns></returns>
  private static List<IEntryPoint> LoadEntryPoints(Site site)
  {
    var entryPoints = new MTList<DataObject>();

    MTServerAccessData su = GetSuperUser();

    // Load entry points
    var loadClient = new RepositoryService_LoadInstancesFor_Client
    {
      UserName = su.UserName,
      Password = su.Password,
      In_forEntityName = site.GetType().FullName,
      In_forEntityId = site.Id,
      In_entityName = typeof(EntryPoint).FullName,
      InOut_mtList = entryPoints
    };

    loadClient.Invoke();
    entryPoints = loadClient.InOut_mtList;

    return entryPoints.Items.Select(ep => ep as EntryPoint).Cast<IEntryPoint>().ToList();
  }

  /// <summary>
  /// Loads all dashboards related to the site.
  /// </summary>
  /// <param name="site"></param>
  /// <returns></returns>
  static public List<IDashboard> LoadSiteDashboards(Site site)
  {
    var dashboards = new MTList<DataObject>();

    MTServerAccessData su = GetSuperUser();

    // try and load site config based on the virtual directory as the site name
    var loadClient = new RepositoryService_LoadInstancesFor_Client
                      {
                        UserName = su.UserName,
                        Password = su.Password,
                        In_forEntityName = site.GetType().FullName,
                        In_forEntityId = site.Id,
                        In_entityName = typeof(Dashboard).FullName,
                        InOut_mtList = dashboards
                      };

    loadClient.Invoke();
    dashboards = loadClient.InOut_mtList;

    var returnDasboards = new List<IDashboard>();
    foreach(var d in dashboards.Items)
    {
      // load columns
      var dashboard = d as Dashboard;
      if (dashboard != null)
      {
        dashboard.Columns = LoadColumns(dashboard);
        returnDasboards.Add(dashboard);
      }
    }

    return returnDasboards;  
  }

  /// <summary>
  /// Loads all columns related to the dashboard.
  /// </summary>
  /// <param name="dashboard"></param>
  /// <returns></returns>
  private static List<IColumn> LoadColumns(Dashboard dashboard)
  {
    var columns = new MTList<DataObject>();
      columns.SortCriteria.Add(new SortCriteria("Position", SortType.Ascending ));
    MTServerAccessData su = GetSuperUser();

    // try and load site config based on the virtual directory as the site name
    var loadClient = new RepositoryService_LoadInstancesFor_Client
                    {
                      UserName = su.UserName,
                      Password = su.Password,
                      In_forEntityName = dashboard.GetType().FullName,
                      In_forEntityId = dashboard.Id,
                      In_entityName = typeof(Column).FullName,
                      InOut_mtList = columns
                    };

    loadClient.Invoke();
    columns = loadClient.InOut_mtList;

    var returnColumns = new List<IColumn>();
    foreach (var c in columns.Items)
    {
      // load widgets
      var col = c as Column;
      if (col != null)
      {
        col.Widgets = LoadWidgets(col);
        returnColumns.Add(col);
      }
    }

    return returnColumns;  
  }

  /// <summary>
  /// Loads all widgets related to a column
  /// </summary>
  /// <param name="column"></param>
  /// <returns></returns>
  private static List<IWidget> LoadWidgets(Column column)
  {
    var widgets = new MTList<DataObject>();

    MTServerAccessData su = GetSuperUser();

    // try and load site config based on the virtual directory as the site name
    var loadClient = new RepositoryService_LoadInstancesFor_Client
                      {
                        UserName = su.UserName,
                        Password = su.Password,
                        In_forEntityName = column.GetType().FullName,
                        In_forEntityId = column.Id,
                        In_entityName = typeof(Widget).FullName,
                        InOut_mtList = widgets
                      };

    loadClient.Invoke();
    widgets = loadClient.InOut_mtList;

    var returnWidgets = new List<IWidget>();
    foreach (var w in widgets.Items)
    {
      // load parameters
      var widget = w as Widget;
      if (widget != null)
      {
        widget.Parameters = LoadParameters(widget);
        returnWidgets.Add(widget);
      }
    }

    return returnWidgets; 
  }

  /// <summary>
  /// Loads all parameters related to a widget.
  /// </summary>
  /// <param name="widget"></param>
  /// <returns></returns>
  private static List<IParameter> LoadParameters(Widget widget)
  {
    var paramaters = new MTList<DataObject>();

    MTServerAccessData su = GetSuperUser();

    // try and load site config based on the virtual directory as the site name
    var loadClient = new RepositoryService_LoadInstancesFor_Client
                      {
                        UserName = su.UserName,
                        Password = su.Password,
                        In_forEntityName = widget.GetType().FullName,
                        In_forEntityId = widget.Id,
                        In_entityName = typeof(Parameter).FullName,
                        InOut_mtList = paramaters
                      };

    loadClient.Invoke();
    paramaters = loadClient.InOut_mtList;

    return paramaters.Items.Select(p => p as Parameter).Cast<IParameter>().ToList(); 
  }

  /// <summary>
  /// Loads bill settings related to a site used for bill presentation config.
  /// </summary>
  /// <param name="site"></param>
  /// <returns></returns>
  static public BillSetting LoadBillSetting(Site site)
  {
    MTServerAccessData su = GetSuperUser();
    var billSetting = new BillSetting();

    // load bill settings
    var loadClient = new RepositoryService_LoadInstanceFor_Client
                       {
                         UserName = su.UserName,
                         Password = su.Password,
                         In_entityName = billSetting.GetType().FullName,
                         In_forEntityId = site.Id,
                         In_forEntityName = site.GetType().FullName
                      };

    loadClient.Invoke();
    billSetting = loadClient.Out_dataObject as BillSetting;

    return billSetting;
  }

  /// <summary>
  /// Loads the profile associated with the account or creates a basic default one if not found.
  /// </summary>
  /// <param name="acc"></param>
  /// <returns></returns>
  static public UserProfile LoadUserProfile(Account acc)
  {
    if (acc == null)
      return null;

    MTServerAccessData su = GetSuperUser();
    var userProfile = new UserProfile();

    var accountDef = new AccountDef();
    if (acc._AccountID != null) accountDef.AccountId = (int)acc._AccountID;

    var profiles = new MTList<DataObject>();

    // load bill settings
    var loadClient = new RepositoryService_LoadInstancesForMetranetEntity_Client
    {
      UserName = su.UserName,
      Password = su.Password,
      In_entityName = userProfile.GetType().FullName,
      In_metranetEntity = accountDef,
      InOut_mtList = profiles
    };

    loadClient.Invoke();
    profiles = loadClient.InOut_mtList;

    if(profiles == null || profiles.Items.Count == 0)
    {
      if (acc._AccountID != null)
      {
        var newProfile = new UserProfile
                           {
                             AccountId = acc._AccountID,
                             Culture = Thread.CurrentThread.CurrentUICulture.ToString(),
                             Theme = SiteConfig.Settings.Theme
                           };
        // no profile found, let's create a default one...
        var createClient = new RepositoryService_SaveInstance_Client
                             {
                               UserName = su.UserName,
                               Password = su.Password,
                               InOut_dataObject = newProfile
                             };
        createClient.Invoke();
        return createClient.InOut_dataObject as UserProfile;
      }
    }

    if (profiles != null) return profiles.Items.Select(p => p as UserProfile).FirstOrDefault();

    return null;
  }

  /// <summary>
  ///   Get system credentials to call service before login
  ///   Since it is static we use double check locking just in case...
  /// </summary>
  /// <returns></returns>
  private static MTServerAccessData GetSuperUser()
  {
    if (_superUser == null)
    {
      lock (Locker)
      {
        if (_superUser == null)
        {
          var sa = new MTServerAccessDataSet();
          sa.Initialize();
          _superUser = sa.FindAndReturnObject("SuperUser");
        }
      }
    }
    return _superUser;
  }

  public static Dashboard CreateSiteDashboard(Site site)
  {

      MTServerAccessData su = GetSuperUser();

      var dashboardKey = new DashboardBusinessKey
      {
          Name = String.Format("{0}_Dashboard", site.SiteBusinessKey.SiteName.Remove(0, 1))
      };
      var dashboard = new Dashboard
      {
          DashboardBusinessKey = dashboardKey,
      };
      var createDashboardClient = new RepositoryService_CreateInstanceFor_Client
      {
          UserName = su.UserName,
          Password = su.Password,
          In_forEntityName = site.GetType().FullName,
          In_forEntityId = site.Id,
          InOut_dataObject = dashboard
      };
      createDashboardClient.Invoke();
      dashboard = createDashboardClient.InOut_dataObject as Dashboard;

      var columns = new List<IColumn>();
      if (dashboard != null)
      {
          columns.Add(CreateDashboardColumn(dashboard, "Column1", 1, DashboardColumnWidth.Small));
          columns.Add(CreateDashboardColumn(dashboard, "Column2", 2, DashboardColumnWidth.Small));
          columns.Add(CreateDashboardColumn(dashboard, "Column3", 3, DashboardColumnWidth.Small));
          // Add columns to dashboard
          dashboard.Columns = columns;

          var widgets = new List<IWidget>();
          if (dashboard.Columns.Count > 0)
          {
              // Add widgets to columns
              widgets.Add(CreateColumnWidget(dashboard.Columns[0] as Column, "BillAdndPayments", 1, "UserControls/BillAndPayments.ascx", String.Empty));
              widgets.Add(CreateColumnWidget(dashboard.Columns[0] as Column, "MyReports", 2, "UserControls/MyReports.ascx", Resources.Dashboard.TEXT_MY_REPORTS));
              dashboard.Columns[0].Widgets = widgets;
              widgets.Clear();

              widgets.Add(CreateColumnWidget(dashboard.Columns[1] as Column, "UsageGraph", 1, "UserControls/UsageGraph.ascx", Resources.Dashboard.TEXT_USAGE_BY_DEPARTMENT));
              widgets.Add(CreateColumnWidget(dashboard.Columns[1] as Column, "UsageByProductGraph", 2, "UserControls/ProductUsageGraph.ascx", Resources.Dashboard.TEXT_USAGE_BY_PRODUCT));
              dashboard.Columns[0].Widgets = widgets;
              widgets.Clear();

              widgets.Add(CreateColumnWidget(dashboard.Columns[2] as Column, "AccountInfo", 1, "UserControls/PayerInfo.ascx", Resources.Dashboard.TEXT_ACCOUNT_INFORMATION));
              widgets.Add(CreateColumnWidget(dashboard.Columns[2] as Column, "Subscriptions", 2, "UserControls/Subscriptions.ascx", Resources.Dashboard.TEXT_MY_SUBSCRIPTIONS));
              dashboard.Columns[0].Widgets = widgets;
          }
      }

      return dashboard;
  }

  public static Column CreateDashboardColumn(Dashboard dashboard, string columnName, int columnPosition, DashboardColumnWidth columnWidth)
  {
      MTServerAccessData su = GetSuperUser();
      var column = new Column
      {
          Name = columnName,
          Position = columnPosition,
          Width = columnWidth
      };
      var createColumnClient = new RepositoryService_CreateInstanceFor_Client
      {
          UserName = su.UserName,
          Password = su.Password,
          In_forEntityName = typeof(Dashboard).FullName,
          In_forEntityId = dashboard.Id,
          InOut_dataObject = column
      };
      createColumnClient.Invoke();
      column = createColumnClient.InOut_dataObject as Column;
      return column;
  }

  public static Widget CreateColumnWidget(Column column, string widgetName, int widgetPosition, string widgetPath, string widgetTitle)
  {
      MTServerAccessData su = GetSuperUser();
      var widget = new Widget
      {
          Name = widgetName,
          Position = widgetPosition,
          WidgetPath = widgetPath,
          Title = widgetTitle,
          Parameters = new List<IParameter>()

      };
      var createWidgetClient = new RepositoryService_CreateInstanceFor_Client
      {
          UserName = su.UserName,
          Password = su.Password,
          In_forEntityName = typeof(Column).FullName,
          In_forEntityId = column.Id,
          InOut_dataObject = widget
      };
      createWidgetClient.Invoke();
      widget = createWidgetClient.InOut_dataObject as Widget;

      return widget;
  }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using Microsoft.Web.Infrastructure;

[assembly: WebActivator.PostApplicationStartMethod(typeof(ASP.AppStart_RegisterRoutesAreasFilters), "Start")]

namespace ASP
{
  public static class AppStart_RegisterRoutesAreasFilters
  {
    public static void Start()
    {
      AreaRegistration.RegisterAllAreas();
      RegisterGlobalFilters(GlobalFilters.Filters);
      RegisterRoutes(RouteTable.Routes);
    }

    public static void RegisterGlobalFilters(GlobalFilterCollection filters)
    {
      filters.Add(new HandleErrorAttribute());
    }

    public static void RegisterRoutes(RouteCollection routes)
    {
      routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
      routes.MapRoute(
        "Default",                                                                // Route name
        "{controller}/{action}/{id}",                                             // URL with parameters
        new { controller = "Home", action = "Index", id = UrlParameter.Optional } // Parameter defaults
        );
    }

  }

}
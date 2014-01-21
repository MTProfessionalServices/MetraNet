using System.Web.Routing;

public static class LayoutHelpers
{
	public static string GetLayout(RouteData data)
	{
    if (CheckController(data, "ExpressionEngine"))
      return "~/Views/Shared/_Layout.cshtml";

    return "~/Views/Shared/_PageLayout.cshtml";
	}

  private static bool CheckController(RouteData data, string controllerName)
  {
    return ((string)data.Values["controller"]).ToUpperInvariant() == controllerName.ToUpperInvariant();
  }
}
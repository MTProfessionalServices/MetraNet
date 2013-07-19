using System.Web.Routing;

public static class LayoutHelpers
{
	public static string GetLayout(RouteData data)
	{
		if ((string) data.Values["controller"] == "SpecCharacteristics" || (string) data.Values["controller"] == "Account")
			return "~/Views/Shared/_PageLayout.cshtml";

		return "~/Views/Shared/_Layout.cshtml";
	}
}
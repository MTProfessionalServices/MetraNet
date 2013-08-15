using System.Web.Mvc;

namespace ASP.Controllers
{
  public class ExpressionEngineController : MTController
  {
    public ActionResult Index()
    {
      Title = "Expression Engine Test Page";

      var entitiesTree = new EntitiesTree();
      entitiesTree.ElementId = "entitiesTree";
      entitiesTree.MetadataAddress = string.Concat(System.Web.HttpContext.Current.Request.ApplicationPath, "/AjaxServices/Metadata.aspx");

      entitiesTree.EntityBaseTypes.Add("ExtensibleEntity");

      ViewBag.EntitiesTree = entitiesTree;

      return View();
    }

  }
}

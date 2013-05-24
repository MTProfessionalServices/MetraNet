using System;
using System.Linq;
using System.Linq.Expressions;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.WebPages;

namespace MvcApplication1.Helpers
{
  public static class LabelExtensions
  {
    public static MvcHtmlString LabelFor<TModel, TValue>(this HtmlHelper<TModel> html, Expression<Func<TModel, TValue>> expression, object htmlAttributes)
    {
      return LabelFor(html, expression, new RouteValueDictionary(htmlAttributes));
    }

    public static MvcHtmlString LabelFor<TModel, TProperty>(this HtmlHelper<TModel> htmlHelper, Expression<Func<TModel, TProperty>> ex, Func<object, HelperResult> template)
    {
      var htmlFieldName = ExpressionHelper.GetExpressionText(ex);
      var propertyName = htmlFieldName.Split('.').Last();
      var label = new TagBuilder("label");
      label.Attributes["for"] = TagBuilder.CreateSanitizedId(htmlHelper.ViewContext.ViewData.TemplateInfo.GetFullHtmlFieldName(htmlFieldName));
      label.InnerHtml = string.Format(
          "{0} {1}",
          propertyName,
          template(null).ToHtmlString()
      );
      return MvcHtmlString.Create(label.ToString());
    }
  }
}
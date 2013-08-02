using System;
using System.Web;
using System.Web.Mvc;
using MetraTech.UI.Common;

/// <summary>
/// Summary description for MvcHtmlHelpers
/// </summary>
public static class HtmlHelpers
{
  /// <summary>
  /// Append JavaScript to bottom of the page
  /// </summary>
  /// <param name="html"></param>
  /// <param name="htmlString">content that will be appended</param>
  /// <returns>nothing</returns>
  public static string AppendToJavaScriptSection(this HtmlHelper html, IHtmlString htmlString)
  {
    if (htmlString == null) throw new ArgumentNullException("htmlString");

    if (HttpContext.Current.Items.Contains(@Constants.JavaScriptSection))
      HttpContext.Current.Items.Add(@Constants.JavaScriptSection, htmlString.ToHtmlString());
    else
      HttpContext.Current.Items[@Constants.JavaScriptSection] += htmlString.ToHtmlString();

    return string.Empty;
  }

  /// <summary>
  /// Append Styles to header section
  /// </summary>
  /// <param name="html"></param>
  /// <param name="htmlString">content that will be appended</param>
  /// <returns>nothing</returns>
  public static string AppendToStyleSection(this HtmlHelper html, IHtmlString htmlString)
  {
    if (htmlString == null) throw new ArgumentNullException("htmlString");

    if (HttpContext.Current.Items.Contains(@Constants.StyleSection))
      HttpContext.Current.Items.Add(@Constants.StyleSection, htmlString.ToHtmlString());
    else
      HttpContext.Current.Items[@Constants.StyleSection] += htmlString.ToHtmlString();

    return string.Empty;
  }
}
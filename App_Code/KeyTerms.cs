using System;
using System.Text.RegularExpressions;
using System.Web;

public class KeyTerms
{

  static readonly Regex RegexKey = new Regex(@"\[[^\]]*\]", RegexOptions.IgnoreCase | RegexOptions.Compiled);

  /// <summary>
  /// Replace KeyTerm tags with the localized resource string
  /// </summary>
  /// <param name="str"></param>
  /// <returns></returns>
  static public string ProcessKeyTerms(string str)
  {
    // Step 1:  Use a compiled Regex to pull out possible [key] values in a collection
    MatchCollection mc = RegexKey.Matches(str);

    // Step 2:  Replace KeyTerm entries in the string
    if (mc.Count > 0)
    {
      string replaceKey;
      foreach (Match m in mc)
      {
        replaceKey = m.ToString();
        string newKey = replaceKey.Substring(1, replaceKey.Length - 2);
        try
        {
          newKey = HttpContext.GetGlobalResourceObject("KeyTerms", newKey).ToString();
        }
        catch (Exception)
        {
          newKey = replaceKey;
        }

        if (!String.IsNullOrEmpty(newKey))
        {
          str = str.Replace(replaceKey, newKey);
        }
      }
    }
    return str;
  }

}
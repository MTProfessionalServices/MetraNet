namespace MetraTech.ICE.ExpressionEngine
{
  using System;
  using System.Collections.Generic;
  using System.Text;
  using System.Text.RegularExpressions;
  using System.Xml;
  using System.IO;

  public static class RefactorHelper
  {
    #region MTSQL Property Helpers

    private static Regex GetMtsqlPropertyRegex(string propertyName)
    {
      var pattern = string.Format("@{0}([^a-zA-Z0-9_]|$)", propertyName);
      return new Regex(pattern, RegexOptions.IgnoreCase | RegexOptions.Singleline);
    }
    public static bool IsMtsqlPropertyMatch(string propertyName, string mtsql)
    {
      var regex = GetMtsqlPropertyRegex(propertyName);
      return regex.IsMatch(mtsql);
    }
    public static string ReplaceMtsqlProperty(string oldPropertyName, string newPropertyName, string mtsql)
    {
      var regex = GetMtsqlPropertyRegex(oldPropertyName);
      var result = regex.Replace(mtsql, "@" + newPropertyName);
      return result;
    }
    #endregion

    #region MTSQL EnumSpace Helpers
    public static Regex GetMtsqlEnumSpaceRegex(string enumSpace)
    {
      var pattern = string.Format("#{0}/", enumSpace);
      return new Regex(pattern, RegexOptions.IgnoreCase);
    }
    public static bool IsMtsqlEnumSpaceMatch(string enumSpace, string mtsql)
    {
      var regex = GetMtsqlEnumSpaceRegex(enumSpace);
      return regex.IsMatch(mtsql);
    }

    public static string ReplaceMtsqlEnumSpace(string oldEnumSpace, string newEnumSpace, string mtsql)
    {
      var regex = GetMtsqlEnumSpaceRegex(oldEnumSpace);
      return regex.Replace(mtsql, newEnumSpace);
    }
    #endregion

    #region MTSQL EnumType Helpers
    public static Regex GetMtsqlEnumTypeRegex(string enumSpace, string enumType)
    {
      var pattern = string.Format("#{0}/{1}#", enumSpace, enumType);
      return new Regex(pattern, RegexOptions.IgnoreCase);
    }
    public static bool IsMtsqlEnumTypeMatch(string enumSpace, string enumType, string mtsql)
    {
      var regex = GetMtsqlEnumTypeRegex(enumSpace, enumType);
      return regex.IsMatch(mtsql);
    }

    public static string ReplaceMtsqlEnumType(string enumSpace, string oldEnumType, string newEnumType, string mtsql)
    {
      var regex = GetMtsqlEnumTypeRegex(enumSpace, oldEnumType);
      return regex.Replace(mtsql, newEnumType);
    }
    #endregion

    #region XML File Helpers
    public static List<XmlNode> GetInnerXmlMatchs(string filePath, string oldInnerText)
    {
      var nodeNameMatches = new List<XmlNode>();

      var doc = new XmlDocument();
      doc.Load(filePath);
      var nodes = new List<XmlNode>();
      AppendChildNodes(nodes, doc.FirstChild);

      foreach (var node in nodes)
      {
        if (node.InnerXml.Equals(oldInnerText, StringComparison.InvariantCultureIgnoreCase))
          nodeNameMatches.Add(node);
      }

      return nodeNameMatches;
    }

    private static void AppendChildNodes(List<XmlNode> nodes, XmlNode node)
    {
      nodes.Add(node);

      if (node == null || !node.HasChildNodes) 
        return;
      foreach (XmlNode childNode in node.ChildNodes)
        AppendChildNodes(nodes, childNode);
    }
    #endregion

    #region C# Helpers
    public static void Foo(string dirPath)
    {
      var dirInfo = new DirectoryInfo(dirPath);
      var fileInfos = dirInfo.GetFiles("*.cs", SearchOption.AllDirectories);
      foreach (var fileInfo in fileInfos)
      {
        
      }
    }
    public static List<string> MatchOrReplaceCSharp(string filePath, Regex regex, string newValue=null)
    {
      var matches = new List<string>();
      var lines = File.ReadAllLines(filePath);
      var sb = new StringBuilder();
      for (int index = 0; index < lines.Length; index++)
      {
        var line = lines[index];
        if (regex.IsMatch(line))
        {
          matches.Add(line);
          if (newValue != null)
            regex.Replace(line, newValue);
        }
      }

      if (newValue != null)
        File.WriteAllText(filePath, sb.ToString());

      return matches;
    }
    #endregion

    public static string[] SplitStringIntoLines(string stringToSplit)
    {
      return stringToSplit.Split(new string[] { "\r\n", "\n" }, StringSplitOptions.None);
    }
  }
}

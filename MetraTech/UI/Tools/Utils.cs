using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Reflection;
using Microsoft.Win32;
using System.Xml;
using System.Xml.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.InteropServices;
using System.Globalization;
using System.Web;
using System.Collections;
using System.ComponentModel;
using MetraTech.DataAccess;
using MetraTech.Interop.Rowset;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using System.Security.Cryptography;
using System.Collections.Generic;

namespace MetraTech.UI.Tools
{
  public class ObjectFilter
  {
    private object field;

    public object Field
    {
      get { return field; }
      set { field = value; }
    }

    private MTOperatorType _operator;

    public MTOperatorType Operator
    {
      get { return _operator; }
      set { _operator = value; }
    }
	
    private object fieldValue;

    public object FieldValue
    {
      get { return fieldValue; }
      set { fieldValue = value; }
    }
  }

  /// <summary>
  /// Utils class which contains a set of common utility classes for 
  /// Formatting strings
  /// Reflection Helpers
  /// Object Serialization
  /// </summary>
  public class Utils
  {
    #region MetraTech Specific (Common Logger, MTErrorMessage)
    public readonly static MetraTech.Logger CommonLogger = new MetraTech.Logger("[MetraTech.UI.Tools]");

    /// <summary>
    /// Takes in a MetraTech error code and returns a detailed string.
    /// </summary>
    /// <param name="errCodeString"></param>
    /// <returns></returns>
    public static string MTErrorMessage(string errCodeString)
    {
      object errCode;
      if (errCodeString.StartsWith("0x"))
      {
        errCode = int.Parse(errCodeString.Substring(2), System.Globalization.NumberStyles.HexNumber);
      }
      else
      {
        errCode = errCodeString;
      }
      object rcd = CreateComponentFromProgID("MetraTech.RCD.1");
      object detailedError = CallMethodInstance(rcd, "ErrorMessage", new object[] { errCode });
      return detailedError.ToString();
    }
    #endregion

    #region SQL Helpers
    public static int ExecuteSQL(string sql)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTStatement stmt = conn.CreateStatement(sql))
          {
              return stmt.ExecuteNonQuery();
          }
      }
    }

    public static System.Data.DataSet ExecuteSQLQuery(string sql)
    {
      IMTSQLRowset rowset = new MTSQLRowset();
      rowset.Init("\\dummy");
      rowset.SetQueryString(sql);
      rowset.Execute();
      return Converter.GetDataSetFromRowset(rowset);
    }

    #endregion

    #region String Helper Functions

    /// <summary>
    /// Replaces and  and Quote characters to HTML safe equivalents.
    /// </summary>
    /// <param name="Html">HTML to convert</param>
    /// <returns>Returns an HTML string of the converted text</returns>
    public static string FixHTMLForDisplay(string Html)
    {
      Html = Html.Replace("<", "&lt;");
      Html = Html.Replace(">", "&gt;");
      Html = Html.Replace("\"", "&quot;");
      return Html;
    }

    /// <summary>
    /// Strips HTML tags out of an HTML string and returns just the text.
    /// </summary>
    /// <param name="Html">Html String</param>
    /// <returns></returns>
    public static string StripHtml(string Html)
    {
      Html = Regex.Replace(Html, @"<(.|\n)*?>", string.Empty);
      Html = Html.Replace("\t", " ");
      Html = Html.Replace("\r\n", "");
      Html = Html.Replace("   ", " ");
      return Html.Replace("  ", " ");
    }

    /// <summary>
    /// Fixes a plain text field for display as HTML by replacing carriage returns 
    /// with the appropriate br and p tags for breaks.
    /// </summary>
    /// <param name="HtmlText">Input string</param>
    /// <returns>Fixed up string</returns>
    public static string DisplayMemo(string HtmlText)
    {
      HtmlText = HtmlText.Replace("\r\n", "\r");
      HtmlText = HtmlText.Replace("\n", "\r");
      HtmlText = HtmlText.Replace("\r\r", "<p>");
      HtmlText = HtmlText.Replace("\r", "<br>");
      return HtmlText;
    }
    /// <summary>
    /// Method that handles handles display of text by breaking text.
    /// Unlike the non-encoded version it encodes any embedded HTML text
    /// </summary>
    /// <param name="Text"></param>
    /// <returns></returns>
    public static string DisplayMemoEncoded(string Text)
    {
      bool PreTag = false;
      if (Text.IndexOf("<pre>") > -1)
      {
        Text = Text.Replace("<pre>", "__pre__");
        Text = Text.Replace("</pre>", "__/pre__");
        PreTag = true;
      }

      // *** fix up line breaks into <br><p>
      Text = Utils.DisplayMemo(HttpUtility.HtmlEncode(Text));

      if (PreTag)
      {
        Text = Text.Replace("__pre__", "<pre>");
        Text = Text.Replace("__/pre__", "</pre>");
      }

      return Text;
    }

    /// <summary>
    /// Expands links into HTML hyperlinks inside of text or HTML.
    /// </summary>
    /// <param name="Text">The text to expand</param>
    /// <param name="Target">Target frame where output is displayed</param>
    /// <returns></returns>
    public static string ExpandUrls(string Text, string Target)
    {
      ExpandUrlsParser Parser = new ExpandUrlsParser();
      Parser.Target = Target;
      return Parser.ExpandUrls(Text);
    }

    public static string ExpandUrls(string Text)
    {
      return ExpandUrls(Text, null);
    }

    public static bool IsNumeric(string text)
    {
      if (String.IsNullOrEmpty(text))
      {
        return false;
      }

      int number;

      bool result = Int32.TryParse(text, out number);

      return result;
    }

    /// <summary>
    /// Extracts a string from between a pair of delimiters. Only the first 
    /// instance is found.
    /// </summary>
    /// <param name="Source">Input String to work on</param>
    /// <param name="BeginDelim">Beginning delimiter</param>
    /// <param name="EndDelim">ending delimiter</param>
    /// <param name="CaseInSensitive">Determines whether the search for delimiters is case sensitive</param>
    /// <param name="AllowMissingEndDelimiter"></param>
    /// <returns>Extracted string or ""</returns>
    public static string ExtractString(string Source, string BeginDelim, string EndDelim, bool CaseInSensitive, bool AllowMissingEndDelimiter)
    {
      int At1, At2;

      if (Source == null || Source.Length < 1)
        return "";

      if (CaseInSensitive)
      {
        At1 = Source.IndexOf(BeginDelim);
        At2 = Source.IndexOf(EndDelim, At1 + BeginDelim.Length);
      }
      else
      {
        string Lower = Source.ToLower();
        At1 = Lower.IndexOf(BeginDelim.ToLower());
        At2 = Lower.IndexOf(EndDelim.ToLower(), At1 + BeginDelim.Length);
      }

      if (AllowMissingEndDelimiter && At2 == -1)
        return Source.Substring(At1 + BeginDelim.Length);

      if (At1 > -1 && At2 > 1)
        return Source.Substring(At1 + BeginDelim.Length, At2 - At1 - BeginDelim.Length);

      return "";
    }

    /// <summary>
    /// Extracts a string from between a pair of delimiters. Only the last 
    /// instance is found.
    /// </summary>
    /// <param name="Source"></param>
    /// <param name="BeginDelim"></param>
    /// <param name="EndDelim"></param>
    /// <param name="CaseInSensitive"></param>
    /// <param name="AllowMissingEndDelimiter"></param>
    /// <returns></returns>
    public static string ExtractStringLastInstance(string Source, string BeginDelim, string EndDelim, bool CaseInSensitive, bool AllowMissingEndDelimiter)
    {
      int At1, At2;

      if (Source == null || Source.Length < 1)
        return "";

      if (CaseInSensitive)
      {
          At2 = Source.LastIndexOf(EndDelim);
          At1 = Source.LastIndexOf(BeginDelim, (At2 != -1) ? At2 - EndDelim.Length : Source.Length);
      }
      else
      {
        string Lower = Source.ToLower();
        At2 = Lower.LastIndexOf(EndDelim.ToLower());
        At1 = Lower.LastIndexOf(BeginDelim.ToLower(), (At2 != -1) ? At2 - EndDelim.Length : Source.Length);
      }

      if (AllowMissingEndDelimiter && At2 == -1)
        return Source.Substring(At1 + BeginDelim.Length);

      if (At1 > -1 && At2 > BeginDelim.Length)
        return Source.Substring(At1 + BeginDelim.Length, At2 - At1 - BeginDelim.Length);

      return "";
    }
    /// <summary>
    /// Extracts a string from between a pair of delimiters. Only the first
    /// instance is found.
    /// <seealso>Class Utils</seealso>
    /// </summary>
    /// <param name="Source">
    /// Input String to work on
    /// </param>
    /// <param name="BeginDelim"></param>
    /// <param name="EndDelim">
    /// ending delimiter
    /// </param>
    /// <param name="CaseInSensitive"></param>
    /// <returns>String</returns>
    public static string ExtractString(string Source, string BeginDelim, string EndDelim, bool CaseInSensitive)
    {
      return ExtractString(Source, BeginDelim, EndDelim, false, false);
    }

    /// <summary>
    /// Extracts a string from between a pair of delimiters. Only the last 
    /// instance is found. Search is case insensitive.
    /// </summary>
    /// <param name="Source">
    /// Input String to work on
    /// </param>
    /// <param name="BeginDelim">
    /// Beginning delimiter
    /// </param>
    /// <param name="EndDelim">
    /// ending delimiter
    /// </param>
    /// <returns>Extracted string or ""</returns>
    public static string ExtractStringLastInstance(string Source, string BeginDelim, string EndDelim)
    {
      return Utils.ExtractStringLastInstance(Source, BeginDelim, EndDelim, false, false);
    }

    /// <summary>
    /// Extracts a string from between a pair of delimiters. Only the first 
    /// instance is found. Search is case insensitive.
    /// </summary>
    /// <param name="Source">
    /// Input String to work on
    /// </param>
    /// <param name="BeginDelim">
    /// Beginning delimiter
    /// </param>
    /// <param name="EndDelim">
    /// ending delimiter
    /// </param>
    /// <returns>Extracted string or ""</returns>
    public static string ExtractString(string Source, string BeginDelim, string EndDelim)
    {
      return Utils.ExtractString(Source, BeginDelim, EndDelim, false, false);
    }

    /// <summary>
    /// Determines whether a string is empty (null or zero length)
    /// </summary>
    /// <param name="String">Input string</param>
    /// <returns>true or false</returns>
    public static bool Empty(string String)
    {
      if (String == null || String.Trim().Length == 0)
        return true;

      return false;
    }

    /// <summary>
    /// Determines wheter a string is empty (null or zero length)
    /// </summary>
    /// <param name="StringValue">Input string (in object format)</param>
    /// <returns>true or false</returns>
    public static bool Empty(object StringValue)
    {
      string String = (string)StringValue;
      if (String == null || String.Trim().Length == 0)
        return true;

      return false;
    }

    /// <summary>
    /// Return a string in proper Case format
    /// </summary>
    /// <param name="Input"></param>
    /// <returns></returns>
    public static string ProperCase(string Input)
    {
      return System.Threading.Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(Input);
    }

    /// <summary>
    /// Returns an abstract of the provided text by returning up to Length characters
    /// of a text string. If the text is truncated a ... is appended.
    /// </summary>
    /// <param name="Text">Text to abstract</param>
    /// <param name="Length">Number of characters to abstract to</param>
    /// <returns>string</returns>
    public static string TextAbstract(string Text, int Length)
    {
      if (Text.Length <= Length)
        return Text;

      Text = Text.Substring(0, Length);

      Text = Text.Substring(0, Text.LastIndexOf(" "));
      return Text + "...";
    }

    /// <summary>
    /// Creates an Abstract from an HTML document. Strips the 
    /// HTML into plain text, then creates an abstract.
    /// </summary>
    /// <param name="Html"></param>
    /// <param name="Length"></param>
    /// <returns></returns>
    public static string HtmlAbstract(string Html, int Length)
    {
      return TextAbstract(StripHtml(Html), Length);
    }

    /// <summary>
    /// Encodes the <paramref name="val"/> for JavaScript
    /// </summary>
    /// <param name="val">string to encode</param>
    /// <returns></returns>
    public static string EncodeForJavaScript(string val)
    {
        if (string.IsNullOrEmpty(val))
            return val;
        return val.EncodeForJavaScript();
    }

    /// <summary>
    /// Encodes the <paramref name="val"/> for HTML
    /// </summary>
    /// <param name="val">string to encode</param>
    /// <returns></returns>
    public static string EncodeForHtml(string val)
    {
        if (string.IsNullOrEmpty(val))
            return val;
        return val.EncodeForHtml();
    }

    /// <summary>
    /// Encodes the <paramref name="val"/> for HTML Attribute
    /// </summary>
    /// <param name="val">string to encode</param>
    /// <returns></returns>
    public static string EncodeForHtmlAttribute(string val)
    {
        if (string.IsNullOrEmpty(val))
            return val;
        return val.EncodeForHtmlAttribute();
    }
    
    /// <summary>
    /// Throws <see cref="ValidatorInputDataException"/>
    /// </summary>
    /// <param name="val">String to validate</param>
    public static void ValidateJsFunction(string val)
    {
        // SECENG: Allow empty parameters
        if (!string.IsNullOrEmpty(val))
        {
            ApiInput input = new ApiInput(val);
            SecurityKernel.Validator.Api.Execute("PatternString.JSFunction", input);
        }
    }
    #endregion

    #region UrlEncoding and UrlDecoding without System.Web
    /// <summary>
    /// UrlEncodes a string without the requirement for System.Web
    /// </summary>
    /// <param name="InputString"></param>
    /// <returns></returns>
    public static string UrlEncode(string InputString)
    {
      StringReader sr = new StringReader(InputString);
      StringBuilder sb = new StringBuilder(InputString.Length);

      while (true)
      {
        int Value = sr.Read();
        if (Value == -1)
          break;
        char CharValue = (char)Value;

        if (CharValue >= 'a' && CharValue <= 'z' ||
          CharValue >= 'A' && CharValue <= 'Z' ||
          CharValue >= '0' && CharValue <= '9')
          sb.Append(CharValue);
        else if (CharValue == ' ')
          sb.Append("+");
        else
          sb.AppendFormat("%{0:X2}", Value);
      }

      return sb.ToString();
    }

    /// <summary>
    /// UrlDecodes a string without requiring System.Web
    /// </summary>
    /// <param name="InputString">String to decode.</param>
    /// <returns>decoded string</returns>
    public static string UrlDecode(string InputString)
    {
      char temp = ' ';
      StringReader sr = new StringReader(InputString);
      StringBuilder sb = new StringBuilder(InputString.Length);

      while (true)
      {
        int lnVal = sr.Read();
        if (lnVal == -1)
          break;
        char TChar = (char)lnVal;
        if (TChar == '+')
          sb.Append(' ');
        else if (TChar == '%')
        {
          // *** read the next 2 chars and parse into a char
          temp = (char)Int32.Parse(((char)sr.Read()).ToString() + ((char)sr.Read()).ToString(),
            System.Globalization.NumberStyles.HexNumber);
          sb.Append(temp);
        }
        else
          sb.Append(TChar);
      }

      return sb.ToString();
    }

    /// <summary>
    /// Retrieves a value by key from a UrlEncoded string.
    /// </summary>
    /// <param name="UrlEncodedString">UrlEncoded String</param>
    /// <param name="Key">Key to retrieve value for</param>
    /// <returns>returns the value or "" if the key is not found or the value is blank</returns>
    public static string GetUrlEncodedKey(string UrlEncodedString, string Key)
    {
      UrlEncodedString = "&" + UrlEncodedString + "&";

      int Index = UrlEncodedString.ToLower().IndexOf("&" + Key.ToLower() + "=");
      if (Index < 0)
        return "";

      int lnStart = Index + 2 + Key.Length;

      int Index2 = UrlEncodedString.IndexOf("&", lnStart);
      if (Index2 < 0)
        return "";

      return UrlDecode(UrlEncodedString.Substring(lnStart, Index2 - lnStart));
    }
    #endregion

    #region Reflection Helper Code
    /// <summary>
    /// Binding Flags constant to be reused for all Reflection access methods.
    /// </summary>
    public const BindingFlags MemberAccess =
      BindingFlags.Public | BindingFlags.NonPublic |
      BindingFlags.Static | BindingFlags.Instance | BindingFlags.IgnoreCase;

    /// <summary>
    /// Binding Flags used for instance method access
    /// </summary>
    public const BindingFlags MethodAccess =
      BindingFlags.GetProperty | BindingFlags.InvokeMethod | BindingFlags.Public |
      BindingFlags.Instance | BindingFlags.IgnoreCase;

    /// <summary>
    /// Create a component from a prog id, uses activator underneath
    /// </summary>
    /// <param name="progID"></param>
    /// <param name="argumentsConstructor"></param>
    /// <returns></returns>
    public static object CreateComponentFromProgID(string progID, params object[] argumentsConstructor)
    {
      Type type = Type.GetTypeFromProgID(progID);

      if (type == null)
      {
        throw new ApplicationException("CreateComponentFromProgID: Unable to retrieve type object for ProgID [" + progID + "]");
      }

      try
      {
        if (argumentsConstructor != null)
          return Activator.CreateInstance(type, argumentsConstructor);
        else
          return Activator.CreateInstance(type);
      }
      catch (Exception ex)
      {
        throw new ApplicationException(String.Format("CreateComponentFromProgID: Unable to create Instance of {0}:{1}{2}", type.Name, ex.Message, (ex.InnerException == null ? "" : "\\nInner Exception:" + ex.InnerException.Message)));
      }
    }

    /// <summary>
    /// Retrieve a property value from an object dynamically. This is a simple version
    /// that uses Reflection calls directly. It doesn't support indexers.
    /// </summary>
    /// <param name="obj">Object to make the call on</param>
    /// <param name="propertyName">Property to retrieve</param>
    /// <returns>Object - cast to proper type</returns>
    public static object GetProperty(object obj, string propertyName)
    {
      return obj.GetType().GetProperty(propertyName, MemberAccess).GetValue(obj, null);
    }
    
    /// <summary>
    /// Retrieve a property info from an object dynamically.
    /// </summary>
    /// <param name="obj">object instance</param>
    /// <param name="propertyName">property name</param>
    /// <returns></returns>
    public static PropertyInfo GetPropertyInfo(object obj, string propertyName)
    {
      var list = obj.GetType().GetProperties(BindingFlags.Instance | BindingFlags.Public | BindingFlags.SetProperty);
      return list.FirstOrDefault(propertyInfo => string.Compare(propertyInfo.Name, propertyName, StringComparison.OrdinalIgnoreCase) == 0);
    }

    /// <summary>
    /// Check the existence of object property  dynamically.
    /// </summary>
    /// <param name="Object">Object to make the call on</param>
    /// <param name="Property">Property to find</param>
    /// <returns>return true if the property exists</returns>
    public static bool CheckingExistenceOfProperty (object Object, string Property)
    {
      var objProperties = Object.GetType().GetProperties();
      return objProperties.Any(t => t.Name.Equals(Property, StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Retrieve a field dynamically from an object. This is a simple implementation that's
    /// straight Reflection and doesn't support indexers.
    /// </summary>
    /// <param name="Object">Object to retreve Field from</param>
    /// <param name="Property">name of the field to retrieve</param>
    /// <returns></returns>
    public static object GetField(object Object, string Property)
    {
      return Object.GetType().GetField(Property, Utils.MemberAccess).GetValue(Object);
    }

    /// <summary>
    /// Parses Properties and Fields including Array and Collection references.
    /// Used internally for the 'Ex' Reflection methods.
    /// </summary>
    /// <param name="Parent"></param>
    /// <param name="Property"></param>
    /// <returns></returns>
    private static object GetPropertyInternal(object Parent, string Property)
    {
      if (Property == "this" || Property == "me")
        return Parent;

      object Result = null;
      string PureProperty = Property;
      string Indexes = null;
      bool IsArrayOrCollection = false;

      // *** Deal with Array Property
      if (Property.IndexOf("[") > -1)
      {
        PureProperty = Property.Substring(0, Property.IndexOf("["));
        Indexes = Property.Substring(Property.IndexOf("["));
        IsArrayOrCollection = true;
      }

      // *** Get the member
      MemberInfo Member = Parent.GetType().GetMember(PureProperty, Utils.MemberAccess)[0];
      if (Member.MemberType == MemberTypes.Property)
        Result = ((PropertyInfo)Member).GetValue(Parent, null);
      else
        Result = ((FieldInfo)Member).GetValue(Parent);

      if (IsArrayOrCollection)
      {
        Indexes = Indexes.Replace("[", "").Replace("]", "");

        if (Result is Array)
        {
          int Index = -1;
          int.TryParse(Indexes, out Index);
          Result = CallMethod(Result, "GetValue", Index);
        }
        else if (Result is ICollection)
        {
          if (Indexes.StartsWith("\""))
          {
            // *** String Index
            Indexes = Indexes.Trim('\"');
            Result = CallMethod(Result, "get_Item", Indexes);
          }
          else
          {
            // *** assume numeric index
            int Index = -1;
            if (int.TryParse(Indexes, out Index))
            {
              Result = CallMethod(Result, "get_Item", Index);
            }

              //Index is non-numeric, and it is a collection of rules, such as (Field1 == Value1) && (Field2 == Value2) etc.
            else
            {
              List<ObjectFilter> objectFilters = new List<ObjectFilter>();
              bool bParsed = ParseObjectFilters(Indexes, out objectFilters);
              if (bParsed)
              {
                Result = FindViewUsingFilters(Result,objectFilters);
              }
              else
              {
                Result = null;
              }

            }
          }
        }

      }

      return Result;
    }


    private static object FindViewUsingFilters(object viewList, List<ObjectFilter> filters)
    {
      if (viewList is IEnumerable)
      {
        foreach (object curView in (viewList as IEnumerable))
        {
          bool match = ViewMatchesFilters(curView, filters);
          if (match)
          {
            return curView;
          }
        }
      }


      return null;
    }

    private static bool ViewMatchesFilters(object curView, List<ObjectFilter> filters)
    {
      bool bMatch = true;

      foreach (ObjectFilter curFilter in filters)
      {
        PropertyInfo pi = curView.GetType().GetProperty(curFilter.Field.ToString());
        if (pi.CanRead)
        {
          object objValue = pi.GetValue(curView,null);
          if (EnumHelper.IsEnumType(pi.PropertyType))
          {
            objValue = EnumHelper.GetValueByEnum(objValue);
          }

          if (!CompareObjects(objValue, curFilter))
          {
            return false;
          }
        }
      }

      return bMatch;
    }

    private static bool CompareObjects(object objValue, ObjectFilter curFilter)
    {
      object rectifiedFilterValue = RectifyValue(objValue.GetType(), curFilter.FieldValue);

      switch (curFilter.Operator)
      {
        case MTOperatorType.OPERATOR_TYPE_EQUAL:
          if (objValue.Equals(rectifiedFilterValue))
          {
            return true;
          }
          break;
          /*
        case MTOperatorType.OPERATOR_TYPE_LESS:
          if (objValue < rectifiedFilterValue)
          {
            return true;
          }
          break;

        case MTOperatorType.OPERATOR_TYPE_LESS_EQUAL:
          if (objValue <= rectifiedFilterValue)
          {
            return true;
          }

          break;

        case MTOperatorType.OPERATOR_TYPE_GREATER:
          if(objValue > rectifiedFilterValue)
          {
            return true;
          }
          break;
        case MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL:
          if(objValue >= rectifiedFilterValue)
          {
            return true;
          }
          break;
          */
        case MTOperatorType.OPERATOR_TYPE_NOT_EQUAL:
          if(!objValue.Equals(rectifiedFilterValue))
          {
            return true;
          }
          break;
      }
      return false;
    }

    private static object RectifyValue(Type type, object fieldValue)
    {
      if (type == typeof(String))
      {
        return fieldValue.ToString();
      }

      if (type == typeof(Int32))
      {
        int intValue = 0;
        if (Int32.TryParse(fieldValue.ToString(), out intValue))
        {
          return intValue;
        }
      }

      if (type == typeof(DateTime))
      {
        DateTime dtValue;
        if (DateTime.TryParse(fieldValue.ToString(), out dtValue))
        {
          return dtValue;
        }
      }

      return fieldValue.ToString();
    }

    private static bool ParseObjectFilters(string filterString, out List<ObjectFilter> objectFilters)
    {
      objectFilters = new List<ObjectFilter>();
      bool bRetCode = false;
      string pat = @"\(?(\w+)\s*(<=|<|!=|==|>|>=)\s*(\""?\w+\""?)\)?(\s*&&\s*\((\w+)\s*(<=|<|!=|==|>|>=)\s*(\""?\w+\""?)\))*";

      Regex r = new Regex(pat, RegexOptions.IgnoreCase);
      Match m = r.Match(filterString);

      if (m.Success)
      {
        bRetCode = true;

        //attempt to parse out the filters
        string patFilter = @"(\w+)\s*(<=|<|!=|==|>|>=)\s*(\""?\w+\""?)";
        r = new Regex(patFilter, RegexOptions.IgnoreCase);

        m = r.Match(filterString);

        //iterate through all matches
        while (m.Success)
        {
          //add new filter to the list
          ObjectFilter of = new ObjectFilter();
          of.Field = m.Groups[1].Value;
          of.Operator = GetFilterOperator(m.Groups[2].Value);
          of.FieldValue = m.Groups[3].Value;

          objectFilters.Add(of);

          m = m.NextMatch();
        }
      }

      return bRetCode;
    }

    private static MTOperatorType GetFilterOperator(string op)
    {
      MTOperatorType opType = MTOperatorType.OPERATOR_TYPE_EQUAL;

      switch (op)
      {
        case "==":
          opType = MTOperatorType.OPERATOR_TYPE_EQUAL;
          break;

        case"<=":
          opType = MTOperatorType.OPERATOR_TYPE_LESS_EQUAL;
          break;

        case "<":
          opType = MTOperatorType.OPERATOR_TYPE_LESS;
          break;

        case ">":
          opType = MTOperatorType.OPERATOR_TYPE_GREATER;
          break;

        case ">=":
          opType = MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL;
          break;

        case "!=":
        case "<>":
          opType = MTOperatorType.OPERATOR_TYPE_NOT_EQUAL;
          break;

        default:
          opType = MTOperatorType.OPERATOR_TYPE_EQUAL;
          break;
      }

      return opType;
    }

    /// <summary>
    /// Parses Properties and Fields including Array and Collection references.
    /// </summary>
    /// <param name="Parent"></param>
    /// <param name="Property"></param>
    /// <param name="Value"></param>
    /// <returns></returns>
    private static object SetPropertyInternal(object Parent, string Property, object Value)
    {
      if (Property == "this" || Property == "me")
        return Parent;

      object Result = null;
      string PureProperty = Property;
      string Indexes = null;
      bool IsArrayOrCollection = false;

      // *** Deal with Array Property
      if (Property.IndexOf("[") > -1)
      {
        PureProperty = Property.Substring(0, Property.IndexOf("["));
        Indexes = Property.Substring(Property.IndexOf("["));
        IsArrayOrCollection = true;
      }

      if (!IsArrayOrCollection)
      {
        // *** Get the member
        MemberInfo Member = Parent.GetType().GetMember(PureProperty, Utils.MemberAccess)[0];
        if (Member.MemberType == MemberTypes.Property)
          ((PropertyInfo)Member).SetValue(Parent, Value, null);
        else
          ((FieldInfo)Member).SetValue(Parent, Value);
        return null;
      }
      else
      {
        // *** Get the member
        MemberInfo Member = Parent.GetType().GetMember(PureProperty, Utils.MemberAccess)[0];
        if (Member.MemberType == MemberTypes.Property)
          Result = ((PropertyInfo)Member).GetValue(Parent, null);
        else
          Result = ((FieldInfo)Member).GetValue(Parent);
      }
      if (IsArrayOrCollection)
      {
        Indexes = Indexes.Replace("[", "").Replace("]", "");

        if (Result is Array)
        {
          int Index = -1;
          int.TryParse(Indexes, out Index);
          Result = CallMethod(Result, "SetValue", Value, Index);
        }
        else if (Result is ICollection)
        {
          if (Indexes.StartsWith("\""))
          {
            // *** String Index
            Indexes = Indexes.Trim('\"');
            Result = CallMethod(Result, "set_Item", Indexes, Value);
          }
          else
          {
            // *** assume numeric index
            int Index = -1;
            int.TryParse(Indexes, out Index);
            Result = CallMethod(Result, "set_Item", Index, Value);
          }
        }

      }

      return Result;
    }

    /// <summary>
    /// Returns the first position of either a . or /
    /// </summary>
    /// <param name="input">String to search</param>
    /// <returns>Position at which either of the above is found, or -1 otherwise</returns>
    protected static int GetIndexOfPathSeparator(string input)
    {
      int pos = -1;

      if (String.IsNullOrEmpty(input))
      {
        return pos;
      }

      pos = input.IndexOf(".");
      if (pos < 0)
      {
        pos = input.IndexOf("/");
      }

      return pos;
    }

    /// <summary>
    /// Returns the data type of the property
    /// </summary>
    /// <param name="Parent"></param>
    /// <param name="Property">Property can be simple or complex(e.g. Internal.SecurityQuestion)</param>
    /// <returns></returns>
    public static Type GetPropertyType(object Parent, string Property)
    {
      if (Parent == null)
      {
        return null;
      }

      Type Type = Parent.GetType();

      int lnAt = GetIndexOfPathSeparator(Property);
      if (lnAt < 0)
      {
        // *** Complex parse of the property    
        return Parent.GetType().GetProperty(Property).PropertyType;
      }

      // *** Walk the . syntax - split into current object (Main) and further parsed objects (Subs)
      string Main = Property.Substring(0, lnAt);
      string Subs = Property.Substring(lnAt + 1);

      // *** Retrieve the next . section of the property
      object Sub = GetPropertyInternal(Parent, Main);

      // *** Now go parse the left over sections
      return GetPropertyType(Sub, Subs);
    }

    /// <summary>
    /// Returns a property or field value using a base object and sub members including . syntax.
    /// For example, you can access: this.oCustomer.oData.Company with (this,"oCustomer.oData.Company")
    /// This method also supports indexers in the Property value such as:
    /// Customer.DataSet.Tables["Customers"].Rows[0]
    /// </summary>
    /// <param name="Parent">Parent object to 'start' parsing from. Typically this will be the Page.</param>
    /// <param name="Property">The property to retrieve. Example: 'Customer.Entity.Company'</param>
    /// <returns></returns>
    public static object GetPropertyEx(object Parent, string Property)
    {
      Type Type = Parent.GetType();

      int lnAt = GetIndexOfPathSeparator(Property);
      if (lnAt < 0)
      {
        // *** Complex parse of the property    
        return GetPropertyInternal(Parent, Property);
      }

      // *** Walk the . syntax - split into current object (Main) and further parsed objects (Subs)
      string Main = Property.Substring(0, lnAt);
      string Subs = Property.Substring(lnAt + 1);

      // *** Retrieve the next . section of the property
      object Sub = GetPropertyInternal(Parent, Main);

      // *** Now go parse the left over sections
      return GetPropertyEx(Sub, Subs);
    }

    /// <summary>
    ///   If the given property on the given object is a nullable type which contains an enum
    ///   then return the type for the enum. Otherwise, return null.
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public static Type GetNullableEnumType(object parent, string propertyName)
    {
      Type type = null;

      if (parent == null)
      {
        return type;
      }

      if (String.IsNullOrEmpty(propertyName))
      {
        return type;
      }

      PropertyInfo propertyInfo = parent.GetType().GetProperty(propertyName, MemberAccess);
      if (propertyInfo == null)
      {
        return type;
      }

      if (propertyInfo.PropertyType.IsGenericType &&
          propertyInfo.PropertyType.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
      {
        NullableConverter nullableConverter = new NullableConverter(propertyInfo.PropertyType);
        if (nullableConverter.UnderlyingType.BaseType == typeof(Enum))
        {
          type = nullableConverter.UnderlyingType;
        }
      }

      return type;
    }

    public static bool IsNullableEnumType(Type type, out Type enumType)
    {
      bool isNullableEnumType = false;
      enumType = null;

      if (type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
      {
        NullableConverter nullableConverter = new NullableConverter(type);
        if (nullableConverter.UnderlyingType.BaseType == typeof(Enum))
        {
          isNullableEnumType = true;
          enumType = nullableConverter.UnderlyingType;
        }
      }

      return isNullableEnumType;
    }

    /// <summary>
    /// Sets the property on an object. This is a simple method that uses straight Reflection 
    /// and doesn't support indexers.
    /// </summary>
    /// <param name="Object">Object to set property on</param>
    /// <param name="Property">Name of the property to set</param>
    /// <param name="Value">value to set it to</param>
    public static void SetProperty(object Object, string Property, object Value)
    {
      Object.GetType().GetProperty(Property, Utils.MemberAccess).SetValue(Object, Value, null);
    }

    /// <summary>
    /// Sets the field on an object. This is a simple method that uses straight Reflection 
    /// and doesn't support indexers.
    /// </summary>
    /// <param name="Object">Object to set property on</param>
    /// <param name="Property">Name of the field to set</param>
    /// <param name="Value">value to set it to</param>
    public static void SetField(object Object, string Property, object Value)
    {
      Object.GetType().GetField(Property, Utils.MemberAccess).SetValue(Object, Value);
    }

    /// <summary>
    /// Sets a value on an object. Supports . syntax for named properties
    /// (ie. Customer.Entity.Company) as well as indexers.
    /// </summary>
    /// <param name="Parent">
    /// Object to set the property on.
    /// </param>
    /// <param name="Property">
    /// Property to set. Can be an object hierarchy with . syntax and can 
    /// include indexers. Examples: Customer.Entity.Company, 
    /// Customer.DataSet.Tables["Customers"].Rows[0]
    /// </param>
    /// <param name="Value">
    /// Value to set the property to
    /// </param>
    public static object SetPropertyEx(object Parent, string Property, object Value)
    {
      Type Type = Parent.GetType();

      // *** no more .s - we got our final object
      int lnAt = GetIndexOfPathSeparator(Property);
      if (lnAt < 0)
      {
        SetPropertyInternal(Parent, Property, Value);
        return null;
      }

      // *** Walk the . syntax
      string Main = Property.Substring(0, lnAt);
      string Subs = Property.Substring(lnAt + 1);

      object Sub = GetPropertyInternal(Parent, Main);

      SetPropertyEx(Sub, Subs, Value);

      return null;
    }

    /// <summary>
    /// Calls a method on an object dynamically.
    /// </summary>
    /// <param name="Object"></param>
    /// <param name="Method"></param>
    /// <param name="Params"></param>
    /// 1st - Method name, 2nd - 1st parameter, 3rd - 2nd parm etc.
    /// <returns></returns>
    public static object CallMethod(object Object, string Method, params object[] Params)
    {
      return Object.GetType().InvokeMember(Method, Utils.MemberAccess | BindingFlags.InvokeMethod, null, Object, Params);
    }

    /// <summary>
    /// Calls a method on the instance of an object
    /// </summary>
    /// <param name="Object"></param>
    /// <param name="Method"></param>
    /// <param name="Params"></param>
    /// <returns></returns>
    public static object CallMethodInstance(object Object, string Method, params object[] Params)
    {
      return Object.GetType().InvokeMember(Method, Utils.MethodAccess, null, Object, Params);
    }

    /// <summary>
    /// Calls a method on an object with extended . syntax (object: this Method: Entity.CalculateOrderTotal)
    /// </summary>
    /// <param name="Parent"></param>
    /// <param name="Method"></param>
    /// <param name="Params"></param>
    /// <returns></returns>
    public static object CallMethodEx(object Parent, string Method, params object[] Params)
    {
      Type Type = Parent.GetType();

      // *** no more .s - we got our final object
      int lnAt = GetIndexOfPathSeparator(Method);
      if (lnAt < 0)
      {
        return Utils.CallMethod(Parent, Method, Params);
      }

      // *** Walk the . syntax
      string Main = Method.Substring(0, lnAt);
      string Subs = Method.Substring(lnAt + 1);

      object Sub = GetPropertyInternal(Parent, Main);

      // *** Recurse until we get the lowest ref
      return CallMethodEx(Sub, Subs, Params);
    }


    /// <summary>
    /// Creates an instance from a type by calling the parameterless constructor.
    /// 
    /// Note this will not work with COM objects - continue to use the Activator.CreateInstance
    /// for COM objects.
    /// <seealso>Class Utils</seealso>
    /// </summary>
    /// <param name="TypeToCreate">
    /// The type from which to create an instance.
    /// </param>
    /// <returns>object</returns>
    public static object CreateInstanceFromType(Type TypeToCreate)
    {
      Type[] Parms = Type.EmptyTypes;
      return TypeToCreate.GetConstructor(Parms).Invoke(null);
    }

    /// <summary>
    /// Converts a type to string if possible. This method supports an optional culture generically on any value.
    /// It calls the ToString() method on common types and uses a type converter on all other objects
    /// if available
    /// </summary>
    /// <param name="RawValue">The Value or Object to convert to a string</param>
    /// <param name="Culture">Culture for numeric and DateTime values</param>
    /// <returns>string</returns>
    public static string TypedValueToString(object RawValue, CultureInfo Culture)
    {
      Type ValueType = RawValue.GetType();
      string Return = null;

      if (ValueType == typeof(string))
        Return = RawValue.ToString();
      else if (ValueType == typeof(int) || ValueType == typeof(decimal) ||
        ValueType == typeof(double) || ValueType == typeof(float))
        Return = string.Format(Culture.NumberFormat, "{0}", RawValue);
      else if (ValueType == typeof(DateTime))
        Return = string.Format(Culture.DateTimeFormat, "{0}", RawValue);
      else if (ValueType == typeof(bool))
        Return = RawValue.ToString();
      else if (ValueType == typeof(byte))
        Return = RawValue.ToString();
      else if (ValueType.IsEnum)
        Return = RawValue.ToString();
      else
      {
        // Any type that supports a type converter
        System.ComponentModel.TypeConverter converter =
          System.ComponentModel.TypeDescriptor.GetConverter(ValueType);
        if (converter != null && converter.CanConvertTo(typeof(string)))
          Return = converter.ConvertToString(null, Culture, RawValue);
        else
          // Last resort - just call ToString() on unknown type
          Return = RawValue.ToString();

      }

      return Return;
    }

    /// <summary>
    /// Converts a type to string if possible. This method uses the current culture for numeric and DateTime values.
    /// It calls the ToString() method on common types and uses a type converter on all other objects
    /// if available.
    /// </summary>
    /// <param name="RawValue">The Value or Object to convert to a string</param>
    /// <returns>string</returns>
    public static string TypedValueToString(object RawValue)
    {
      return TypedValueToString(RawValue, CultureInfo.CurrentCulture);
    }

    /// <summary>
    /// Turns a string into a typed value. Useful for auto-conversion routines
    /// like form variable or XML parsers.
    /// <seealso>Class Utils</seealso>
    /// </summary>
    /// <param name="SourceString">
    /// The string to convert from
    /// </param>
    /// <param name="TargetType">
    /// The type to convert to
    /// </param>
    /// <param name="Culture">
    /// Culture used for numeric and datetime values.
    /// </param>
    /// <returns>object. Throws exception if it cannot be converted.</returns>
    public static object StringToTypedValue(string SourceString, Type TargetType, CultureInfo Culture)
    {
      object Result = null;

      if (TargetType == typeof(string))
        Result = SourceString;
      else if (TargetType == typeof(int))
        Result = int.Parse(SourceString, NumberStyles.Integer, Culture.NumberFormat);
      else if (TargetType == typeof(byte))
        Result = Convert.ToByte(SourceString);
      else if (TargetType == typeof(decimal))
        Result = Decimal.Parse(SourceString, NumberStyles.Any, Culture.NumberFormat);
      else if (TargetType == typeof(double))
        Result = Double.Parse(SourceString, NumberStyles.Any, Culture.NumberFormat);
      else if (TargetType == typeof(bool))
      {
        if (SourceString.ToLower() == "true" || SourceString.ToLower() == "on" || SourceString == "1")
          Result = true;
        else
          Result = false;
      }
      else if (TargetType == typeof(DateTime))
        Result = Convert.ToDateTime(SourceString, Culture.DateTimeFormat);
      else if (TargetType.IsEnum)
        Result = Enum.Parse(TargetType, SourceString);
      else
      {
        System.ComponentModel.TypeConverter converter = System.ComponentModel.TypeDescriptor.GetConverter(TargetType);
        if (converter != null && converter.CanConvertFrom(typeof(string)))
          Result = converter.ConvertFromString(null, Culture, SourceString);
        else
        {
          System.Diagnostics.Debug.Assert(false, "Type Conversion not handled in StringToTypedValue for " +
                                        TargetType.Name + " " + SourceString);
          throw (new ApplicationException("Type Conversion not handled in StringToTypedValue"));
        }
      }

      return Result;
    }

    /// <summary>
    /// Turns a string into a typed value. Useful for auto-conversion routines
    /// like form variable or XML parsers.
    /// </summary>
    /// <param name="SourceString">The input string to convert</param>
    /// <param name="TargetType">The Type to convert it to</param>
    /// <returns>object reference. Throws Exception if type can not be converted</returns>
    public static object StringToTypedValue(string SourceString, Type TargetType)
    {
      return StringToTypedValue(SourceString, TargetType, CultureInfo.CurrentCulture);
    }

    #endregion

    #region COM Reflection Helper Code

    /// <summary>
    /// Retrieve a dynamic 'non-typelib' property
    /// </summary>
    /// <param name="Object">Object to make the call on</param>
    /// <param name="Property">Property to retrieve</param>
    /// <returns></returns>
    public static object GetPropertyCom(object Object, string Property)
    {
      return Object.GetType().InvokeMember(Property, Utils.MemberAccess | BindingFlags.GetProperty | BindingFlags.GetField, null,
                        Object, null);
    }


    /// <summary>
    /// Returns a property or field value using a base object and sub members including . syntax.
    /// For example, you can access: this.oCustomer.oData.Company with (this,"oCustomer.oData.Company")
    /// </summary>
    /// <param name="Parent">Parent object to 'start' parsing from.</param>
    /// <param name="Property">The property to retrieve. Example: 'oBus.oData.Company'</param>
    /// <returns></returns>
    public static object GetPropertyExCom(object Parent, string Property)
    {

      Type Type = Parent.GetType();

      int lnAt = GetIndexOfPathSeparator(Property);
      if (lnAt < 0)
      {
        if (Property == "this" || Property == "me")
          return Parent;

        // *** Get the member
        return Parent.GetType().InvokeMember(Property, Utils.MemberAccess | BindingFlags.GetProperty | BindingFlags.GetField, null,
          Parent, null);
      }

      // *** Walk the . syntax - split into current object (Main) and further parsed objects (Subs)
      string Main = Property.Substring(0, lnAt);
      string Subs = Property.Substring(lnAt + 1);

      object Sub = Parent.GetType().InvokeMember(Main, Utils.MemberAccess | BindingFlags.GetProperty | BindingFlags.GetField, null,
        Parent, null);

      // *** Recurse further into the sub-properties (Subs)
      return Utils.GetPropertyExCom(Sub, Subs);
    }

    /// <summary>
    /// Sets the property on an object.
    /// </summary>
    /// <param name="Object">Object to set property on</param>
    /// <param name="Property">Name of the property to set</param>
    /// <param name="Value">value to set it to</param>
    public static void SetPropertyCom(object Object, string Property, object Value)
    {
      Object.GetType().InvokeMember(Property, Utils.MemberAccess | BindingFlags.SetProperty | BindingFlags.SetField, null, Object, new object[1] { Value });
      //GetProperty(Property,Utils.MemberAccess).SetValue(Object,Value,null);
    }

    /// <summary>
    /// Sets the value of a field or property via Reflection. This method alws 
    /// for using '.' syntax to specify objects multiple levels down.
    /// 
    /// Utils.SetPropertyEx(this,"Invoice.LineItemsCount",10)
    /// 
    /// which would be equivalent of:
    /// 
    /// this.Invoice.LineItemsCount = 10;
    /// </summary>
    /// <param name="Parent">
    /// Object to set the property on.
    /// </param>
    /// <param name="Property">
    /// Property to set. Can be an object hierarchy with . syntax.
    /// </param>
    /// <param name="Value">
    /// Value to set the property to
    /// </param>
    public static object SetPropertyExCom(object Parent, string Property, object Value)
    {
      Type Type = Parent.GetType();

      int lnAt = GetIndexOfPathSeparator(Property);
      if (lnAt < 0)
      {
        // *** Set the member
        Parent.GetType().InvokeMember(Property, Utils.MemberAccess | BindingFlags.SetProperty | BindingFlags.SetField, null,
          Parent, new object[1] { Value });

        return null;
      }

      // *** Walk the . syntax - split into current object (Main) and further parsed objects (Subs)
      string Main = Property.Substring(0, lnAt);
      string Subs = Property.Substring(lnAt + 1);


      object Sub = Parent.GetType().InvokeMember(Main, Utils.MemberAccess | BindingFlags.GetProperty | BindingFlags.GetField, null,
        Parent, null);

      return SetPropertyExCom(Sub, Subs, Value);
    }


    /// <summary>
    /// Wrapper method to call a 'dynamic' (non-typelib) method
    /// on a COM object
    /// </summary>
    /// <param name="Object"></param>
    /// 1st - Method name, 2nd - 1st parameter, 3rd - 2nd parm etc.
    /// <param name="Method"></param>
    /// <param name="Params"></param>
    /// <returns></returns>
    public static object CallMethodCom(object Object, string Method, params object[] Params)
    {
      return Object.GetType().InvokeMember(Method, Utils.MemberAccess | BindingFlags.InvokeMethod, null, Object, Params);
    }

    #endregion

    #region Object Serialization routines
    /// <summary>
    /// Returns a string of all the field value pairs of a given object.
    /// Works only on non-statics.
    /// </summary>
    /// <param name="Obj"></param>
    /// <param name="Separator"></param>
    /// <param name="Type"></param>
    /// <returns></returns>
    public static string ObjectToString(object Obj, string Separator, ObjectToStringTypes Type)
    {
      FieldInfo[] fi = Obj.GetType().GetFields();

      string lcOutput = "";

      if (Type == ObjectToStringTypes.Properties || Type == ObjectToStringTypes.PropertiesAndFields)
      {
        foreach (PropertyInfo Property in Obj.GetType().GetProperties())
        {
          try
          {
            lcOutput = lcOutput + Property.Name + ":" + Property.GetValue(Obj, null).ToString() + Separator;
          }
          catch
          {
            lcOutput = lcOutput + Property.Name + ": n/a" + Separator;
          }
        }
      }

      if (Type == ObjectToStringTypes.Fields || Type == ObjectToStringTypes.PropertiesAndFields)
      {
        foreach (FieldInfo Field in fi)
        {
          try
          {
            lcOutput = lcOutput + Field.Name + ": " + Field.GetValue(Obj).ToString() + Separator;
          }
          catch
          {
            lcOutput = lcOutput + Field.Name + ": n/a" + Separator;
          }
        }
      }
      return lcOutput;
    }

    public enum ObjectToStringTypes
    {
      Properties,
      PropertiesAndFields,
      Fields
    }

    /// <summary>
    /// Serializes an object instance to a file.
    /// </summary>
    /// <param name="Instance">the object instance to serialize</param>
    /// <param name="Filename"></param>
    /// <param name="BinarySerialization">determines whether XML serialization or binary serialization is used</param>
    /// <returns></returns>
    public static bool SerializeObject(object Instance, string Filename, bool BinarySerialization)
    {
      bool retVal = true;

      if (!BinarySerialization)
      {
        XmlTextWriter writer = null;
        try
        {
          XmlSerializer serializer =
            new XmlSerializer(Instance.GetType());

          // Create an XmlTextWriter using a FileStream.
          Stream fs = new FileStream(Filename, FileMode.Create);
          writer = new XmlTextWriter(fs, new UTF8Encoding());
          writer.Formatting = Formatting.Indented;
          writer.IndentChar = ' ';
          writer.Indentation = 3;

          // Serialize using the XmlTextWriter.
          serializer.Serialize(writer, Instance);
        }
        catch (Exception)
        {
          retVal = false;
        }
        finally
        {
          if (writer != null)
            writer.Close();
        }
      }
      else
      {
        Stream fs = null;
        try
        {
          BinaryFormatter serializer = new BinaryFormatter();
          fs = new FileStream(Filename, FileMode.Create);
          serializer.Serialize(fs, Instance);
        }
        catch
        {
          retVal = false;
        }
        finally
        {
          if (fs != null)
            fs.Close();
        }
      }

      return retVal;
    }

    /// <summary>
    /// Overload that supports passing in an XML TextWriter. Note the Writer is not closed
    /// </summary>
    /// <param name="Instance"></param>
    /// <param name="writer"></param>
    /// <returns></returns>
    public static bool SerializeObject(object Instance, XmlTextWriter writer)
    {
      bool retVal = true;

      try
      {
        XmlSerializer serializer =
          new XmlSerializer(Instance.GetType());

        // Create an XmlTextWriter using a FileStream.
        writer.Formatting = Formatting.Indented;
        writer.IndentChar = ' ';
        writer.Indentation = 3;

        // Serialize using the XmlTextWriter.
        serializer.Serialize(writer, Instance);
      }
      catch (Exception ex)
      {
        string Message = ex.Message;
        retVal = false;
      }

      return retVal;
    }

    /// <summary>
    /// Serializes an object into a string variable for easy 'manual' serialization
    /// </summary>
    /// <param name="Instance"></param>
    /// <param name="XmlResultString"></param>
    /// <returns></returns>
    public static bool SerializeObject(object Instance, out string XmlResultString)
    {
      XmlResultString = "";
      MemoryStream ms = new MemoryStream();

      XmlTextWriter writer = new XmlTextWriter(ms, new UTF8Encoding());

      if (!SerializeObject(Instance, writer))
      {
        ms.Close();
        return false;
      }

      byte[] Result = new byte[ms.Length];
      ms.Position = 0;
      ms.Read(Result, 0, (int)ms.Length);

      XmlResultString = Encoding.UTF8.GetString(Result, 0, (int)ms.Length);

      ms.Close();
      writer.Close();

      return true;
    }


    /// <summary>
    /// Serializes an object instance to a file.
    /// </summary>
    /// <param name="Instance">the object instance to serialize</param>
    /// <param name="ResultBuffer">determines whether XML serialization or binary serialization is used</param>
    /// <returns></returns>
    public static bool SerializeObject(object Instance, out byte[] ResultBuffer)
    {
      bool retVal = true;

      MemoryStream ms = null;
      try
      {
        BinaryFormatter serializer = new BinaryFormatter();
        ms = new MemoryStream();
        serializer.Serialize(ms, Instance);
      }
      catch
      {
        retVal = false;
      }
      finally
      {
        if (ms != null)
          ms.Close();
      }

      ResultBuffer = ms.ToArray();

      return retVal;
    }

    /// <summary>
    /// Deserializes an object from file and returns a reference.
    /// </summary>
    /// <param name="Filename">name of the file to serialize to</param>
    /// <param name="ObjectType">The Type of the object. Use typeof(yourobject class)</param>
    /// <param name="BinarySerialization">determines whether we use Xml or Binary serialization</param>
    /// <returns>Instance of the deserialized object or null. Must be cast to your object type</returns>
    public static object DeSerializeObject(string Filename, Type ObjectType, bool BinarySerialization)
    {
      object Instance = null;

      if (!BinarySerialization)
      {

        XmlReader reader = null;
        XmlSerializer serializer = null;
        FileStream fs = null;
        try
        {
          // Create an instance of the XmlSerializer specifying type and namespace.
          serializer = new XmlSerializer(ObjectType);

          // A FileStream is needed to read the XML document.
          fs = new FileStream(Filename, FileMode.Open);
          reader = new XmlTextReader(fs);

          Instance = serializer.Deserialize(reader);

        }
        catch
        {
          return null;
        }
        finally
        {
          if (fs != null)
            fs.Close();

          if (reader != null)
            reader.Close();
        }
      }
      else
      {

        BinaryFormatter serializer = null;
        FileStream fs = null;

        try
        {
          serializer = new BinaryFormatter();
          fs = new FileStream(Filename, FileMode.Open);
          Instance = serializer.Deserialize(fs);

        }
        catch
        {
          return null;
        }
        finally
        {
          if (fs != null)
            fs.Close();
        }
      }

      return Instance;
    }

    /// <summary>
    /// Deserialize an object from an XmlReader object.
    /// </summary>
    /// <param name="reader"></param>
    /// <param name="ObjectType"></param>
    /// <returns></returns>
    public static object DeSerializeObject(System.Xml.XmlReader reader, Type ObjectType)
    {
      XmlSerializer serializer = new XmlSerializer(ObjectType);
      object Instance = serializer.Deserialize(reader);
      reader.Close();

      return Instance;
    }

    public static object DeSerializeObject(string XML, Type ObjectType)
    {
      XmlTextReader reader = new XmlTextReader(XML, XmlNodeType.Document, null);
      return DeSerializeObject(reader, ObjectType);
    }

    public static object DeSerializeObject(byte[] Buffer, Type ObjectType)
    {
      BinaryFormatter serializer = null;
      MemoryStream ms = null;
      object Instance = null;

      try
      {
        serializer = new BinaryFormatter();
        ms = new MemoryStream(Buffer);
        Instance = serializer.Deserialize(ms);

      }
      catch
      {
        return null;
      }
      finally
      {
        if (ms != null)
          ms.Close();
      }

      return Instance;
    }
    #endregion

    #region Miscellaneous Routines

    /// <summary>
    /// Returns the 
    /// </summary>
    /// <param name="accID"></param>
    /// <param name="effectiveDate"></param>
    /// <returns></returns>
    public static int GetCorporateAccountOfChildAccount(int accID, DateTime effectiveDate)
    {
      int corpID = 0;

      try
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\AccHierarchies", "__GET_CORPORATE_ACCOUNT_OF_CURRENT_ACCOUNT__"))
              {

                  stmt.AddParam("%%EFF_DATE%%", effectiveDate, true);
                  stmt.AddParam("%%ID_ACC%%", accID);

                  using (IMTDataReader rdr = stmt.ExecuteReader())
                  {
                      while (rdr.Read())
                      {
                          corpID = rdr.GetInt32("id_ancestor");
                      }
                  }
              }
          }
      }
      catch (Exception e)
      {
        CommonLogger.LogException(String.Format("Unable to retrieve ancestor of account {0}", accID), e);
      }
      return corpID;
    }


    /// <summary>
    /// Returns the logon password stored in the registry if Auto-Logon is used.
    /// This function is used privately for demos when I need to specify a login username and password.
    /// </summary>
    /// <param name="GetUserName"></param>
    /// <returns></returns>
    public static string GetSystemPassword(bool GetUserName)
    {
      RegistryKey RegKey = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon");
      if (RegKey == null)
        return "";

      string Password;
      if (!GetUserName)
        Password = (string)RegKey.GetValue("DefaultPassword");
      else
        Password = (string)RegKey.GetValue("DefaultUsername");

      if (Password == null)
        return "";

      return (string)Password;
    }

    /// <summary>
    /// Converts the passed date time value to Mime formatted time string
    /// </summary>
    /// <param name="Time"></param>
    public static string MimeDateTime(DateTime Time)
    {
      TimeSpan Offset = TimeZone.CurrentTimeZone.GetUtcOffset(Time);

      string sOffset = Offset.Hours.ToString().PadLeft(2, '0');
      if (Offset.Hours < 0)
        sOffset = "-" + (Offset.Hours * -1).ToString().PadLeft(2, '0');

      sOffset += Offset.Minutes.ToString().PadLeft(2, '0');

      return "Date: " + MetraTime.Now.ToString("ddd, dd MMM yyyy HH:mm:ss",
                                                    System.Globalization.CultureInfo.InvariantCulture) +
                                                    " " + sOffset;
    }

    /// <summary>
    /// Single method to retrieve HTTP content from the Web quickly
    /// </summary>
    /// <param name="Url"></param>
    /// <param name="ErrorMessage"></param>
    /// <returns></returns>
    public static string HttpGet(string Url, ref string ErrorMessage)
    {
      string MergedText = "";

      System.Net.WebClient Http = new System.Net.WebClient();

      // Download the Web resource and save it into a data buffer.
      try
      {
        byte[] Result = Http.DownloadData(Url);
        MergedText = Encoding.Default.GetString(Result);
      }
      catch (Exception ex)
      {
        ErrorMessage = ex.Message;
        return null;
      }

      return MergedText;
    }

    public static void LogString(string Output, string Filename)
    {
      StreamWriter Writer = new StreamWriter(Filename, true);
      Writer.WriteLine(DateTime.Now.ToString() + " - " + Output);
      Writer.Close();
    }

    public static string Encrypt(string source)
    {
      Encoding en = Encoding.GetEncoding(0);
      MD5 md5 = new MD5CryptoServiceProvider();
      byte[] result = md5.ComputeHash(en.GetBytes(source));
      return Convert.ToBase64String(result);
    }

    #endregion

    #region Path Functions
    public static string GetBinDir()
    {
      string dirName = Path.GetDirectoryName(Assembly.GetExecutingAssembly().CodeBase);
      dirName = dirName.Replace("file:\\","");
      return dirName;
    }


    /// <summary>
    /// Returns the full path of a full physical filename
    /// </summary>
    /// <param name="Path"></param>
    /// <returns></returns>
    public static string JustPath(string Path)
    {
      FileInfo fi = new FileInfo(Path);
      return fi.DirectoryName + "\\";
    }

    /// <summary>
    /// Returns a relative path string from a full path.
    /// </summary>
    /// <param name="FullPath">The path to convert. Can be either a file or a directory</param>
    /// <param name="BasePath">The base path to truncate to and replace</param>
    /// <returns>
    /// Lower case string of the relative path. If path is a directory it's returned without a backslash at the end.
    /// 
    /// Examples of returned values:
    ///  .\test.txt, ..\test.txt, ..\..\..\test.txt, ., ..
    /// </returns>
    public static string GetRelativePath(string FullPath, string BasePath)
    {
      // *** Start by normalizing paths
      FullPath = FullPath.ToLower();
      BasePath = BasePath.ToLower();

      if (BasePath.EndsWith("\\"))
        BasePath = BasePath.Substring(0, BasePath.Length - 1);
      if (FullPath.EndsWith("\\"))
        FullPath = FullPath.Substring(0, FullPath.Length - 1);

      // *** First check for full path
      if ((FullPath + "\\").IndexOf(BasePath + "\\") > -1)
        return FullPath.Replace(BasePath, ".");

      // *** Now parse backwards
      string BackDirs = "";
      string PartialPath = BasePath;
      int Index = PartialPath.LastIndexOf("\\");
      while (Index > 0)
      {
        // *** Strip path step string to last backslash
        PartialPath = PartialPath.Substring(0, Index);

        // *** Add another step backwards to our pass replacement
        BackDirs = BackDirs + "..\\";

        // *** Check for a matching path
        if (FullPath.IndexOf(PartialPath) > -1)
        {
          if (FullPath == PartialPath)
            // *** We're dealing with a full Directory match and need to replace it all
            return FullPath.Replace(PartialPath, BackDirs.Substring(0, BackDirs.Length - 1));
          else
            // *** We're dealing with a file or a start path
            return FullPath.Replace(PartialPath + (FullPath == PartialPath ? "" : "\\"), BackDirs);
        }
        Index = PartialPath.LastIndexOf("\\", PartialPath.Length - 1);
      }

      return FullPath;
    }
    #endregion

    #region Shell Functions for displaying URL, HTML, Text and XML
    [DllImport("Shell32.dll")]
    private static extern int ShellExecute(int hwnd, string lpOperation,
      string lpFile, string lpParameters,
      string lpDirectory, int nShowCmd);

    /// <summary>
    /// Uses the Shell Extensions to launch a program based or URL moniker.
    /// </summary>
    /// <param name="Url">Any URL Moniker that the Windows Shell understands (URL, Word Docs, PDF, Email links etc.)</param>
    /// <returns></returns>
    public static int GoUrl(string Url)
    {
      string TPath = Path.GetTempPath();

      int Result = ShellExecute(0, "OPEN", Url, "", TPath, 1);
      return Result;
    }

    /// <summary>
    /// Displays an HTML string in a browser window
    /// </summary>
    /// <param name="HtmlString"></param>
    /// <param name="extension"></param>
    /// <returns></returns>
    public static int ShowString(string HtmlString, string extension)
    {
      if (extension == null)
        extension = "htm";

      string File = Path.GetTempPath() + "\\__preview." + extension;
      StreamWriter sw = new StreamWriter(File, false, Encoding.Default);
      sw.Write(HtmlString);
      sw.Close();

      return GoUrl(File);
    }

    public static int ShowHtml(string HtmlString)
    {
      return ShowString(HtmlString, null);
    }

    /// <summary>
    /// Displays a large Text string as a text file.
    /// </summary>
    /// <param name="TextString"></param>
    /// <returns></returns>
    public static int ShowText(string TextString)
    {
      string File = Path.GetTempPath() + "\\__preview.txt";

      StreamWriter sw = new StreamWriter(File, false);
      sw.Write(TextString);
      sw.Close();

      return GoUrl(File);
    }
    #endregion


#if false
		/// <summary>
		/// Parses the text of a Soap Exception and returns just the error message text
		/// Ideally you'll want to have a SoapException fire on the server, otherwise
		/// this method will try to parse out the inner exception error message.
		/// </summary>
		/// <param name="SoapExceptionText"></param>
		/// <returns></returns>
		public static string ParseSoapExceptionText(string SoapExceptionText) 
		{
			string Message = Utils.ExtractString(SoapExceptionText,"SoapException: ","\n");
			if (Message != "")
				return Message;

			Message = Utils.ExtractString(SoapExceptionText,"SoapException: "," --->");
			if (Message == "Server was unable to process request.") 
			{
				Message = Utils.ExtractString(SoapExceptionText,"-->","\n");
				Message = Message.Substring(Message.IndexOf(":")+1);
			}

			if (Message == "")
				return "An error occurred on the server.";

			return Message;
		}
#endif
  }


  public class ExpandUrlsParser
  {
    public string Target = "";

    /// <summary>
    /// Expands links into HTML hyperlinks inside of text or HTML.
    /// </summary>
    /// <param name="Text">The text to expand</param>
    /// <returns></returns>
    public string ExpandUrls(string Text)
    {
      // *** Expand embedded hyperlinks
      string regex = @"\b(((ftp|https?)://)?[-\w]+(\.\w[-\w]*)+|\w+\@|mailto:|[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\.)+(com\b|edu\b|biz\b|gov\b|in(?:t|fo)\b|mil\b|net\b|org\b|[a-z][a-z]\b)(:\d+)?(/[-a-z0-9_:\@&?=+,.!/~*'%\$]*)*(?<![.,?!])(?!((?!(?:<a )).)*?(?:</a>))(?!((?!(?:<!--)).)*?(?:-->))";
      System.Text.RegularExpressions.RegexOptions options = ((System.Text.RegularExpressions.RegexOptions.IgnorePatternWhitespace | System.Text.RegularExpressions.RegexOptions.Multiline)
          | System.Text.RegularExpressions.RegexOptions.IgnoreCase);
      System.Text.RegularExpressions.Regex reg = new System.Text.RegularExpressions.Regex(regex, options);

      MatchEvaluator MatchEval = new MatchEvaluator(this.ExpandUrlsRegExEvaluator);
      return Regex.Replace(Text, regex, MatchEval);
    }

    /// <summary>
    /// Internal RegExEvaluator callback
    /// </summary>
    /// <param name="M"></param>
    /// <returns></returns>
    private string ExpandUrlsRegExEvaluator(Match M)
    {
      string Href = M.Groups[0].Value;
      string Text = Href;

      if (Href.IndexOf("://") < 0)
      {
        if (Href.StartsWith("www."))
          Href = "http://" + Href;
        else if (Href.StartsWith("ftp"))
          Href = "ftp://" + Href;
        else if (Href.IndexOf("@") > -1)
          Href = "mailto://" + Href;
      }

      string Targ = !string.IsNullOrEmpty(this.Target) ? " target='" + this.Target + "'" : "";

      return "<a href='" + Href + "'" + Targ +
              ">" + Text + "</a>";
    }
  }
}

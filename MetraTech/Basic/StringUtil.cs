using System;
using System.CodeDom.Compiler;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;

namespace MetraTech.Basic
{
  public static class StringUtil
  {
    public static object ChangeType(object value, Type conversionType)
    {
      // This if block was taken from Convert.ChangeType as is, and is needed here since we're
      // checking properties on conversionType below.
      if (conversionType == null)
      {
        throw new ArgumentNullException("conversionType");
      } 

      // If it's not a nullable type, just pass through the parameters to Convert.ChangeType
      if (conversionType.IsGenericType &&
        conversionType.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
      {
        // It's a nullable type, so instead of calling Convert.ChangeType directly which would throw a
        // InvalidCastException (per http://weblogs.asp.net/pjohnson/archive/2006/02/07/437631.aspx),
        // determine what the underlying type is
        // If it's null, it won't convert to the underlying type, but that's fine since nulls don't really
        // have a type--so just return null

        // We only do this check if we're converting to a nullable type, since doing it outside
        // would diverge from Convert.ChangeType's behavior, which throws an InvalidCastException if
        // value is null and conversionType is a value type.
        if (value == null)
        {
          return null;
        } 

        // It's a nullable type, and not null, so that means it can be converted to its underlying type,
        // so overwrite the passed-in conversion type with this underlying type
        NullableConverter nullableConverter = new NullableConverter(conversionType);
        conversionType = nullableConverter.UnderlyingType;
      } 

      // Handle Guid
      if (conversionType == typeof(Guid))
      {
        if (value.ToString().IsGuid())
        {
          return value.ToString().ConvertToGuid();
        }
      
        return null;
      }

      // Handle Enum
      if (conversionType.IsEnum)
      {
        return TypeDescriptor.GetConverter(conversionType).ConvertFrom(value);
      }

      // Now that we've guaranteed conversionType is something Convert.ChangeType can handle (i.e. not a
      // nullable type), pass the call on to Convert.ChangeType
      return Convert.ChangeType(value, conversionType);
    }

    public static T FromString<T>(string text)
    {
      try
      {
        return (T)Convert.ChangeType(text, typeof(T), CultureInfo.InvariantCulture);
      }
      catch (System.Exception e)
      {
        throw new BasicException
          (String.Format("Cannot convert string '{0}' to type '{1}'", text, typeof(T).AssemblyQualifiedName),
                         e,
                         SystemConfig.CallerInfo);
      }
    }

    public static object FromString(string text, Type targetType)
    {
      try
      {
        return Convert.ChangeType(text, targetType, CultureInfo.InvariantCulture);
      }
      catch (System.Exception e)
      {
        throw new BasicException
          (String.Format("Cannot convert string '{0}' to type '{1}'", text, targetType.AssemblyQualifiedName), 
                         e,
                         SystemConfig.CallerInfo);
      }
    }

    public static string Join<T>(string delimiter, IEnumerable<T> collection, Func<T, string> convert)
    {
      return String.Join(delimiter, collection.Select(convert).ToArray());
    }

    public static string CleanName(string name)
    {
      Check.Require(!String.IsNullOrEmpty(name), "name cannot be null or empty");

      // Compliant with item 2.4.2 of the C# specification
      string identifier = cSharpIdentifierRegex.Replace(name, "_");
      
      //The identifier must start with a character 
      if (!char.IsLetter(identifier, 0))
      {
        identifier = String.Concat("_", identifier);
      }
      else
      {
        // Upper case the first letter
        Char[] letters = identifier.ToCharArray();
        letters[0] = Char.ToUpper(letters[0]);
        identifier = new String(letters);
      }

      // Escape C# keywords
      identifier = Microsoft.CSharp.CSharpCodeProvider.CreateProvider("C#").CreateEscapedIdentifier(identifier);
      
      // Replace all '_x' with 'X'. 

      // In the lambda below, m is of type System.Text.RegularExpressions.Match
      // Take the last (and only) character (of the match) and uppercase it. Drop the preceding underscores.
      identifier = 
        Regex.Replace(identifier, @"[_]+\w", m => m.Value[m.Value.Length - 1].ToString().ToUpper());

      return identifier;
    }

    public static string Truncate(this string inputString, int size)
    {
      return String.IsNullOrEmpty(inputString) ? 
             inputString :
             inputString.Substring(0, Math.Min(inputString.Length, size));
    }
    #region Data
    private static readonly Regex guidRegex = 
      new Regex(@"^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$", RegexOptions.Compiled); 
    private static readonly Regex cSharpIdentifierRegex = 
      new Regex(@"[^\p{Ll}\p{Lu}\p{Lt}\p{Lo}\p{Nd}\p{Nl}\p{Mn}\p{Mc}\p{Cf}\p{Pc}\p{Lm}]");

    #endregion
  }

  public static class DateTimeUtil
  {
    /// <summary>
    ///    Return true, if the two dates are equal to the second
    /// </summary>
    /// <param name="thisDateTime"></param>
    /// <param name="otherDateTime"></param>
    /// <returns></returns>
    public static bool EqualsToTheSecond(this DateTime thisDateTime, DateTime otherDateTime)
    {
      return thisDateTime.Date.Equals(otherDateTime.Date) &&
             thisDateTime.Hour == otherDateTime.Hour &&
             thisDateTime.Minute == otherDateTime.Minute &&
             thisDateTime.Second == otherDateTime.Second;
    }
  }

  public static class ListToGenericListConverter<T>
  {
    /// <summary>
    /// Converts a non-typed collection into a strongly typed collection.  This will fail if
    /// the non-typed collection contains anything that cannot be casted to type of T.
    /// </summary>
    /// <param name="listOfObjects">A <see cref="ICollection{T}"/> of objects that will
    /// be converted to a strongly typed collection.</param>
    /// <returns>Always returns a valid collection - never returns null.</returns>
    public static List<T> ConvertToGenericList(IList listOfObjects)
    {
      Check.Require(listOfObjects != null, "Argument 'entities' cannot be null", SystemConfig.CallerInfo);

      ArrayList notStronglyTypedList = new ArrayList(listOfObjects);
      return new List<T>(notStronglyTypedList.ToArray(typeof(T)) as T[]);
    }
  }
}

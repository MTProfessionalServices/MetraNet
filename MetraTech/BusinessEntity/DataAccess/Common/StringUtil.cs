using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Text.RegularExpressions;
using MetraTech.BusinessEntity.DataAccess.Exception;
using NHibernate.Util;

using MetraTech.Basic;
using MetraTech.Basic.Config;

namespace MetraTech.BusinessEntity.DataAccess.Common
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
        throw new MetadataException
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
        throw new MetadataException
          (String.Format("Cannot convert string '{0}' to type '{1}'", text, targetType.AssemblyQualifiedName), 
                         e,
                         SystemConfig.CallerInfo);
      }
    }


    #region Data
    private static readonly Regex guidRegex = new Regex(@"^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$", RegexOptions.Compiled); 
    #endregion

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

using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.Threading;
using System.Reflection;
using System.IO;
using System.Resources;
using System.Collections;

namespace MetraTech.DomainModel.Common
{
  public class CommonEnumHelper
  {
    public static bool StringToBool(string value)
    {
        return StringUtils.ConvertToBoolean(value);
      }

    /// <summary>
    /// Returns an enum object of type specified in enumType that has a value
    /// of enumValue in value position specified by valueID.  If value ID is greater
    /// than the number of values for the current enum, null will be returned
    /// </summary>
    /// <param name="enumType"></param>
    /// <param name="enumValue"></param>
    /// <param name="valueID"></param>
    /// <returns></returns>
    public static object GetEnumByValue(Type enumType, string enumValue, int valueID)
    {
      if (String.IsNullOrEmpty(enumValue) == false)
      {
        object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;
          Debug.Assert(attribute != null);

          // Loop through all enum values.
          string[] oldEnumValues = attribute.OldEnumValues;
          for (int i = 0; i < oldEnumValues.Length; i++)
          {
            // Parse enum attribute string.
            string name = String.Empty;
            string[] paramValues = null;
            int ordinal = SplitEnumAttribute(oldEnumValues[i], out name, out paramValues);

            if ((valueID < 0) || (valueID >= paramValues.Length))
            {
              return null;
            }

            //compare param value at the specified position to the search value
            if (paramValues[valueID] == enumValue)
            {
              return Enum.ToObject(enumType, ordinal);
            }
          }
        }
      }

      // enum value not found.
      return null;
    }

    /// <summary>
    /// enumValue must be one of the values in the <value> element.
    /// Specified in R:\extension\...\EnumType\...
    /// For Example in the case of DayOfTheWeek, enumValue should be "1" for "Sunday"
    /// 
    ///      <enum name="DayOfTheWeek">
    ///      <description>Day of the week</description>
    ///      <entries>
    ///        <entry name="Sunday">              <value>1</value></entry>
    ///        <entry name="Monday">        <value>2</value></entry>
    ///        <entry name="Tuesday">        <value>3</value></entry>
    ///        <entry name="Wednesday">        <value>4</value></entry>
    ///        <entry name="Thursday">            <value>5</value></entry>
    ///        <entry name="Friday">              <value>6</value></entry>
    ///        <entry name="Saturday">            <value>7</value></entry>
    ///      </entries>
    ///    </enum>
    ///
    /// </summary>
    /// <param name="enumType"></param>
    /// <param name="enumValue"></param>
    /// <returns></returns>
    public static object GetEnumByValue(Type enumType, string enumValue)
    {
      if (String.IsNullOrEmpty(enumValue) == false)
      {
        ////First try just converting the value to the given type
        ////If that fails, then try checking the attributes
        //try
        //{
          
        //  var enumValueResult = Enum.Parse(enumType, enumValue.ToUpper()); //ToUpper is arbitrary but needed for LanguageCodes 'DE', 'FR', etc.
        //  return enumValueResult;
        //}
        //catch
        //{
        //}

        object[] attributes = enumType.GetCustomAttributes(typeof(MTEnumAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          MTEnumAttribute attribute = attributes[0] as MTEnumAttribute;
          Debug.Assert(attribute != null);

          // Loop through all enum values.
          string[] oldEnumValues = attribute.OldEnumValues;
          for (int i = 0; i < oldEnumValues.Length; i++)
          {
            // Parse enum attribute string.
            string name = String.Empty;
            string[] paramValues = null;
            int ordinal = SplitEnumAttribute(oldEnumValues[i], out name, out paramValues);
            for (int j = 0; j < paramValues.Length; j++)
            {
              // If the enum value matches then return the .Net enum value.
              if (paramValues[j] == enumValue)
                return Enum.ToObject(enumType, ordinal);
            }
          }
        }
      }

      // enum value not found.
      return null;
    }

    /// <summary>
    ///    assemblyName must be the name of the dll as in:
    ///     MetraTech.DomainModel.Enums.Generated.dll
    ///    
    ///    ie. No path
    /// </summary>
    /// <param name="assemblyName"></param>
    /// <param name="searchDir"></param>
    /// <returns></returns>
    public static Assembly GetAssembly(string assemblyName, string searchDir)
    {
      Assembly assembly = null;

      try
      {
        assembly = Assembly.Load(assemblyName.Replace(".dll", ""));
      }
      catch (Exception)
      {
        assembly =
          Assembly.LoadFile
            (Path.Combine(searchDir, assemblyName));
      }

      return assembly;
    }

    public static T EnumCast<T>(object value)
    {
        return (T)System.Convert.ChangeType(value, Enum.GetUnderlyingType(typeof(T)));
    }

    #region Protected Methods
    // Split each enum value into parts (ordinal:"name":value 1:value 2:value N"
    protected static int SplitEnumAttribute(string attributeString, out string name, out string[] internalValues)
    {
      // Find the last quote in the string.
      int firstQuoteIndex = attributeString.IndexOf('"');
      int lastQuoteIndex = attributeString.LastIndexOf('"');

      // Set the name for the internal enum value.
      name = attributeString.Substring(firstQuoteIndex + 1, lastQuoteIndex - (firstQuoteIndex + 1));

      // Return the array of internal values.
      string values = attributeString.Substring(lastQuoteIndex + 2);
      internalValues = values.Split(':');

      return GetEnumAttributeOrdinal(attributeString);
    }

    /// <summary>
    ///   Given an enum attribute string of the type:
    ///   "0:\"AccountResolution\":AccountResolution"
    ///   
    ///   Return the ordinal value. 0, in this case.
    /// </summary>
    /// <param name="attributeString"></param>
    /// <returns></returns>
    protected static int GetEnumAttributeOrdinal(string attributeString)
    {
      string[] attributeParts = attributeString.Split(':');
      // Return ordinal value of enum value.
      return Int32.Parse(attributeParts[0]);
    }

    #endregion

    #region Data
    public const string enumAssemblyName = "MetraTech.DomainModel.Enums.Generated.dll";
    #endregion
  }
}

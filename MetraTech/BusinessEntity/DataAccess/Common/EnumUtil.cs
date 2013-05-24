using System;
using System.Linq;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.DomainModel.Common;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public static class EnumUtil
  {
    /// <summary>
    ///    Return the enumSpace and enumType from the MTEnumAttribute for the
    ///    specified enum
    /// </summary>
    /// <param name="assemblyQualifiedName"></param>
    /// <param name="enumSpace"></param>
    /// <param name="enumType"></param>
    public static void GetEnumSpaceAndName(string assemblyQualifiedName,
                                           out string enumSpace,
                                           out string enumName)
    {
      Check.Require(!String.IsNullOrEmpty(assemblyQualifiedName), 
                    "Argument 'assemblyQualifiedName' cannot be null or empty", 
                    SystemConfig.CallerInfo);

      enumSpace = String.Empty;
      enumName = String.Empty;

      try
      {
        Type type = Type.GetType(assemblyQualifiedName, true);
        Check.Assert(type != null, String.Format("Cannot find enum type '{0}'", assemblyQualifiedName), SystemConfig.CallerInfo);
        Check.Assert(type.IsEnum, String.Format("Type '{0}' is not an enum type", assemblyQualifiedName), SystemConfig.CallerInfo);
        
        MTEnumAttribute attribute = 
          type.GetCustomAttributes(typeof(MTEnumAttribute), false).Cast<MTEnumAttribute>().Single();
        Check.Assert(attribute != null, String.Format("Cannot find MTEnumAttribute for enum type '{0}'", assemblyQualifiedName), SystemConfig.CallerInfo);

        enumSpace = attribute.EnumSpace;
        enumName = attribute.EnumName;

        Check.Ensure(!String.IsNullOrEmpty(enumSpace), String.Format("Enum space not found for enum type '{0}'", assemblyQualifiedName), SystemConfig.CallerInfo);
        Check.Ensure(!String.IsNullOrEmpty(enumName), String.Format("Enum name not found for enum type '{0}'", assemblyQualifiedName), SystemConfig.CallerInfo);

      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load type '{0}'.", assemblyQualifiedName);
        throw new MetadataException(message, e, SystemConfig.CallerInfo);
      }
    }
  }

    
}

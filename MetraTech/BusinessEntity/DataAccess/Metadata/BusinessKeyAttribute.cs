using System;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  /// <summary>
  /// Facilitates indicating which property(s) describe the unique businessKey of an 
  /// entity.  See DataObject.GetTypeSpecificBusinessKeyProperties() for when this is leveraged.
  /// </summary>
  /// <remarks>
  /// This is intended for use with <see cref="DataObject" />.  It may NOT be used on a <see cref="ValueObject"/>.
  /// </remarks>
  [Serializable]
  public class BusinessKeyAttribute : Attribute { }
}

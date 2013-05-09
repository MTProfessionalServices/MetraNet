using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Xml;

// MetraTech Dynamic Data Object namespace.
namespace MetraTech.DDO
{
  // ENUM MEMBERS:
  public enum PropertyType
  {
	  UNKNOWN,
	  INTEGER,
	  DOUBLE,
	  STRING,
	  DATETIME,
	  BOOLEAN,
	  ENUM,
	  DECIMAL,
    BIGINTEGER
  }

  /// <summary>
  /// This class describes an individual dynamic data object property.
  /// </summary>
  [DataContract(Name = "Property")]
  public class Property
  {
    // MEMBER PROPERTIES:

    /// <summary>
    /// This is a required property. This name will identify the
    /// generated class property and will be decorated with “c_” to become
    /// a column in a database table.
    /// </summary>
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    /// <summary>
    /// This is an optional property. This member property provides a detailed
    /// description of the DDO.Property and is useful for generating help.
    /// </summary>
    public string Description
    {
      get { return description; }
      set { description = value; }
    }

    /// <summary>
    /// This is a required property.
    /// The default value for this property is UNKNOWN.
    /// </summary>
    public PropertyType PropType
    {
      get { return propType; }
      set { propType = value; }
    }

    /// <summary>
    /// This property is used only if PropType is set to STRING.
    /// The default value is 0, which means that maximum length will be created.
    /// </summary>
    public int Size
    {
      get { return size; }
      set { size = value; }
    }

    /// <summary>
    /// The default value of this property is true. When set to false interface will thow an error
    /// when setting the property to NULL and the database table column will have a required constraint.
    /// </summary>
    public bool IsNullable
    {
      get { return isNullable; }
      set { isNullable = value; }
    }

    /// <summary>
    /// The default value of this property is false. When set to true the property will have a
    /// unique constraint applied to the underlying column in the database table.
    /// </summary>
    public bool IsUnique
    {
      get { return isUnique; }
      set { isUnique = value; }
    }

    /// <summary>
    /// The default value of this property is NULL. This property may be set to any value
    /// associated with the PropType. This value will become the default property value constraint
    /// on the underlying table.
    /// </summary>
    public object DefaulValue
    {
      get { return defaultValue; }
      set { defaultValue = value; }
    }

    // DATA MEMBERS:

    [DataMember()]
    private string name;

    [DataMember()]
    private string description;

    [DataMember()]
    private PropertyType propType = PropertyType.UNKNOWN;

    [DataMember()]
    private int size = 0;

    [DataMember()]
    private bool isNullable = true;

    [DataMember()]
    private bool isUnique = false;

    [DataMember()]
    private object defaultValue = null;
  }
}

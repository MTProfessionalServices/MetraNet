using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Xml;

// MetraTech Dynamic Data Object namespace.
namespace MetraTech.DDO
{
  [DataContract(Name = "Relation")]
  public class Relation
  {
    // MEMBER PROPERTIES:

    public enum RelationKind
    {
      OneToOne,  // Default
      OneToMany,
      ManyToMany,
      ManyToOne,
    }

    /// <summary>
    /// Object relationship name, read only. This name will identify a class property to access
    /// one or more relational values.
    /// </summary>
    public string Name
    {
      get { return name; }
    }

    /// <summary>
    /// This is an optional parameter. A detailed description of the relashinship is useful
    /// for generating help.
    /// </summary>
    public string Description
    {
      get { return description; }
      set { description = value; }
    }

    /// <summary>
    /// This is a required parameter and can be one of the following relashionship types:
    /// OneToOne,OneToMany, ManyToMany, and ManyToOne.
    /// The default value is OneToOne.
    /// </summary>
    public RelationKind Kind
    {
      get { return kind; }
      set { kind = value; }
    }

    /// <summary>
    /// This is an optional parameter that specifies the filename that points to a
    /// dynamic data object configuration file (.ddo.xml). Once the file is validated
    /// the Relation object will be identified with the type defined by the configuration
    /// file. Alternatively, set the Entity property instead.
    /// </summary>
    public string EntityFilename
    {
      get { return entityFilename; }
      set { entityFilename = value; }
    }

    /// <summary>
    /// This is an optional property that may be used as and alternative to EntityFilename
    /// to initialize this class. If Configuration file is unavailable or does not yet exists,
    /// specify an Entity class with which to identify the relation.
    /// </summary>
    public Entity Entity
    {
      get { return entity; }
      set { entity = value; }
    }

    // DATA MEMBERS:
    [DataMember()]
    private string name = String.Empty;

    [DataMember()]
    private string description;

    [DataMember()]
    private RelationKind kind = RelationKind.OneToOne;

    [DataMember()]
    private string entityFilename;

    [DataMember()]
    private Entity entity = null;
  }
}

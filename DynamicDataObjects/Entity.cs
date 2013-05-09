using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Xml;

// MetraTech Dynamic Data Object namespace.
namespace MetraTech.DDO
{
  // Metratech specific.
  using MetraTech.Interop.RCD;

  [DataContract(Name = "Entity", Namespace = "www.metratech.com")]
  public class Entity
  {
      // MEMBER PROPERTIES:

      /// <summary>
      /// This is a required property that represents the name of dynamic data object.
      /// The name must be unique accross all extensions. If the name is not unique the
      /// code generation step will fail. This name will become the dynamic data object
      /// class name and will be part of the database table name.
      /// </summary>
      public string Name
      {
        get { return name; }
        set { name = value; }
      }

      /// <summary>
      /// Description of dynamic data object. This description may be helpful in generating
      /// help for the new dynamic data object.
      /// </summary>
      public string Description
      {
        get { return description; }
        set { description = value; }
      }

      /// <summary>
      /// Dynamic Data Object configuration files are stored in
      /// \extensions\{Extension}\Config\DDO\ folder. This parameter is required and 
      /// identifies the extention folder to which this dynamic data object belongs.
      /// Additionally, this property partially identifies the assembly name that this
      /// dynamic data object will be complied to.
      /// </summary>
      public string Extension
      {
        get { return extension; }
        set { extension = value; }
      }

      /// <summary>
      /// This is an optional parameter. Set this parameter to true to enable temporal
      /// management for this Entity. The default value is set to false.
      /// </summary>
      public bool TrackHistory
      {
        get { return trackHistory; }
        set { trackHistory = value; }
      }

      /// <summary>
      /// This parameter provides a fully qualified path to the configuration file.
      /// </summary>
      public string Path
      {
        get
        {
          return MakeFilename(Name, Extension);  
        }
      }

      /// <summary>
      /// This property enumerates all the Property objects that describe the dynamic
      /// data object defined by this Entity. This is a read only property.
      /// </summary>
      public Dictionary<string, Property> Properties
      { 
        get { return properties; }
      }

      /// <summary>
      /// This property enumerates all the Relation objects that are associated with
      /// the dynamic data object defined by this Entity. This is a read only property.
      /// </summary>
      public Dictionary<string, Relation> Relations
      { 
        get { return relations; }
      }

      // PUBLIC MEMBER METHODS:

      /// <summary>
      /// Add a new Property to the dynamic data object. Error will be thrown is property by with same
      /// name already exists.
      /// </summary>
      /// <param name="property">Object that describes the property to add.</param>
      public void AddProperty(Property property)
      {
        // Make sure the property is not null.
        if (property == null)
          throw new Exception("Added property object is null");

        // Make sure property name is specified.
        if (property.Name.Length == 0)
          throw new Exception("DDO property 'Name' not specified.");

        // Initialize properties list as needed.
        if (properties == null)
          properties = new Dictionary<string, Property>();

        // Check is property already exists.
        if (properties.ContainsKey(property.Name))
            throw new Exception("Property '" + property.Name + "' already exists");

        // Vaidate property.
        //xxx TODO:

        // Add property.
        properties[property.Name] = property;
      }

      /// <summary>
      /// Remove a Property proverty from the dynamic data object. Nothing will happen if provided
      /// property does not exist.
      /// </summary>
      /// <param name="name">Name of property to remove from this dynamic data object</param>
      /// 
      public void RemoveProperty(string name)
      {
        // Check if there is anything todo.
        if (properties == null || name == null || name.Length == 0)
          return;

        properties.Remove(name);
      }

      /// <summary>
      /// Add a new Relation to the dynamic data object. Error will be thrown if the same relation
      /// already exists.
      /// </summary>
      /// <param name="relation"></param>
      public void AddRelation(Relation relation)
      {
        // Make sure the property is not null.
        if (relation == null)
          throw new Exception("Added relationship object is null");

        // Initialize properties list as needed.
        if (relations == null)
          relations = new Dictionary<string, Relation>();

        // Check is property already exists.
        if (relations.ContainsKey(relation.Name))
          throw new Exception("Relation '" + relation.Name + "' already exists");

        // Vaidate relation.
        //xxx TODO:

        // Add property.
        relations[relation.Name] = relation;
      }

      /// <summary>
      /// Remove a Relation from the dynamic data object. Nothing will happen if specified relationship
      /// does not exist.
      /// </summary>
      /// <param name="name"></param>
      public void RemoveRelation(string name)
      {
        // Check if there is anything todo.
        if (relations == null || name == null || name.Length == 0)
          return;

        // Remove property if found.
        relations.Remove(name);
      }

      /// <summary>
      /// Persist the dynamic data object configuration information to disk: 
      /// 1. One file per dynamic data object
      /// 2. Destination folder: \extensions\{Extension}\Config\DDO\
      /// 3. Filename will be {Name}.ddo.xml
      /// Ecption will be raised if Extension property is not set prior to callig
      /// this method.
      /// </summary>
      public void Save()
      {
        //xxx TODO: Good enahancement, keep a dirty flag and only save if any changes ditected.

        // Validate that required properties are provided.
        // Validate Extension and Name to start
        //xxx TODO: 

        // Make sure extension exists.
        string extensionPath = rcd.ExtensionDir + @"\" + Extension;
        if (!Directory.Exists(extensionPath))
          throw new Exception("Extension '" + extension + "' does not found");

        // Make sure that the Extension path exists.
        string directoryName = MakePath(Name, Extension);
        if (!Directory.Exists(directoryName))
        {
			    try
          {
				    Directory.CreateDirectory(directoryName);
			    }
			    catch (Exception e)
          {
				    throw new Exception("Exception creating directory '" + directoryName + "', " + e.Message);
			    }
				}

        // Serialization
        FileStream writer = new FileStream(MakeFilename(Name, Extension), FileMode.Create);
        DataContractSerializer serializer = new DataContractSerializer(typeof(Entity));
        serializer.WriteObject(writer, this);
        writer.Close();
      }

      /// <summary>
      /// Load the Dynamic Data Object information from the specified configuration file.
      /// This function will throw an exception if the configuration file is not valid.
      /// Filename must end with ".ddo.xml"
      /// </summary>
      /// <param name="configFilename">A fully qualified path to a valid DDO configuration file.</param>
      public static Entity Load(string configFilename)
      {
        // Deserialization
        FileStream fs = new FileStream(configFilename, FileMode.Open);
        XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());

        DataContractSerializer serializer = new DataContractSerializer(typeof(Entity));
        Entity entity = (Entity)serializer.ReadObject(reader, true);
        reader.Close();
        return entity;
      }

      /// <summary>
      /// Load the Dynamic Data Object information from the specified configuration file.
      /// This function will throw an exception if the name or extension is not valid.
      /// </summary>
      /// <param name="name">Name of dynamic data object.</param>
      /// <param name="extension">Extnsion the dynamic data object is stored in.</param>
      public static Entity Load(string name, string extension)
      {
        return Load(MakeFilename(name, extension));
      }
  
      // PRIVATE MEMBER METHODS:
      private static string MakePath(string name, string extension)
      {
        return rcd.ExtensionDir + @"\" + extension + @"\Config\ddo\";
      }

      private static string MakeFilename(string name, string extension)
      {
        return MakePath(name, extension) + name + ".ddo.xml";
      }

      // DATA MEMBERS:
      [DataMember()]
      private string name;
      
      [DataMember()]
      private string description;

      [DataMember()]
      private string extension;

      [DataMember()]
      private bool trackHistory = false;

      [DataMember()]
      private Dictionary<string, Property> properties = null;

      [DataMember()]
      private Dictionary<string, Relation> relations = null;

      // Used to figure out where the store the entity.
      private static IMTRcd rcd = new MTRcdClass();
    }

  /// <summary>
  /// This class is used to enumerate items of Entity type.
  /// </summary>
  public class EntityEnum : IEnumerator
  {
    // MEMBER METHODS:
    public EntityEnum(ArrayList list)
    {
      entities = list;
    }

    public bool MoveNext()
    {
      position++;
      return (position < entities.Count);
    }

    public void Reset()
    {
      position = -1;
    }

    public object Current
    {
      get
      {
        try
        {
          return entities[position];
        }
        catch (IndexOutOfRangeException)
        {
          throw new InvalidOperationException();
        }
      }
    }

    // DATA MEMBERS:
    public ArrayList entities;

    // Enumerators are positioned before the first element
    // until the first MoveNext() call.
    protected int position = -1;
  }
}

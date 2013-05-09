using System;
using System.Collections;
using System.Text;
using System.IO;

// MetraTech specific.
using MetraTech.Xml;

// MetraTech Dynamic Data Object namespace.
namespace MetraTech.DDO
{
  public class Entities : IEnumerable
  {
    // MEMBER METHODS:

    /// <summary>
    /// Add a new Entity to the collection.
    /// </summary>
    /// <param name="entity"></param>
    public void Add(Entity entity)
    {
      // Allocate as needed.
      if (entities == null)
        entities = new ArrayList();

      // Check if entity already exists.
      foreach (Entity ent in entities)
      {
        if (entity.Name == ent.Name)
          throw new Exception("Dynamic Data object \"" + entity.Name + "\" already exists");
      }

      // Vaidate entity.
      //xxx TODO:

      // Add entity.
      entities.Add(entity);
    }

    /// <summary>
    /// Add a new Entity to the collection using a configuration file.
    /// </summary>
    /// <param name="configFilename"></param>
    public void Add(string configFilename)
    {
      Add(Entity.Load(configFilename));
    }

    /// <summary>
    /// Remove the entity configuration from collection. This will permanently
    /// delete the configuration file from disk.
    /// </summary>
    /// <param name="name"></param>
    public void Remove(string name)
    {
      // Check if there is anything todo.
      if (entities == null || name == null || name.Length == 0)
        return;

      // Find entity.
      for (int i = 0; i < entities.Count; i++)
      {
        // Remove entity if found.
        if (((Entity) entities[i]).Name == name)
        {
          Entity entity = (Entity) entities[i];
          entities.RemoveAt(i);

          // Delete associated DDO configuratuion file.
          if (File.Exists(entity.Path))
            File.Delete(entity.Path);
          return;
        }
      }
    }

    /// <summary>
    /// Return the IEnumerable interface for iteration over the collection.
    /// </summary>
    /// <returns></returns>
    public IEnumerator GetEnumerator()
    {
      return new EntityEnum(entities);
    }

    /// <summary>
    /// Generate new configuration files or update existing configuration files based on entities
    /// loaded in the collection.
    /// </summary>
    public void Save()
    {
      foreach (Entity entity in entities)
        entity.Save();
    }

    /// <summary>
    /// Locate all dynamic data object types and load them into this collection.
    /// This method will look for all files with a “.ddo.xml” extention in the {extension} folders.
    /// The configuration file will be validated before being added to the collecton.
    /// </summary>
    public void Load()
    {
      string searchQuery = @"config\DDO\*.ddo.xml";

      // Find all files and populate Entities collection.
      foreach (string configFilename in MTXmlDocument.FindFilesInExtensions(searchQuery))
      {
        // Validate that this is actually a DDO configuration file.
        //xxx TODO:

        // Add to cache.
        Add(configFilename);
      }
    }

    // DATA MEMBERS:
    private ArrayList entities = null;
  }
}

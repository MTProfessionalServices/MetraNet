using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class MultiData
  {
    #region Public Methods
    public MultiData()
    {
      Instances = new Dictionary<Entity, List<DataObject>>();
      SaveSpecs = new Dictionary<DataObject, SaveSpec>();
    }

    public void Clear()
    {
      Instances.Clear();
      SaveSpecs.Clear();
    }

    public void AddInstance<T>(T instance, SaveSpec relationshipSpec = null) where T : DataObject
    {
      Check.Require(instance != null, "instance cannot be null");
      AddInstances(new Dictionary<T, SaveSpec> { {instance, relationshipSpec} });
    }

    public void AddInstances<T>(Dictionary<T, SaveSpec> instances) where T : DataObject
    {
      Check.Require(instances != null, "instances cannot be null");
      if (instances.Count == 0) return;

      List<DataObject> currentInstances;

      foreach(KeyValuePair<T, SaveSpec> kvp in instances)
      {
        Entity entity = MetadataRepository.Instance.GetEntity(kvp.Key.GetType().FullName);
        Check.Require(entity != null, String.Format("Cannot find entity '{0}' in metadata repository", kvp.Key.GetType().FullName));

        // Check database
        Instances.Keys.ForEach(e =>
          Check.Require(e.DatabaseName.ToLower() == entity.DatabaseName, 
                        String.Format("Cannot add instances of type '{0}' because its database '{1}' is different from the current instances",
                        entity.FullName, entity.DatabaseName)));

        if (!Instances.TryGetValue(entity, out currentInstances))
        {
          currentInstances = new List<DataObject>();
          Instances.Add(entity, currentInstances);
        }

        // Prevent duplicates
        Check.Require(!currentInstances.Contains(kvp.Key), String.Format("Instance '{0}' has already been added", kvp.Key));
        currentInstances.Add(kvp.Key);

        if (kvp.Value != null)
        {
          Check.Require(!SaveSpecs.ContainsKey(kvp.Key), String.Format("Instance '{0}' has already been added", kvp.Key));
          SaveSpecs.Add(kvp.Key, kvp.Value);
        }
      }
    }

    public T GetInstance<T>() where T: DataObject
    {
      Entity entity = MetadataRepository.Instance.GetEntity(typeof(T).FullName);
      Check.Require(entity != null, String.Format("Cannot find entity '{0}' in metadata repository", typeof(T).FullName));

      List<DataObject> currentInstances;
      Instances.TryGetValue(entity, out currentInstances);
      
      // Ok to not have any instances
      if (currentInstances == null || currentInstances.Count == 0)
        return null;

      // Not Ok to have more than one instance
      Check.Require(currentInstances.Count == 1, 
                    String.Format("Found multiple instances of type '{0}'. Use GetInstances", typeof(T).FullName));

      return currentInstances[0] as T;
    }

    public List<T> GetInstances<T>() where T: DataObject
    {
      Entity entity = MetadataRepository.Instance.GetEntity(typeof(T).FullName);
      Check.Require(entity != null, String.Format("Cannot find entity '{0}' in metadata repository", typeof(T).FullName));

      return GetInstances(entity).Cast<T>().ToList();
    }

    public List<DataObject> GetInstances(Entity entity)
    {
      List<DataObject> currentInstances;
      Instances.TryGetValue(entity, out currentInstances);

      if (currentInstances == null) 
        return new List<DataObject>();

      return currentInstances;
    }

    public List<DataObject> GetInstances(string entityName)
    {
      Entity entity = MetadataRepository.Instance.GetEntity(entityName);
      Check.Require(entity != null, String.Format("Cannot find entity '{0}' in metadata repository", entityName));

      List<DataObject> currentInstances;
      Instances.TryGetValue(entity, out currentInstances);

      if (currentInstances == null)
        return new List<DataObject>();

      return currentInstances;
    }

    public List<Entity> GetEntities()
    {
      return Instances.Keys.ToList();
    }

    public SaveSpec GetSaveSpec(DataObject instance)
    {
      SaveSpec relationshipSpec;
      SaveSpecs.TryGetValue(instance, out relationshipSpec);
      return relationshipSpec;
    }

    #endregion

    #region Private Properties
    private Dictionary<Entity, List<DataObject>> Instances {get; set;}
    private Dictionary<DataObject, SaveSpec> SaveSpecs { get; set; }
    #endregion
  }

  public class SaveSpec
  {
    #region Public Methods
    public SaveSpec()
    {
      RelationshipNames = new List<string>();
      UpdateInstance = true;
    }

    /// <summary>
    ///   Error, if the specified relationshipName is not valid for the specified entityName
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="relationshipName"></param>
    public void AddRelationshipName(string entityName, string relationshipName)
    {
      if (RelationshipNames.Contains(relationshipName)) return;
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(relationshipName), "relationshipName cannot be null or empty");
      Check.Require(MetadataRepository.Instance.HasRelationshipName(entityName, relationshipName),
                    String.Format("Specified relationshipName '{0}' cannot be found on entity '{1}'",
                                   relationshipName, entityName));

      RelationshipNames.Add(relationshipName);
    }

    public void DeleteRelationshipName(string relationshipName)
    {
      Check.Require(!String.IsNullOrEmpty(relationshipName), "relationshipName cannot be null or empty");
      RelationshipNames.Remove(relationshipName);
    }

    public List<string> GetRelationshipNames()
    {
      return RelationshipNames.ToList();
    }
    #endregion

    #region Public Properties
    public bool UpdateRelationship { get; set; }
    public bool UpdateInstance { get; set; }
    #endregion

    #region Private Properties
    private List<string> RelationshipNames { get; set; }
    #endregion
  }
}

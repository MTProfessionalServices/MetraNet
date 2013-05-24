using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using System.Resources;


namespace MetraTech.DomainModel.BaseTypes
{
  /// <summary>
  /// Base class for the service definition domain model.
  /// This is the model that is used if the service definition
  /// doesn't have any related children.
  /// </summary>
  
  [DataContract]
  [Serializable]
  public class BaseServiceDef : BaseObject
  {
    /// <summary>
    /// Name of the generated assembly.
    /// </summary>
    public const string generatedAssemblyName = "MetraTech.DomainModel.ServiceDefinitions.Generated";

    [System.Web.Script.Serialization.ScriptIgnore]
    [NonSerialized]
    protected static readonly new System.Resources.ResourceManager ResourceManager = new System.Resources.ResourceManager ( "MetraTech.Baseline", Assembly.GetExecutingAssembly () );
  }

  /// <summary>
  /// RootServiceDef's are service definitions that have children.
  /// </summary>
  [DataContract]
  [KnownType("KnownTypes")]
  [Serializable]
  public class RootServiceDef : BaseServiceDef
  {
      /// <summary>
      /// Returns the list of known service def types, by looping through the generated assembly and finding compatible types.
      /// </summary>
      public static Type[] KnownTypes()
      {
          List<Type> types = new List<Type>();
          Assembly assembly = MetraTech.DomainModel.BaseTypes.BaseObject.GetAssembly(generatedAssemblyName);
          foreach (Type type in assembly.GetTypes())
          {
              if (typeof(RootServiceDef).IsAssignableFrom(type))
              {
                  types.Add(type);
              }
          }
          return types.ToArray();
      }
  }

  /// <summary>
  /// Attribute to declare what svc def a BaseServiceDef corresponds to.
  /// </summary>
  [AttributeUsage(AttributeTargets.Class, AllowMultiple=false)]
  public class ServiceDefinitionAttribute : System.Attribute
  {
    public string Namespace { get; set; }
    public string Name { get; set; }
    public string Key { get; set; }
  }
}

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Xml;
using System.Text;
using System.Xml.Linq;
using MetraTech.Basic.Config;
using MetraTech.Basic;

namespace MetraTech.DomainModel.BaseTypes
{
  [DataContract]
  [Serializable]
  [KnownType("GetKnownTypes")]
  public abstract class BaseDto
  {
    /// <summary>
    ///   Retrieve the BaseDto derived types from the DTO assemblies specified in 'dto-assembly' elements in
    ///   RMP\config\domainmodel\config.xml
    /// </summary>
    /// <returns></returns>
    public static Type[] GetKnownTypes()
    {
      var types = new List<Type>();
     
      string configFile = Path.Combine(SystemConfig.GetConfigDir(), @"domainmodel\config.xml");
      if (!File.Exists(configFile))
      {
        logger.Error((String.Format("Cannot find domain model config file '{0}'", configFile)));
      }
      
      IEnumerable<XElement> dtoAssemblies = from s in XElement.Load(configFile).Elements("dto-assembly")
                                            select s;

      foreach(string assemblyName in dtoAssemblies)
      {
        Assembly assembly;
        try
        {
          assembly = Assembly.Load(assemblyName.ToLower().Replace(".dll", ""));
          Check.Require(assembly != null, String.Format("Cannot load assembly '{0}'", assemblyName));
        }
        catch (Exception e)
        {
          logger.Error(String.Format("Cannot load assembly '{0}'", assemblyName), e);
          throw;
        }
         
        Check.Require(assembly != null, String.Format("Failed to load assembly '{0}'", assemblyName));

        try
        {
          Type[] assemblyTypes = assembly.GetTypes();

          types.AddRange(assemblyTypes.Where(type => type.IsSubclassOf(typeof (BaseDto))));
        }
        catch (ReflectionTypeLoadException rtle)
        {
          logger.Error(String.Format("Cannot load types from assembly {0}:", assemblyName));
          foreach (Exception exception in rtle.LoaderExceptions)
          {
            logger.Error(String.Format("Exception loading type: {0}", exception.Message));
          }
        }
      }

      return types.ToArray();
    }

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("BaseDto");
    #endregion
  }

 
}

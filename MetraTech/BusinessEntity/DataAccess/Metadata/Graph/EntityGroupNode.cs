using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Linq;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  public class EntityGroupNode
  {
    #region Public Properties
    public string EntityGroupName { get; set; }
    public string ExtensionName { get; set; }

    public EntityGraph EntityGraph { get; set; }
    #endregion

    #region Public Methods
   
    #endregion

    #region Public Static Methods
    public static string GetEntityFullName(XElement classElement)
    {
      XAttribute nameAttribute = classElement.Attribute("name");
      Check.Require(nameAttribute != null, 
                    String.Format("Cannot find 'name' attribute for 'class' element in file '{0}'", classElement.BaseUri), 
                    SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(nameAttribute.Value), 
                    String.Format("'name' attribute for 'class' element in file '{0}' cannot be null or empty", classElement.BaseUri), 
                    SystemConfig.CallerInfo);

      string entityName, assemblyName;
      Name.ParseAssemblyQualifiedTypeName(nameAttribute.Value, out entityName, out assemblyName);

      Check.Require(!String.IsNullOrEmpty(entityName),
                     String.Format("Cannot find entity name in file '{0}'", classElement.BaseUri),
                     SystemConfig.CallerInfo);

      return entityName;
    }

    public static XElement GetClassElement(string hbmFile, out ClassType classType)
    {
      classType = ClassType.Unknown;
      XElement classElement = null;

      XElement root = XElement.Load(hbmFile);

      classElement =
         root.Elements().Where(e => e.Name == Name.NHibernateNamespace + "class").SingleOrDefault();

      if (classElement != null)
      {
        // It's a relationship if we find a <meta> element with an attribute called 'attribute' whose value is 'relationship-type'
        XElement relationshipTypeMeta =
          classElement.Elements(Name.NHibernateNamespace + "meta")
            .Where(m => (string)m.Attribute("attribute") == RelationshipEntity.RelationshipTypeAttribute)
            .SingleOrDefault();

        if (relationshipTypeMeta != null)
        {
          // It's a relationship
          classType = ClassType.Relationship;
        }
        else
        {
          // It's a plain class
          classType = ClassType.Plain;
        }
      }
      else
      {
        // Look for sub class
        classElement =
            root.Elements().Where(e => e.Name == Name.NHibernateNamespace + "joined-subclass").SingleOrDefault();
        if (classElement != null)
        {
          classType = ClassType.SubClass;
        }
      }

      return classElement;
    }
    #endregion

    #region Private Methods
   
    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("EntityGroupNode");
    #endregion
  }
}

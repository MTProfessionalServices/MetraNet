using System;
using System.Collections;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MetraNet.MtProperty;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ICE.ExpressionEngine
{
  public static class EEConvert
  {
    public static MtType GetMtType(DataTypeInfo dtInfo)
    {
      var baseType = TypeHelper.GetBaseType(dtInfo.ToString());
      var mtType = TypeFactory.Create(baseType);
      switch (baseType)
      {
        case BaseType.Enumeration:
          var mtEnum = (MetraTech.ExpressionEngine.TypeSystem.EnumerationType) mtType;
          mtEnum.Namespace = dtInfo.EnumSpace;
          mtEnum.Category = dtInfo.EnumType;
          break;
        case BaseType.String:
          if (dtInfo.Length == null)
            ((StringType) mtType).Length = 0;
          else
            ((StringType) mtType).Length = (int) dtInfo.Length;
          break;
      }
      return mtType;
    }

    public static void CopyProperties(ComplexType complexType, PropertyCollection oldCollection, MetraTech.ExpressionEngine.PropertyCollection newCollection)
    {
      foreach (var oldProperty in oldCollection)
      {
        var type = GetMtType(oldProperty.DataTypeInfo);
        var property = MtPropertyFactory.Create(complexType, oldProperty.Name, type, oldProperty.Required, oldProperty.Description);
        newCollection.Add(property);
      }
    }

    public static Entity GetEntity(ElementBase oldEntity)
    {
      ComplexType complexType;
      MetraNetEntityBase entity;
      PropertyCollection propertyCollection;
      switch(oldEntity.ElementType)
      {
        case ElementType.AccountView:
          complexType = ComplexType.AccountView;
          propertyCollection = ((AccountView) oldEntity).Properties;
          var avEntity = EntityFactory.CreateAccountViewEntity(oldEntity.Name, oldEntity.Description);
          entity = avEntity;
          break;
        case ElementType.ProductView:
          complexType = ComplexType.ProductView;
          propertyCollection = ((ProductView) oldEntity).Properties;
          var pvEntity = EntityFactory.CreateProductViewEntity(oldEntity.Name, oldEntity.Description);
          //foreach (var key in ((ProductView)oldEntity).UKConstraints)
          //{
          //  pvEntity.UniqueKey.Add(key);
          //}
          entity = pvEntity;
          break;
        case ElementType.ServiceDefinition:
          complexType = ComplexType.ServiceDefinition;
          propertyCollection = ((ServiceDefinition) oldEntity).Properties;
          var sdEntity = EntityFactory.CreateServiceDefinitionEntity(oldEntity.Name, oldEntity.Description);
          entity = sdEntity;
          break;
        default:
          throw new ArgumentException("Invalid ElementType: " + oldEntity.ElementType);
      }

      entity.Extension = oldEntity.Extension;

      CopyProperties(complexType, propertyCollection, entity.Properties);

      return entity;
    }

    public static void Save(string extensionsDir)
    {
      Save(extensionsDir, ElementType.ServiceDefinition);
      Save(extensionsDir, ElementType.ProductView);
      Save(extensionsDir, ElementType.ServiceDefinition); 
    }

    public static void Save(string extensionsDir, ElementType elementType)
    {
      var elements = Config.Instance.GetElementList(elementType);
      foreach (DictionaryEntry de in elements.Values)
      {
        var entity = (MetraNetEntityBase)GetEntity((ElementBase) de.Value);
        entity.SaveInExtensionsDirectory(extensionsDir);
      }

    }

  }
}

using System;
using System.Collections.Generic;
using System.IO;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    public static class PropertyBagFactory
    {
        public static AccountViewEntity CreateAccountViewEntity(string name, string description)
        {
            return new AccountViewEntity(name, description);
        }

        public static BusinessModelingEntity CreateBusinessModelingEntity(string name, string description)
        {
            return new BusinessModelingEntity(name, description);
        }

        public static ParameterTableEntity CreateParameterTable(string name, string description)
        {
            return new ParameterTableEntity(name, description);
        }
        public static ProductViewEntity CreateProductViewEntity(string name, string description)
        {
            return new ProductViewEntity(name, description);
        }
        
        public static ServiceDefinitionEntity CreateServiceDefinitionEntity(string name, string description)
        {
            return new ServiceDefinitionEntity(name, description);
        }

        public static PropertyBag Create(string propertyBagTypeName, string name, string description)
        {
            switch (propertyBagTypeName)
            {
                case PropertyBagConstants.AccountView:
                    return CreateAccountViewEntity(name, description);
                case PropertyBagConstants.BusinessModelingEntity:
                    return CreateBusinessModelingEntity(name, description);
                case PropertyBagConstants.ParameterTable:
                    return CreateParameterTable(name, description);
                case PropertyBagConstants.ProductView:
                    return CreateProductViewEntity(name, description);
                case PropertyBagConstants.ServiceDefinition:
                    return CreateServiceDefinitionEntity(name, description);
                default:
                    return Create(propertyBagTypeName, name, description);
            }
        }

        public static List<PropertyBag> LoadDirectory(string dirPath, string expectedPropertyBagTypeName)
        {
            var list = new List<PropertyBag>();
            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return list;

            foreach (var fileInfo in dirInfo.GetFiles("*.xml"))
            {
                PropertyBag propertyBag;
                switch (expectedPropertyBagTypeName)
                {
                    case "AccountView":
                        propertyBag = PropertyBag.CreateFromFile <AccountViewEntity> (fileInfo.FullName);
                        break;
                    case "ProductView":
                        propertyBag = PropertyBag.CreateFromFile <ProductViewEntity> (fileInfo.FullName);
                        break;
                    case "ServiceDefinition":
                        propertyBag = PropertyBag.CreateFromFile<ServiceDefinitionEntity>(fileInfo.FullName);
                        break;
                    default:
                        propertyBag = PropertyBag.CreateFromFile<PropertyBag>(fileInfo.FullName);
                        break;
                }

                list.Add(propertyBag);
            }

            return list;
        }

        public static void LoadDirectoryIntoContext(string dirPath, string expectedPropertyBagTypeName, Context context)
        {
            if (context == null)
                throw new ArgumentException("context");

            foreach (var propertyBag in LoadDirectory(dirPath, expectedPropertyBagTypeName))
            {
                context.AddEntity(propertyBag);
                //context.Entities.Add(propertyBag.Name, propertyBag);    
            }
        }

    }
}

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Validations;

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

        public static List<PropertyBag> LoadDirectory(string dirPath, string expectedPropertyBagTypeName, ValidationMessageCollection messages)
        {
            var list = new List<PropertyBag>();
            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return list;

            foreach (var fileInfo in dirInfo.GetFiles("*.xml"))
            {
                PropertyBag propertyBag;

                try
                {
                    switch (expectedPropertyBagTypeName)
                    {
                        case "AccountView":
                            propertyBag = PropertyBag.CreateFromFile<AccountViewEntity>(fileInfo.FullName);
                            break;
                        case "ProductView":
                            propertyBag = PropertyBag.CreateFromFile<ProductViewEntity>(fileInfo.FullName);
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
                catch (Exception exception)
                {
                    if (messages == null)
                        throw;
                    messages.Error(string.Format(CultureInfo.CurrentCulture, Localization.FileLoadError, fileInfo.FullName), exception);
                }
            }

            return list;
        }

        public static void LoadDirectoryIntoContext(string dirPath, string expectedPropertyBagTypeName, Context context)
        {
            if (context == null)
                throw new ArgumentException("context");

            var propertyBags = LoadDirectory(dirPath, expectedPropertyBagTypeName, context.DeserilizationMessages);
            foreach (var propertyBag in propertyBags)
            {
                try
                {
                    context.AddEntity(propertyBag);
                }
                catch (Exception exception)
                {
                    if (context.DeserilizationMessages == null)
                        throw;
                    context.DeserilizationMessages.Error(string.Format(CultureInfo.CurrentCulture, Localization.FileLoadError, propertyBag.ToString()), exception);
                }
            }
        }

    }
}

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    public static class PropertyBagFactory
    {
        public static AccountViewEntity CreateAccountViewEntity(string _namespace, string name, string description)
        {
            return new AccountViewEntity(_namespace, name, description);
        }

        public static BusinessModelingEntity CreateBusinessModelingEntity(string _namespace, string name, string description)
        {
            return new BusinessModelingEntity(_namespace, name, description);
        }

        public static ParameterTableEntity CreateParameterTable(string _namespace, string name, string description)
        {
            return new ParameterTableEntity(_namespace, name, description);
        }
        public static ProductViewEntity CreateProductViewEntity(string _namespace, string name, string description)
        {
            return new ProductViewEntity(_namespace, name, description);
        }
        
        public static ServiceDefinitionEntity CreateServiceDefinitionEntity(string _namespace, string name, string description)
        {
            return new ServiceDefinitionEntity(_namespace, name, description);
        }

        public static PropertyBag Create(string propertyBagTypeName, string _namespace, string name, string description)
        {
            switch (propertyBagTypeName)
            {
                case PropertyBagConstants.AccountView:
                    return CreateAccountViewEntity(_namespace, name, description);
                case PropertyBagConstants.BusinessModelingEntity:
                    return CreateBusinessModelingEntity(_namespace, name, description);
                case PropertyBagConstants.ParameterTable:
                    return CreateParameterTable(_namespace, name, description);
                case PropertyBagConstants.ProductView:
                    return CreateProductViewEntity(_namespace, name, description);
                case PropertyBagConstants.ServiceDefinition:
                    return CreateServiceDefinitionEntity(_namespace, name, description);
                default:
                    return new PropertyBag(_namespace, name, propertyBagTypeName, PropertyBagMode.PropertyBag, description);
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
                    propertyBag.Extension = IOHelper.GetMetraNetExtension(fileInfo.FullName);
                    list.Add(propertyBag);
                }
                catch (Exception exception)
                {
                    if (messages == null)
                        throw;
                    messages.Error(exception, string.Format(CultureInfo.CurrentCulture, Localization.FileLoadError, fileInfo.FullName));
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
                    context.AddPropertyBag(propertyBag);
                }
                catch (Exception exception)
                {
                    if (context.DeserilizationMessages == null)
                        throw;
                    context.DeserilizationMessages.Error(exception, string.Format(CultureInfo.CurrentCulture, Localization.FileLoadError, propertyBag.ToString()));
                }
            }
        }

    }
}

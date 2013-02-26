using System;
using MetraTech.ExpressionEngine.Entities;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    public static class PropertyBagFactory
    {
        public static ProductViewEntity CreateProductViewEntity(string name, string description)
        {
            return new ProductViewEntity(name, description);
        }
        
        public static AccountViewEntity CreateAccountViewEntity(string name, string description)
        {
            return new AccountViewEntity(name, description);
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
                case PropertyBagConstants.ProductView:
                    return CreateProductViewEntity(name, description);
                case PropertyBagConstants.ServiceDefinition:
                    return CreateServiceDefinitionEntity(name, description);
                default:
                    return Create(propertyBagTypeName, name, description);
            }
        }
    }
}

using System;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.MTProperties
{
    public static class PropertyFactory
    {
        public static Property Create(string name, Type type, bool isRequired, string description)
        {
            return PropertyFactory.Create(null, name, type, isRequired, description);
        }

        public static Property Create(string propertyBagTypeName, string name, Type type, bool isRequired, string description)
        {
            if (type == null)
                throw new ArgumentException("type is null");

            switch (propertyBagTypeName)
            {
                case PropertyBagConstants.AccountView:
                    return new AccountViewProperty(name, type, isRequired, description);
                case PropertyBagConstants.BusinessModelingEntity:
                    return new BusinessModelingEntityProperty(name, type, isRequired, description);
                case PropertyBagConstants.ParameterTable:
                    return new ParameterTableProperty(name, type, isRequired, description);
                case PropertyBagConstants.ProductView:
                    return new ProductViewProperty(name, type, isRequired, description);
                case PropertyBagConstants.ServiceDefinition:
                    return new ServiceDefinitionProperty(name, type, isRequired, description);
                default:
                    return new Property(name, type, isRequired, description);
            }
        }
    }
}

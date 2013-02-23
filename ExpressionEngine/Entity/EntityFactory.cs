using System;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    public static class EntityFactory
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

        public static Entity Create(ComplexType type, string name, string description)
        {
            switch (type)
            {
                case ComplexType.AccountView:
                    return CreateAccountViewEntity(name, description);
                case ComplexType.ProductView:
                    return CreateProductViewEntity(name, description);
                case ComplexType.ServiceDefinition:
                    return CreateServiceDefinitionEntity(name, description);
                default:
                    throw new ArgumentException("Invalid Type: " + type);
            }
        }
    }
}

using System;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    public static class MtPropertyFactory
    {
        public static Property Create(ComplexType complexType, string name, MtType type, bool isRequired, string description)
        {
            switch (complexType)
            {
                case ComplexType.AccountView:
                    return new AccountViewProperty(name, type, description);
                case ComplexType.ProductView:
                    return new ProductViewProperty(name, type, description);
                case ComplexType.ServiceDefinition:
                    return new ServiceDefinitionProperty(name, type, description);
                default:
                    return new Property(name, type, description);
            }
        }
    }
}

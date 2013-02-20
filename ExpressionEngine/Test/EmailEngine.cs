using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine.Test
{
    public static class EmailEngine // : IProcessingEngine
    {
        public static void EvalutateExpressions(EmailInstance email, PropertyCollection propertyCollection)
        {
            SetOutput(EmailInstance.ToPropertyName, email.ToExpression.Content, propertyCollection);
            SetOutput(EmailInstance.CcPropertyName, email.CcExpression.Content, propertyCollection);
            SetOutput(EmailInstance.SubjectPropertyName, email.SubjectExpression.Content, propertyCollection);
            SetOutput(EmailInstance.BodyPropertyName, email.BodyExpression.Content, propertyCollection);
        }

        private static void SetOutput(string outputPropertyName, string content, PropertyCollection propertyCollection)
        {
            var property = propertyCollection.Get(outputPropertyName);
            if (property == null)
                throw new ArgumentException("Unable to find output property " + outputPropertyName);
            if (property is ComplexType)
                throw new ArgumentException("Property is a complex type");

            ((Property)property).Value = MergeValues(content, propertyCollection);            
        }

        private static string MergeValues(string content, PropertyCollection propertyCollection)
        {
            if (string.IsNullOrEmpty(content))
                return content;

            //THis isn't designed to be efficient! We're just doing string substituions
            foreach (var property in propertyCollection)
            {
                if (property is ComplexType)
                    throw new ArgumentException("Property is a complex type");

                var pattern = "{" + property.Name + "}";
                content = content.Replace(pattern, ((Property)property).Value);
            }
            return content;
        }
    }
}

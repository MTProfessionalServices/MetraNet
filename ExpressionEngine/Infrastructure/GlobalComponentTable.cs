using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Infrastructure
{
    public class GlobalComponentTable : IEnumerable<ComponentReference>
    {
        #region Properties
        private Context Context;
        private Dictionary<string, ComponentReference> Components = new Dictionary<string, ComponentReference>(StringComparer.InvariantCultureIgnoreCase);
        #endregion

        #region Constructor
        public GlobalComponentTable(Context context)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            Context = context;
        }
        #endregion

        #region Methods
        public bool Add(ComponentReference componentReference, ValidationMessageCollection messages)
        {
            string errorMessage;
            var result = Add(componentReference, out errorMessage);
            if (!result)
                messages.Error(errorMessage);
            return result;
        }
        public bool Add(ComponentReference componentReference, out string errorMessage)
        {
            if (componentReference == null)
                throw new ArgumentException("componentReference is null");

            if (Components.ContainsKey(componentReference.FullName))
            {
                errorMessage =
                    string.Format(string.Format(CultureInfo.CurrentCulture, "Duplicate name {0}", componentReference.FullName));
                return false;
            }

            Components.Add(componentReference.FullName, componentReference);
            errorMessage = null;
            return true;
        }

        public ValidationMessageCollection Load()
        {
            var messages = new ValidationMessageCollection();
            Components.Clear();

            //Property bags are most critical, load them first
            foreach (var propertyBag in Context.PropertyBags)
            {
                if (Add(propertyBag.GetComponentReference(), messages))
                {
                    foreach (var property in propertyBag.Properties)
                    {
                        Add(property.GetComponentReference(), messages);
                    }
                }
            }

            //Load Enumerations
            foreach (var enumCategory in Context.EnumManager.Categories)
            {
                if (Add(enumCategory.GetComponentReference(), messages))
                {
                    foreach (var enumItem in enumCategory.Items)
                    {
                        Add(enumItem.GetComponentReference(), messages);
                    }
                }
            }

            //Load the functions
            //Load AQGs

            return messages;
        }
        #endregion

        #region IEnumerable Methods
        IEnumerator<ComponentReference> IEnumerable<ComponentReference>.GetEnumerator()
        {
            return Components.Values.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}

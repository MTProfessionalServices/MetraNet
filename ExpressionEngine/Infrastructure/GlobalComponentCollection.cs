using System;
using System.Collections.Generic;
using System.Globalization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Infrastructure
{
    public class GlobalComponentCollection : IEnumerable<IComponent>
    {
        #region Properties
        private Context Context;
        private Dictionary<string, IComponent> Components = new Dictionary<string, IComponent>(StringComparer.InvariantCultureIgnoreCase);
        private List<IComponent> _duplicates = new List<IComponent>();
        public IEnumerable<IComponent> Duplicates { get { return _duplicates.ToArray(); } }
        #endregion

        #region Constructor
        public GlobalComponentCollection(Context context)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            Context = context;
        }
        #endregion

        #region Methods
        private bool Add(IComponent component, ValidationMessageCollection messages)
        {
            string errorMessage;
            var result = Add(component, out errorMessage);
            if (!result)
                messages.Error(errorMessage);
            return result;
        }

        private bool Add(IComponent component, out string errorMessage)
        {
            if (component == null)
                throw new ArgumentException("componentReference is null");

            if (Components.ContainsKey(component.FullName))
            {
                errorMessage = string.Format(CultureInfo.CurrentCulture, "Duplicate name {0}", component.FullName);
                _duplicates.Add(component);
                return false;
            }

            Components.Add(component.FullName, component);
            errorMessage = null;
            return true;
        }

        public IComponent Get(string fullName)
        {
            IComponent component;
            Components.TryGetValue(fullName, out component);
            return component;
        }

        public bool Exists(string fullName)
        {
            return Get(fullName) != null;
        }

        public ValidationMessageCollection Load()
        {
            var messages = new ValidationMessageCollection();
            Components.Clear();
            _duplicates.Clear();

            //Property bags are most critical, load them first
            foreach (var propertyBag in Context.PropertyBags)
            {
                if (Add(propertyBag, messages))
                {
                    foreach (var property in propertyBag.Properties)
                    {
                        Add(property, messages);
                    }
                }
            }

            //Load Enumerations
            foreach (var enumCategory in Context.EnumManager.Categories)
            {
                if (Add(enumCategory, messages))
                {
                    foreach (var enumItem in enumCategory.Items)
                    {
                        Add(enumItem, messages);
                    }
                }
            }

            //Load the functions
            //Load AQGs

            return messages;
        }


        //public void WriteCsvFile(string filePath)
        //{
        //    IOHelper.EnsureDirectoryExits(Path.GetDirectoryName(filePath));
        //    var sb = new StringBuilder();
        //    foreach (var component in Components.Values)
        //    {
        //        sb.AppendLine(string.Format(CultureInfo.InvariantCulture, "{0},{1}", component.FullName, component.ComponentType));
        //    }

        //    File.WriteAllText(filePath, sb.ToString());
        //}
        #endregion

        #region IEnumerable Methods
        IEnumerator<IComponent> IEnumerable<IComponent>.GetEnumerator()
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

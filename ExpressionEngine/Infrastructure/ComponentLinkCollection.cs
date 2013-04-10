using System;
using System.Collections.Generic;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Components
{
    public class ComponentLinkCollection : IEnumerable<ComponentLink>
    {
        #region Properties
        private List<ComponentLink> Links = new List<ComponentLink>();
        #endregion

        #region Methods
        public ComponentLink Add(ComponentLink link)
        {
            Links.Add(link);
            return link;
        }

        public ComponentLink Add(ComponentType type, object linkObject, string linkObjectPropertyName, bool isRequired, string userContext)
        {
            var link = new ComponentLink(type, linkObject, linkObjectPropertyName, isRequired, userContext);
            Links.Add(link);
            return link;
        }

        public void Validate(ValidationMessageCollection messages, Context context)
        {
            if (messages == null)
                throw new ArgumentException("messages is null");
            if (context == null)
                throw new ArgumentException("context is null");

            foreach (var link in Links)
            {
                link.Validate(messages, context);
            }
        }

        #endregion

        #region IEnumerable
        IEnumerator<ComponentLink> IEnumerable<ComponentLink>.GetEnumerator()
        {
            return Links.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}

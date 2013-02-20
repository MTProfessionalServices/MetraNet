using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class ExpressionParseResults
    {
        #region Properties
        public bool IsValid { get; set; }
        public ValidationMessageCollection  Messages {get; private set;}
        public object ParseTree { get; set; }
        public DataTypeInfo DataTypeInfo { get; set; }
        public PropertyCollection Parameters { get; private set; }
        #endregion

        #region Constructor
        public ExpressionParseResults()
        {
            Messages = new ValidationMessageCollection();
            Parameters = new PropertyCollection(this);
            IsValid = false;
        }
        #endregion

        #region Methods
        public void BindResultsToContext(Context context)
        {
            if (context == null)
                new ArgumentNullException("context");

            foreach (var parameter in Parameters)
            {
                var property = context.GetRecursive(parameter.Name);
                if (property != null)
                {
                    parameter.Description = property.Description;
                    parameter.DataTypeInfo = property.DataTypeInfo.Copy();
                }
                else if (parameter.Direction == Property.DirectionType.Input || parameter.Direction == Property.DirectionType.InOut)
                {
                    parameter.Description = null;
                    parameter.DataTypeInfo.BaseType = BaseType.Unknown;

                    //Would be really nice to provide line/column number here. Need parse tree to do that
                    Messages.Error(string.Format(Localization.UnableToFindProperty, parameter.Name));
                }
            }
        }
        #endregion
    }
}

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
        public string Message { get; set; }
        public int LineNumber { get; set; }
        public int ColumnNumber { get; set; }
        public object ParseTree { get; set; }
        public DataTypeInfo DataTypeInfo { get; set; }
        public PropertyCollection Parameters { get; private set; }
        #endregion

        #region Constructor
        public ExpressionParseResults()
        {
            Parameters = new PropertyCollection(this);
            IsValid = false;
        }
        #endregion

        #region Methods
        public bool BindResultsToContext(Context context)
        {
            if (context == null)
                new ArgumentNullException("context");

            bool allInputsBound = true;
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
                    allInputsBound = false;
                }
            }

            return allInputsBound;
        }
        #endregion
    }
}

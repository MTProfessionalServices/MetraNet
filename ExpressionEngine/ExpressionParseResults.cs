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
        }
        #endregion
    }
}

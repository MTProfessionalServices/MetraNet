using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class Function : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The function's name
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// The category. Used for filtering. Ensure that proper case is used.
        /// This should be localized in future.
        /// </summary>
        public string Category { get; set; }

        /// <summary>
        /// The description. Used in tool tips, online help, etc.
        /// This should be localized in future.
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// The parameters that are fixed.
        /// </summary>
        public PropertyCollection FixedParameters { get; set; }

        /// <summary>
        /// Some functions suport multiple arguments. For example, Min(a, b, c...). At this point, we require that they all be of the same 
        /// datatype which is set by this property. 
        /// DynamicParameterMin property
        /// </summary>
        public Property DynamicParameterPrototype { get; set; }

        /// <summary>
        /// The minimum number of dynamic parameters. Min, Max, Average would all be 2.
        /// </summary>
        public int DynamicParameterMin { get; set; }

        public string ToolTip { get { return Description; } }
        public string Image { get { return "Function.png"; } }
        #endregion

        #region Constructor
        public Function(string name, string category, string description)
        {
            Name = name;
            Category = category;
            Description = description;

            FixedParameters = new PropertyCollection(this);
            DynamicParameterPrototype = null;
        }
        #endregion
    
        #region Methods
        public string ToExpression{get
        {
            return string.Format("{0}()", Name);
        }}

        #endregion
    }
}

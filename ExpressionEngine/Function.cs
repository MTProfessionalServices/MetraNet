using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

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
        /// The data type that the function returns
        /// </summary>
        public DataTypeInfo ReturnType { get; set; }

        /// <summary>
        /// The description. Used in tool tips, online help, etc.
        /// This should be localized in future.
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// Indicates what version of MetraNet the function is first supported
        /// </summary>
        public string FirstSupported { get; set; }

        /// <summary>
        /// The parameters that are fixed.
        /// </summary>
        public PropertyCollection FixedParameters { get; set; }

        /// <summary>
        /// Some functions suport multiple arguments. For example, Min(a, b, c...). At this point, we require that they all be of the same 
        /// datatype which is set by this property. 
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
        public Function()
        {
        }

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

        public string ToExpressionSnippet
        {
            get
            {
                return string.Format("{0}()", Name);
            }
        }


        public static Function CreateFunctionFromFile(string filePath)
        {
            try
            {
                var func = new Function(null, null, null);
                var doc = new XmlDocument();
                var rootNode = doc.LoadAndGetRootNode(filePath, "TreeLogicFunction");
                func.Name = rootNode.GetChildTag("Name");
                func.Category = rootNode.GetChildTag("Category");
                func.ReturnType = DataTypeInfo.CreateFromXmlNode(rootNode.GetChildNode("ReturnType"));
                var fixedArgsNode = rootNode.SelectSingleNode("FixedArguments");
                if (fixedArgsNode != null)
                    func.FixedParameters.LoadFromXmlNode(fixedArgsNode, "Argument");
                return func;
            }
            catch (Exception ex)
            {
                throw new Exception(string.Format("Unable to load Function file {0} [{1}]", filePath, ex.Message));
            }
        }

        #endregion
    }
}

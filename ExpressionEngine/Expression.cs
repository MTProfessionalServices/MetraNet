using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// This is a place holder. Need to think through. We probably will want expression templates.
    /// </summary>
    public class Expression
    {
        #region Enums
        public enum ExpressionTypeEnum { 
            AQG,
            UQG,
            Logic,
            Email,
            Message ///Merging of localized text (e.g., email templates, sms messages, etc.)
        }
        #endregion

        #region Static Properties
        public static readonly string[] EqualityOperators = new string[] { "==", "eq" };
        public static readonly string[] InequalityOperators = new string[] { "!=", "nq" };
        #endregion

        #region Properties

        public string Name { get; set; }

        public string Description{get;set;}

        /// <summary>
        /// The type of expression
        /// </summary>
        public readonly ExpressionTypeEnum Type;

        /// <summary>
        /// This probably belongs in a expression template as opposed to an instance
        /// </summary>
        public List<string> EntityParameters = new List<string>();

        public ExpressionInfo Info { get { return ExpressionInfo.Items[Type]; } }

        /// <summary>
        /// The actual expression
        /// </summary>
        public string Content { get; set; }

        /// <summary>
        /// The data type that the Expression returns. You must invoke parse to update this.
        /// Need to decide how this interact with an output parameter (need to think it through)
        /// </summary>
        public Property ReturnType { get; private set; }

        /// <summary>
        /// The parameters that the Expression interacts with. Note that the Direction
        /// can be Input, Output, or InOut. You must invoke Parse() to update this.
        /// </summary>
        public PropertyCollection Parameters { get; private set; }
        #endregion

        #region Constructor
        public Expression(ExpressionTypeEnum type, string contents, string name=null)
        {
            Type = type;
            Content = contents;
            Name = name;
            Parameters = new PropertyCollection(this);
            _DemoLoader.LoadInputsOutputs(this);
        }
        #endregion

        #region Methods
        /// <summary>
        /// Parses the contents and updates the ReturnType and Parameters properties. If successful, true is
        /// returned. Otherwise false is returned and the errorMsg, lineNumer and columnNumber are set.
        /// </summary>
        public bool Parse(out string errorMsg, out int lineNumber, out int columnNumber)
        {
            throw new NotImplementedException();
        }

        public static Expression CreateFromFile(string filePath)
        {
            var doc = new XmlDocument();
            var rootNode = doc.LoadAndGetRootNode(filePath, "Expression");
            var name = rootNode.GetChildTag("Name");
            var content = rootNode.GetChildTag("Content");
            var description = rootNode.GetChildTag("Description");
            var type = rootNode.GetChildEnum<ExpressionTypeEnum>("Type");
            var exp = new Expression(type, content, name);
            foreach (var entity in rootNode.SelectNodes("EntityParameters/Entity"))
            {
                exp.EntityParameters.Add(((XmlNode)entity).InnerText);
            }
            exp.Description = description;
            return exp;
        }
        #endregion

    }
}

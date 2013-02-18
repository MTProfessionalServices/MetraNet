using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    public class EmailTemplate : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EmailTemplate.png"; } }
        public string ToExpressionSnippet { get { return string.Empty; } }
        public List<string> EntityParameters = new List<string>();
        public Expression ToExpression = new Expression(Expression.ExpressionTypeEnum.Email, null);
        public Expression CcExpresson = new Expression(Expression.ExpressionTypeEnum.Email, null);
        public Expression SubjectExpression = new Expression(Expression.ExpressionTypeEnum.Email, null);
        public Expression BodyExpression = new Expression(Expression.ExpressionTypeEnum.Email, null);
        public string Description { get; set; }
        #endregion

        #region Methods
        public static EmailTemplate CreateFromFile(string filePath)
        {
            var template = new EmailTemplate();

            var doc = new XmlDocument();
            var rootNode = doc.LoadAndGetRootNode(filePath, "EmailTemplate");
            template.Name = rootNode.GetChildTag("Name");
            template.ToExpression.Content = rootNode.GetChildTag("To");
            template.CcExpresson.Content = rootNode.GetChildTag("Cc");
            template.SubjectExpression.Content = rootNode.GetChildTag("Subject");
            template.BodyExpression.Content = rootNode.GetChildTag("Body");
            template.Description = rootNode.GetChildTag("Description");
            foreach (var entity in rootNode.SelectNodes("EntityParameters/Entity"))
            {
                template.EntityParameters.Add(((XmlNode)entity).InnerText);
            }
            return template;
        }

        #endregion
    }
}

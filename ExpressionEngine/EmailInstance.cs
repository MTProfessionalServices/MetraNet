using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Collections.ObjectModel;
using System.IO;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// This is a template and an instance mashed up. Need to seperate going forward.
    /// 
    /// The _isInitialized is used because of the way that serialization works and the desire to not
    /// write out all of the Expression properties for each of the 4 expressions in an Email. I'm not
    /// happy with the way it works and we probably need to rethink. If you have questions, ask Scott
    /// </summary>
    [DataContract]
    public class EmailInstance
    {
        #region Properties
        /// <summary>
        // See main description
        /// </summary>
        private bool _isInitalized = false;

        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public string EmailTemplate { get; set; }

        /// <summary>
        /// Who the email is being sent to (must have at least one)
        /// </summary>
        public Expression ToExpression { get { if (!_isInitalized) Initalize(); return _toExpression; } }
        private Expression _toExpression;
        [DataMember]
        private string _toExpressionContent { get { return ToExpression.Content; } set { ToExpression.Content = value; } }

        /// <summary>
        /// Who, if anyone, will recieve a carbon copy
        /// </summary>
        public Expression CcExpression { get { if (!_isInitalized) Initalize(); return _ccExpression; } }
        private Expression _ccExpression;
        [DataMember]
        private string _ccExpressionContent { get { return CcExpression.Content; } set { CcExpression.Content = value; } }

        /// <summary>
        /// The email's subject
        /// </summary>
        public Expression SubjectExpression { get { if (!_isInitalized) Initalize(); return _subjectExpression; } }
        private Expression _subjectExpression;
        [DataMember]
        private string _subjectExpressionContent{ get { return SubjectExpression.Content; } set { SubjectExpression.Content = value; } }

        /// <summary>
        /// The email's body
        /// </summary>
        public Expression BodyExpression { get { if (!_isInitalized) Initalize(); return _bodyExpression; } }
        private Expression _bodyExpression;
        [DataMember]
        private string _bodyExpressionContent { get { return BodyExpression.Content; } set { BodyExpression.Content = value; } }

        /// <summary>
        /// The description TODO: localize
        /// </summary>
        [DataMember]
        public string Description { get; set; }
        #endregion

        #region GUI Helper Properties (move in future)
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EmailTemplate.png"; } }
        #endregion

        #region Initalize

        private void Initalize()
        {
            _toExpression = new Expression(Expression.ExpressionTypeEnum.Email, null, null);
            _ccExpression = new Expression(Expression.ExpressionTypeEnum.Email, null, null);
            _subjectExpression = new Expression(Expression.ExpressionTypeEnum.Email, null, null);
            _bodyExpression = new Expression(Expression.ExpressionTypeEnum.Email, null, null);
            _isInitalized = true;
        }


        #endregion

        #region Methods

        public void UpdateEntityParameters()
        {
            if (string.IsNullOrEmpty(EmailTemplate))
                return;

            //TODO... we need to think through where this is retrieved from!
            EmailTemplate template;
            if (!DemoLoader.GlobalContext.EmailTemplates.TryGetValue(EmailTemplate, out template))
                return;

            foreach (var expression in GetExpressions())
            {
                expression.EntityParameters.AddRange(template.EntityParameters);
            }
        }

        public List<Expression> GetExpressions()
        {
            var expressions = new List<Expression>();
            expressions.Add(ToExpression);
            expressions.Add(CcExpression);
            expressions.Add(SubjectExpression);
            expressions.Add(BodyExpression);
            return expressions;
        }

        public ExpressionParseResults Parse()
        {
            var summaryResult = new ExpressionParseResults();
            foreach (var expression in GetExpressions())
            {
                var result = expression.Parse();
                if (!result.IsValid)
                    return result;

                foreach (var parameter in result.Parameters)
                {
                    var param = summaryResult.Parameters.Get(parameter.Name);
                    if (param == null)
                        summaryResult.Parameters.Add(parameter);
                }
            }
            return summaryResult;
        }
        public static EmailInstance CreateFromFile(string file)
        {
            var fs = new FileStream(file, FileMode.Open);
            var reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(EmailInstance));
            var instance = (EmailInstance)ser.ReadObject(reader, true);
            fs.Close();
            reader.Close();
            return instance;
        }

        public void Save(string dirPath)
        {
            var filePath = string.Format(@"{0}\{1}.xml", dirPath, Name);
            var writer = new FileStream(filePath, FileMode.Create);
            var ser = new DataContractSerializer(typeof(EmailInstance));
            ser.WriteObject(writer, this);
            writer.Close();
        }
        #endregion
    }
}

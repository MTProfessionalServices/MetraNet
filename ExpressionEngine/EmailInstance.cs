using System.Collections.ObjectModel;
using System.Runtime.Serialization;
using System.Globalization;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// The _isInitialized is used because of the way that serialization works and the desire to not
    /// write out all of the Expression properties for each of the 4 expressions in an Email. I'm not
    /// happy with the way it works and we probably need to rethink. If you have questions, ask Scott
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class EmailInstance
    {
        #region Constants
        public const string ToPropertyName = "To";
        public const string CCPropertyName = "Cc";
        public const string SubjectPropertyName = "Subject";
        public const string BodyPropertyName = "Body";
        #endregion

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
        public Expression CCExpression { get { if (!_isInitalized) Initalize(); return _ccExpression; } }
        private Expression _ccExpression;
        [DataMember]
        private string _ccExpressionContent { get { return CCExpression.Content; } set { CCExpression.Content = value; } }

        /// <summary>
        /// The email's subject
        /// </summary>
        public Expression SubjectExpression { get { if (!_isInitalized) Initalize(); return _subjectExpression; } }
        private Expression _subjectExpression;
        [DataMember]
        private string _subjectExpressionContent { get { return SubjectExpression.Content; } set { SubjectExpression.Content = value; } }

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
            _toExpression = new Expression(ExpressionType.Email, null, null);
            _ccExpression = new Expression(ExpressionType.Email, null, null);
            _subjectExpression = new Expression(ExpressionType.Email, null, null);
            _bodyExpression = new Expression(ExpressionType.Email, null, null);
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

        public Collection<Expression> GetExpressions()
        {
            var expressions = new Collection<Expression>();
            expressions.Add(ToExpression);
            expressions.Add(CCExpression);
            expressions.Add(SubjectExpression);
            expressions.Add(BodyExpression);
            return expressions;
        }

        public ExpressionParseResults Parse()
        {
            var summaryResult = new ExpressionParseResults();

            //Parse all of the inputs
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

            //Hardcode the outputs
            AddOutput(summaryResult.Parameters, ToPropertyName);
            AddOutput(summaryResult.Parameters, CCPropertyName);
            AddOutput(summaryResult.Parameters, SubjectPropertyName);
            AddOutput(summaryResult.Parameters, BodyPropertyName);

            return summaryResult;
        }

        public ExpressionParseResults ParseAndBindResults(Context context)
        {
            var results = Parse();
            results.BindResultsToContext(context);
            return results;
        }

        private void AddOutput(PropertyCollection properties, string name)
        {
            var description = string.Format(CultureInfo.InvariantCulture, "The email's {0} field.", name);
            var property = Property.CreateString(name, true, description, 0);
            property.Direction = Direction.Output;
            properties.Add(property);
        }

        public static EmailInstance CreateFromFile(string file)
        {
            return IOHelper.CreateFromFile<EmailInstance>(file);
        }

        public void Save(string dirPath)
        {
            var filePath = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.xml", dirPath, Name);
            IOHelper.Save(filePath, this);
        }
        #endregion
    }
}

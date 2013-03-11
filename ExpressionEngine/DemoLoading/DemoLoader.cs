using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Placeholders;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;


namespace MetraTech.ExpressionEngine
{
    //this is a total mess that loads data into the GlobalContext.... needs to replaced with clean data loading
    public static class DemoLoader
    {
        #region Properties
        public const string DirPath = @"C:\ExpressionEngine";
        public static string TopLevelDataDir = Path.Combine(DirPath, "Data");
        private static string DataPath;
        #endregion

        #region General

        public static Context CreateContext(ProductType product, string subDir)
        {
            Context context;
            DataPath = Path.Combine(TopLevelDataDir, subDir);

            if (product == ProductType.MetraNet)
            {
                context = Context.LoadExtensions(Path.Combine(DataPath, "Extensions"));
                LoadXqg(context, ExpressionType.Aqg, Path.Combine(DataPath, "AqgExpressions.csv"));
                LoadXqg(context, ExpressionType.Uqg, Path.Combine(DataPath, "UqgExpressions.csv"));
            }
            else
            {
                context = Context.LoadMetanga(DataPath);
            }

            LoadFunctions(context);
            LoadExpressions(context);
            LoadEmailTemplates(context, Path.Combine(DataPath, "EmailTemplates"));
            LoadEmailInstances(context, Path.Combine(DataPath, "EmailInstances"));
            context.LoadPageLayouts();

            return context;
        }


        #endregion

        #region Expressions
        public static void LoadExpressions(Context context)
        {
            var dirInfo = new DirectoryInfo(Path.Combine(DataPath, "Expressions"));
            if (!dirInfo.Exists)
                return;

            foreach (var fileInfo in dirInfo.GetFiles("*.xml"))
            {
                var exp = Expression.CreateFromFile(fileInfo.FullName);
                context.Expressions.Add(exp.Name, exp);
            }
        }
        #endregion

        #region XQGs

        public static void LoadXqg(Context context, ExpressionType type, string filePath)
        {
            if (context == null)
                throw new ArgumentException("context");

            if (!File.Exists(filePath))
                return;

            var lines = File.ReadAllLines(filePath);
            for (int index = 1; index < lines.Length; index++)
            {
                var cols = lines[index].Split(',');
                var name = cols[0];
                var expression = cols[1];
                var description = string.Empty;
                switch (type)
                {
                    case ExpressionType.Aqg:
                        var aqg = new Aqg(name, description, expression);
                        context.Aqgs.Add(aqg.Name, aqg);
                        break;
                    case ExpressionType.Uqg:
                        var uqg = new Uqg(name, description, expression);
                        context.Uqgs.Add(uqg.Name, uqg);
                        break;
                    default:
                        throw new NotImplementedException();
                }
            }
        }
        #endregion

        #region Emails
        public static void LoadEmailInstances(Context context, string dirPath)
        {
            if (context == null)
                throw new ArgumentException("context");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return;
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var emailInstance = EmailInstance.CreateFromFile(file.FullName);
                context.EmailInstances.Add(emailInstance.Name, emailInstance);
            }
        }
        public static void LoadEmailTemplates(Context context, string dirPath)
        {
            if (context == null)
                throw new ArgumentNullException("context");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return;
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var emailTemplate = EmailTemplate.CreateFromFile(file.FullName);
                context.EmailTemplates.Add(emailTemplate.Name, emailTemplate);
            }
        }
        #endregion

        #region Functions
        public static void LoadFunctions(Context context)
        {
            var dirInfo = new DirectoryInfo(Path.Combine(DirPath, @"Reference\Functions"));
            foreach (var file in dirInfo.GetFiles("*.xml"))
            {
                var func = Function.CreateFromFile(file.FullName);
                context.AddFunction(func);
            }
        }
        #endregion
    }
}

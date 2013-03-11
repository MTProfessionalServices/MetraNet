using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using MetraTech.ExpressionEngine;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Validations.Enumerations;

namespace PropertyGui
{
    /// <summary>
    /// Simple class to facilitate a future Model View Controller (or similar model). To be clear this is just a collection of methods and 
    /// in no way a MVC.
    /// </summary>
    public static class MvcAbstraction
    {
        #region Enums
        public enum ViewModeType { Properties, Entities, Functions, Enumerations, AQGs, UQGs, InputsOutputs, Emails, PageLayouts, Expressions }
        #endregion

        #region Methods

        /// <summary>
        /// Returns a list of ViewModes that are applicable to the specified Expression. If no
        /// Expression is supplied, all ViewModes are returned. Used to load a filter combo box.
        /// </summary>
        public static List<ViewModeType> GetRelevantViewModes(Expression expression = null)
        {
            var viewModes = new List<ViewModeType>();

            //If no expression, then show almost everything (i.e., no filter)
            if (expression == null)
            {
                foreach (var item in Enum.GetValues(typeof(ViewModeType)))
                {
                    if ((ViewModeType)item == ViewModeType.InputsOutputs)
                        continue;

                    viewModes.Add((ViewModeType)item);
                }
                return viewModes;
            }

            if (expression.Info.SupportsAqgs)
                viewModes.Add(ViewModeType.AQGs);
            if (expression.Info.SupportsUqgs)
                viewModes.Add(ViewModeType.UQGs);
            if (expression.Info.SupportedEntityTypes.Count > 0)
                viewModes.Add(ViewModeType.Entities);

            viewModes.Add(ViewModeType.Properties);
            viewModes.Add(ViewModeType.Enumerations);
            viewModes.Add(ViewModeType.Functions);
            viewModes.Add(ViewModeType.InputsOutputs);

            return viewModes;
        }

        public static List<string> GetRelevantEntityTypes(Context context, Expression expression = null)
        {
            var types = new List<string>();

            if (context.ProductType == ProductType.Metanga)
            {
                foreach (var propertyBag in context.PropertyBags)
                {
                    types.Add(propertyBag.Name);
                }
            }
            else
            {
                foreach (var propertyBagTypeName in TypeHelper.MsixEntityTypes)
                {
                    if (expression == null || expression.Info.SupportedEntityTypes.Contains(propertyBagTypeName))
                        types.Add(propertyBagTypeName);
                }
            }

            if (types.Count > 1 && !types.Contains(PropertyBagConstants.AnyFilter))
                types.Add(PropertyBagConstants.AnyFilter);

            return types;
        }

        public static MessageBoxIcon GetMessageBoxIcon(SeverityType severity)
        {
            switch (severity)
            {
                case SeverityType.Error:
                    return MessageBoxIcon.Stop;
                case SeverityType.Warn:
                    return MessageBoxIcon.Warning;
                default:
                    return MessageBoxIcon.Information;
            }
        }

        #endregion

        public static Image GetOverlayImage(Image baseImage, Image overlayImage)
        {
            var g = Graphics.FromImage(baseImage);
            g.DrawImageUnscaled(overlayImage, 0, 0);
            return baseImage;
        }

    }
}

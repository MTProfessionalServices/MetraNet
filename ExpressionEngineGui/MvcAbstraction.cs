using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    /// <summary>
    /// Simple class to facilitate a future Model View Controller (or similar model). To be clear this is just a collection of methods and 
    /// in no way a MVC.
    /// </summary>
    public static class MvcAbstraction
    {
        #region Enums
        public enum ViewModeType { Properties, Entities, Functions, Enums, AQGs, UQGs, InputsOutputs, UoMs, Emails }
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
            viewModes.Add(ViewModeType.Enums);
            viewModes.Add(ViewModeType.Functions);
            viewModes.Add(ViewModeType.InputsOutputs);
            viewModes.Add(ViewModeType.UoMs);

            return viewModes;
        }

        public static List<ComplexType.ComplexTypeEnum> GetRelevantEntityTypes(Context.ProductTypeEnum product, Expression expression = null)
        {
            var types = new List<ComplexType.ComplexTypeEnum>();

            if (product == Context.ProductTypeEnum.Metanga)
            {
                types.Add(ComplexType.ComplexTypeEnum.Metanga);
                return types;
            }

            foreach (var value in Enum.GetValues(typeof(ComplexType.ComplexTypeEnum)))
            {
                var type = (ComplexType.ComplexTypeEnum)value;
                if (expression == null || expression.Info.SupportedEntityTypes.Contains(type))
                    types.Add((ComplexType.ComplexTypeEnum)type);
            }

            if (types.Count > 1 && !types.Contains(ComplexType.ComplexTypeEnum.Any))
                types.Add(ComplexType.ComplexTypeEnum.Any);

            return types;
        }

        #endregion
    }
}

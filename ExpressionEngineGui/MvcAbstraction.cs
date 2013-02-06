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
        public enum ViewModeType { Properties, Entities, Functions, Enums, AQGs, UQGs, InputsOutputs }
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

            return viewModes;
        }

        public static List<Entity.EntityTypeEnum> GetRelevantEntityTypes(Expression expression = null)
        {
            var types = new List<Entity.EntityTypeEnum>();

            foreach (var value in Enum.GetValues(typeof(Entity.EntityTypeEnum)))
            {
                var type = (Entity.EntityTypeEnum)value;
                if (expression == null || expression.Info.SupportedEntityTypes.Contains(type))
                    types.Add((Entity.EntityTypeEnum)type);
            }

            if (types.Count > 1 && !types.Contains(Entity.EntityTypeEnum.Any))
                types.Add(Entity.EntityTypeEnum.Any);

            return types;
        }
        #endregion
    }
}

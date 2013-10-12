// -----------------------------------------------------------------------
// <copyright file="PropertyName.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace MetraTech.Quoting
{
    using System;
    using System.Linq.Expressions;

    /// <summary>
    /// Gets property cals as string
    /// </summary>
    public class PropertyName<Class>
    {
        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="property"> class propert</param>
        /// <returns>propertname as string</returns>
        public static string GetPropertyName<T>(Expression<Func<Class, T>> property)
        {
            MemberExpression memberExpression = (MemberExpression)property.Body;
            return memberExpression.Member.Name;
        }
    }
}

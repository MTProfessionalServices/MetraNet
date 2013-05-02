using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Agreements.Models;
using MetraTech.Interop.QueryAdapter;
using MetraTech.DataAccess;

namespace AgreementTemplate.Test
{


    /// <summary>
    /// The TestUtilities class contains utility methods that can be used by any AgreementTemplate test.
    /// </summary>
    public class TestUtilities
    {

        /// <summary>
        /// Removes all agreement templates, along with their core template properties
        /// and core agreement properties, from the database.
        /// Removes all rows from the tables t_agr_template, t_agr_properties, and t_agr_template_entity_map.
        /// </summary>
        public static void CleanDatabase()
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
                    "delete from t_agr_properties; delete from t_agr_template_entity_map; delete from t_agr_template"))
                {
                    stmt.ExecuteNonQuery();
                }
            }
        }


        /// <summary>
        /// A quick and dirty equality tester for agreement template view models.
        /// </summary>
        /// <param name="left">first model</param>
        /// <param name="right">second model</param>
        /// <returns>true iff the two models are considered equal for the purposes of unit testing</returns>
        public static bool UT_Equal(AgreementTemplateViewModel left, AgreementTemplateViewModel right)
        {
            return ((left.AgreementTemplateId == right.AgreementTemplateId) &&
                    (left.CoreTemplateProperties.AgreementTemplateNameId == right.CoreTemplateProperties.AgreementTemplateNameId) &&
                    (left.CoreTemplateProperties.AgreementTemplateDescId == right.CoreTemplateProperties.AgreementTemplateDescId) &&
                    (left.CoreTemplateProperties.AvailableStartDate == right.CoreTemplateProperties.AvailableStartDate));
        }


        /// <summary>
        /// Generic method that compares two objects of the same type for equality, as required by the unit tests.
        /// Unit test equality might not be as stringent as Equals(); some properties might not be significant for unit tests.
        /// </summary>
        /// <param name="left">first object</param>
        /// <param name="right">second object</param>
        /// <returns>true iff the two objects are considered equal for the purposes of unit testing</returns>
        public static bool UT_Equal<T>(T left, T right) where T : class
        {
/*
            Type tType = typeof(T);
            Type mType = typeof (AgreementTemplateModel);
            if (tType == mType)
            {
                return true;
            }
 */
            return PublicInstancePropertiesEqual(left, right);
        }


        /// <summary>
        /// Compares two objects of type T and returns a boolean indicating
        /// whether the two objects' public instance properties are equal (via Object.Equals()).
        /// (Source:  http://stackoverflow.com/questions/506096/comparing-object-properties-in-c-sharp)
        /// </summary>
        /// <typeparam name="T">the type of the two objects being compared</typeparam>
        /// <param name="self">first object</param>
        /// <param name="to">second object</param>
        /// <param name="ignore">names of properties to exclude from the comparison</param>
        /// <returns>
        /// true iff all the public instance properties of the two objects
        /// (except for the ignored properties) are equal
        /// </returns>
        public static bool PublicInstancePropertiesEqual<T>(T self, T to, params string[] ignore) where T : class
        {
            if (self != null && to != null)
            {
                Type type = typeof(T);
                List<string> ignoreList = new List<string>(ignore);
                foreach (System.Reflection.PropertyInfo pi in
                         type.GetProperties(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance))
                {
                    if (!ignoreList.Contains(pi.Name))
                    {
                        object selfValue = type.GetProperty(pi.Name).GetValue(self, null);
                        object toValue = type.GetProperty(pi.Name).GetValue(to, null);

                        if ((selfValue != toValue) &&
                            (selfValue == null || !selfValue.Equals(toValue)))
                        {
                            return false;
                        }
                    }
                }
                return true;
            }
            return (self == to);
        }


        /// <summary>
        /// Indicates whether two lists of agreement template models contain the same elements.
        /// Only the template IDs of the elements are compared.
        /// </summary>
        /// <param name="leftList">First list</param>
        /// <param name="rightList">Second list</param>
        /// <returns>true iff the two lists contain the same set of agreement template models</returns>
        public static bool UT_ListEqual(List<AgreementTemplateModel> leftList, List<AgreementTemplateModel> rightList)
        {
            if (leftList == null || rightList == null)
            {
                return (leftList == rightList);
            }
            if (leftList.Count != rightList.Count)
            {
                return false;
            }
            foreach (AgreementTemplateModel leftItem in leftList)
            {
                if (rightList.Where(rightItem => (rightItem.AgreementTemplateId == leftItem.AgreementTemplateId)).Count() == 0)
                {
                    // Nothing in rightList matches template leftItem in leftList.
                    return false;
                }
            }
            return true;
        }


        /// <summary>
        /// Generic method that compares two lists for equality, as required by the unit tests.
        /// The list elements are compared using UT_Equal.
        /// </summary>
        /// <param name="leftList">first list</param>
        /// <param name="rightList">second list</param>
        /// <returns>true iff the contents of the two lists are considered equal for the purposes of unit testing</returns>
        public static bool UT_ListEqual<T>(List<T> leftList, List<T> rightList) where T : class
        {
            if (leftList == null || rightList == null)
            {
                return (leftList == rightList);
            }
            if (leftList.Count != rightList.Count)
            {
                return false;
            }
            foreach (T leftItem in leftList)
            {
                if (rightList.Where(rightItem => UT_Equal(leftItem, rightItem)).Count() == 0)
                {
                    return false;
                }
            }
            return true;
        }


    }
}
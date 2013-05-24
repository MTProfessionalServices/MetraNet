//=============================================================================
// Copyright 2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
//
// MODULE: AllowedFilePostFixes.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;

    using EnumeratedTypes;

    /// <summary>
    /// 
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("A6108B51-CA9E-4F89-859A-D2807308F3CF")]
    public class AllowedFilePostFixes : Dictionary<QueryFileTypeEnum, string>
    {
        /// <summary>
        /// Singleton instance of the AllowedFilePostFixes class.
        /// </summary>
        private static AllowedFilePostFixes allowedFilePostFixes = null;

        /// <summary>
        /// Used to provide synchronized access to this class.
        /// </summary>
        private static object SyncObject = new object();

        /// <summary>
        /// Gets the singleton instance of the AllowedFilePostFixes class
        /// </summary>
        public static AllowedFilePostFixes PostFixes 
        {
            get
            {
                if (AllowedFilePostFixes.allowedFilePostFixes== null)
                {
                    lock (AllowedFilePostFixes.SyncObject)
                    {
                        if (AllowedFilePostFixes.allowedFilePostFixes== null)
                        {
                            var names = Enum.GetNames(typeof(QueryFileTypeEnum));
                            var values = Enum.GetValues(typeof(QueryFileTypeEnum));
                            AllowedFilePostFixes.allowedFilePostFixes = new AllowedFilePostFixes();

                            for (int index = 0; index < names.Length; index++)
                            {
                                QueryFileTypeEnum queryFileTypeEnum = (QueryFileTypeEnum)values.GetValue(index);

                                switch (queryFileTypeEnum)
                                {
                                    case QueryFileTypeEnum.All:
                                        {
                                        }
                                        break;
                                    case QueryFileTypeEnum.DbAccess:
                                        {
                                            AllowedFilePostFixes.allowedFilePostFixes.Add(queryFileTypeEnum, "DbAccess.xml");
                                        }
                                        break;
                                    case QueryFileTypeEnum.Info:
                                        {
                                            AllowedFilePostFixes.allowedFilePostFixes.Add(queryFileTypeEnum, "._Info.xml");
                                        }
                                        break;
                                    default:
                                        {
                                            AllowedFilePostFixes.allowedFilePostFixes.Add(queryFileTypeEnum, string.Concat(".", names[index], ".sql"));
                                        }
                                        break;
                                }
                            }
                        }
                    }
                }

                return AllowedFilePostFixes.allowedFilePostFixes;
            }
        }

        /// <summary>
        /// Prevents a default instance of the AllowdFilePostFixes class from being instantiated.
        /// </summary>
        private AllowedFilePostFixes()
        {
        }
    }
}

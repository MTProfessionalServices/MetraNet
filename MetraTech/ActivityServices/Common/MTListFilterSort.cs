using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Common;

namespace MetraTech.ActivityServices.Common
{
  public delegate string FilterColumnResolver(string propName, ref object propValue, object helper);

  public class MTListFilterSort
  {
    public static void ApplyFilterSortCriteria<T>(IMTBaseFilterSortStatement statement, MTList<T> mtList)
    {
      ApplyFilterSortCriteria<T>(statement, mtList, null, null);
    }

    public static void ApplyFilterSortCriteria<T>(IMTBaseFilterSortStatement statement, MTList<T> mtList, FilterColumnResolver resolver, object helper)
    {
      #region Apply Sorting
      //add sorting info if applies
      if (mtList.SortCriteria != null && mtList.SortCriteria.Count > 0)
      {
        foreach (MetraTech.ActivityServices.Common.SortCriteria sc in mtList.SortCriteria)
        {
          object dummy = null;
          string sortColumn = sc.SortProperty;

          if (resolver != null)
          {
            sortColumn = resolver(sc.SortProperty, ref dummy, helper);
          }

          statement.SortCriteria.Add(
              new MetraTech.DataAccess.SortCriteria(
                  sortColumn,
                  ((sc.SortDirection == SortType.Ascending) ? SortDirection.Ascending : SortDirection.Descending)));
        }
      }

      #endregion

      #region Apply Filters
      //apply filters
      foreach (MTBaseFilterElement filterElement in mtList.Filters)
      {
        BaseFilterElement fe = ConvertMTFilterElement(filterElement, resolver, helper);

        statement.AddFilter(fe);
      }
      #endregion

      #region Apply Pagination
      //set paging info
      statement.CurrentPage = mtList.CurrentPage;
      statement.PageSize = mtList.PageSize;
      #endregion
    }

    public static BaseFilterElement ConvertMTFilterElement(MTBaseFilterElement filterElement, FilterColumnResolver resolver, object helper)
    {
      BaseFilterElement bfe = null;

      if (filterElement.GetType() == typeof(MTBinaryFilterOperator))
      {
        MTBinaryFilterOperator bfo = filterElement as MTBinaryFilterOperator;

        bfe = new BinaryFilterElement(
                    ConvertMTFilterElement(bfo.LeftHandElement, resolver, helper),
                    (BinaryFilterElement.BinaryOperatorType)((int)bfo.OperatorType),
                    ConvertMTFilterElement(bfo.RightHandElement, resolver, helper));
      }
      else if (filterElement.GetType() == typeof(MTFilterElement))
      {
        MTFilterElement fe = filterElement as MTFilterElement;
        object filterValue = fe.Value;
        string filterColumn = fe.PropertyName;

        if (resolver != null)
        {
          filterColumn = resolver(fe.PropertyName, ref filterValue, helper);
        }

        bfe = new FilterElement(filterColumn,
          (FilterElement.OperationType)((int)fe.Operation),
          filterValue);
      }
      else
      {
        throw new MASBasicException("Unexpected MTBaseFilterElement type");
      }

      return bfe;
    }

  }
}

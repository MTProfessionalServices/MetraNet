using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using MetraTech.Agreements.Models;
using MetraTech.DataAccess;

namespace MetraTech.Agreements.Controllers
{
    /// <summary>
    /// A TemplatesResultsPage contains a list of AgreementTemplateViewModel objects -- one page's worth --
    /// along with a count of the total number of templates across all the results pages.
    /// </summary>
    public class TemplatesResultsPage
    {
        /// <summary>
        /// A count of the total number of templates across all the pages of results.
        /// </summary>
        public int totalCountAcrossPages { get; set; }

        /// <summary>
        /// One page's worth of AgreementTemplateViewModel objects that
        /// satisfy a set of filtering criteria.
        /// </summary>
        public List<AgreementTemplateViewModel> templateViewModels { get; set; }
    }


    public class TemplateApiController : ApiController
    {
        private IAgreementTemplateServices m_svc;

        private Logger _Log = new Logger("[TemplateApiController]");
        
        public TemplateApiController()
        {
            m_svc = AgreementTemplateServicesFactory.GetAgreementTemplateService(); 
        }

        public TemplateApiController(int i)
        {
            m_svc = AgreementTemplateServicesFactory.GetAgreementTemplateService(i);
        }

        public TemplateApiController(IAgreementTemplateServices svc)
        {
            m_svc = svc;
        }


        /// <summary>
        /// Returns the agreement template with the specified id.
        /// If id is negative, returns a new agreement template.
        /// Throws HttpResponseException if can't find template with the specified id.
        /// 
        /// Handles request:  GET: Agreements/api/TemplateApi/5
        /// </summary>
        /// <param name="id">ID of agreement template</param>
        /// <exception cref="HttpResponseException">if can't find template with the specified id</exception>
        public AgreementTemplateViewModel Get(int id)
        {
            var resourcesManager = new ResourcesManager();

            try
            {
                AgreementTemplateViewModel retVal;
                if (id < 0)
                {

                    var template = new AgreementTemplateModel();
                    retVal = new AgreementTemplateViewModel(template);
                }
                else
                {
                    retVal = new AgreementTemplateViewModel(m_svc.GetAgreementTemplate(id));
                }

                return retVal;
            }
            catch (DataException e)
            {
                _Log.LogException(String.Format(resourcesManager.GetLocalizedResource("TEXT_CANT_FIND_TEMPLATE"), id), e);
                throw new HttpResponseException(HttpStatusCode.NotFound);
            }
            catch (Exception e)
            {
                _Log.LogException(String.Format(resourcesManager.GetLocalizedResource("TEXT_CANT_LOAD_TEMPLATE"), id), e);
                throw new HttpResponseException(HttpStatusCode.InternalServerError);
            }
        }


        /// <summary>
        /// Stores submitted data for a new agreement template in the database.
        /// Handles request:  POST: Agreements/api/TemplateApi
        /// </summary>
        /// <param name="inTemplate">contents of agreement template (in request body)</param>
        public HttpResponseMessage Post(AgreementTemplateViewModel inTemplate)
        {
            var resourcesManager = new ResourcesManager();

            if (!ModelState.IsValid)
            {
                string messages = string.Join(" ",
                                              ModelState.Values.SelectMany(x => x.Errors).Select(x => x.ErrorMessage));
                var resp = Request.CreateErrorResponse(HttpStatusCode.BadRequest, messages);
                throw new HttpResponseException(resp);
            }
            try
            {
                var template = new AgreementTemplateModel();
                inTemplate.SaveToModel(template);
                /** TEMPORARY **/
                if (template.CoreTemplateProperties.CreatedBy == 0)
                    template.CoreTemplateProperties.CreatedBy = 123;
                template.CoreTemplateProperties.UpdatedBy = 123;
                var outTemplate = m_svc.Save(template);

                AgreementTemplateViewModel outTemplateVM = new AgreementTemplateViewModel(outTemplate);

                var response = Request.CreateResponse<AgreementTemplateViewModel>(
                    HttpStatusCode.Created, outTemplateVM);

                // TODO: Fix up uri so we can include the Location header in the httpResponse, per convention.
                //string uri = Url.Link("DefaultApi", new {id = outTemplateVM.AgreementTemplateId});
                //response.Headers.Location = new Uri(uri);

                return response;

            }
            catch (Exception e)
            {
                _Log.LogException(resourcesManager.GetLocalizedResource("TEXT_CANT_CREATE_TEMPLATE"), e);
                throw new HttpResponseException(HttpStatusCode.InternalServerError);
            }
        }


        /// <summary>
        /// Updates the contents of an existing agreement template in the database.
        /// Handles request:  PUT: Agreements/api/TemplateApi/5
        /// </summary>
        /// <param name="id">ID of agreement template</param>
        /// <param name="inTemplate">contents of agreement template (in request body)</param>
        public AgreementTemplateViewModel Put(int id, AgreementTemplateViewModel inTemplate)
        {
            var resourcesManager = new ResourcesManager();

            if (!ModelState.IsValid)
            {
                string messages = string.Join(" ",
                                              ModelState.Values.SelectMany(x => x.Errors).Select(x => x.ErrorMessage));
                var resp = Request.CreateErrorResponse(HttpStatusCode.BadRequest, messages);
                throw new HttpResponseException(resp);
            }
            if (id != inTemplate.AgreementTemplateId)
            {
                string message =
                    String.Format(resourcesManager.GetLocalizedResource("TEXT_REQUEST_ID_DOESNT_MATCH_TEMPLATE_ID"), id,
                                  inTemplate.AgreementTemplateId);
                _Log.LogError(message);
                throw new HttpResponseException(Request.CreateErrorResponse(HttpStatusCode.BadRequest, message));
            }
            try
            {
                // This action returns AgreementTemplateViewModel, as opposed to void,
                // so that the client can extract the agreement template's ID
                // (or anything else it wants to use, e.g., in a confirmation message).
                AgreementTemplateModel template = new AgreementTemplateModel();
                //template.AgreementTemplateId = id;
                inTemplate.SaveToModel(template);
                /** TEMPORARY **/
                template.CoreTemplateProperties.UpdatedBy = 123;
                var outTemplate = m_svc.Save(template);
                return new AgreementTemplateViewModel(outTemplate);
            }
            catch (Exception e)
            {
                _Log.LogException(String.Format(resourcesManager.GetLocalizedResource("TEXT_CANT_SAVE_TEMPLATE"), id), e);
                throw new HttpResponseException(HttpStatusCode.InternalServerError);
            }
        }


        /// <summary>
        /// Deletes the agreement template with the specified ID from the database.
        /// Handles request:  DELETE: Agreements/api/TemplateApi/5
        /// </summary>
        /// <param name="id">ID of agreement template</param>
        //public void Delete(int id)
        //{
        //}


        /// <summary>
        /// Returns a list of all the agreement templates on the system, subject to the
        /// filtering, sorting, and paging requirements specified in the parameters.
        /// The parameters correspond to optional URL query string parameters named
        /// "filter", "sort", "pageSize" and "pageNum".
        /// The order of parameters in the query string is not significant.
        /// 
        /// The "filter" parameter defines one or more filters, separated by ";;".
        /// Each filter has the format:  propertyName::operation::value
        /// Supported property names are (as defined in the __GET_AGREEMENTS_TEMPLATES__ database query):
        ///     AgreementTemplateId, AgreementTemplateNameId, AgreementTemplateName, 
        ///     AgreementTemplateDescId, AgreementTemplateDescription, 
        ///     CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, AvailableStartDate, AvailableEndDate
        /// Supported operations are (as defined in MetraTech.DataAccess.FilterElement.OperationType (DataAccess\Statement.cs)):
        ///     Like, Like_W, Equal, NotEqual, Greater, GreaterEqual, Less, LessEqual, In, IsNull, IsNotNull
        /// 
        /// The "sort" parameter defines one or more sort criteria, separated by ";;".
        /// Each criteria may be preceded by a '+' or '-'.
        /// A '+' implies ascending sort order, and a '-' implies descending sort order.
        /// The default sort order is ascending.
        /// 
        /// The "pageSize" parameter specifies the number of elements to return per result page,
        /// and the "pageNum" parameter specifies which page of results to return to the client.
        /// 
        /// If the format of the input query string is invalid or if any other error occurs
        /// while retrieving the list of templates, the method throws an HttpResponseException.
        /// 
        /// 
        /// Handles request:  GET: Agreements/api/TemplateApi?filter=AgreementTemplateName::Like::%test%;;CreatedBy::NotEqual::123&sort=AgreementTemplateName;;-UpdatedDate&pageSize=20&pageNum=3
        /// 
        /// The above sample query string specifies two filters (template name contains "test",
        /// and template was not created by user 123), two sorting criteria (sort by
        /// ascending template name and by descending date of last update),
        /// a page size of 20 and a page number of 3.
        /// </summary>
        /// <param name="filter">a string specifying filters to apply to a search</param>
        /// <param name="sort">a string specifying sort criteria to apply to a search</param>
        /// <param name="pageSize">the number of elements to return per result page</param>
        /// <param name="pageNum">which page of results to return to the client</param>
        /// <returns> One page's worth of view model objects that satisfy the given filtering, sorting and paging requirements,
        /// along with a count of the total number of templates across all pages </returns>
        /// <exception cref="HttpResponseException">If the format of the input query string is invalid 
        /// or if any other error occurs while retrieving the list of templates</exception>
        public TemplatesResultsPage GetAllAgreementTemplates(string filter = null, string sort = null, int pageSize = 10, int pageNum = 1)
        {
            var resourcesManager = new ResourcesManager();

            try
            {
                List<AgreementTemplateModel> modelList;
                List<AgreementTemplateViewModel> viewModelList;

                List<FilterElement> filters = ParseFilterValues(filter);
                List<SortCriteria> sorters = ParseSortValues(sort);

                int totalResultsCount = m_svc.GetAgreementTemplates(filters, sorters, pageSize, pageNum, out modelList);
                _Log.LogTrace(String.Format("{0} templates satisfy the filter: {1}", totalResultsCount, filter));

                viewModelList = new List<AgreementTemplateViewModel>();
                foreach (AgreementTemplateModel model in modelList)
                {
                    viewModelList.Add(new AgreementTemplateViewModel(model));
                }

                TemplatesResultsPage retval = new TemplatesResultsPage();
                retval.totalCountAcrossPages = totalResultsCount;
                retval.templateViewModels = viewModelList;

                return retval;
            }
            catch (FormatException e)
            {
                _Log.LogException(resourcesManager.GetLocalizedResource("TEXT_BADLY_FORMATTED_PARAMETERS"), e);
                throw new HttpResponseException(HttpStatusCode.BadRequest);
            }
            catch (Exception e)
            {
                _Log.LogException(resourcesManager.GetLocalizedResource("TEXT_CANT_LOAD_TEMPLATE_LIST"), e);
                throw new HttpResponseException(HttpStatusCode.InternalServerError);
            }
        }


        /// <summary>
        /// Parses filtering information out of a string with a format like this:
        /// 
        ///     AgreementTemplateName::Like::%test%;;CreatedBy::NotEqual::123
        /// 
        /// This sample string specifies two filters: template name contains "test",
        /// and template was not created by user 123.
        /// 
        /// The valueStr parameter defines one or more filters, separated by valueDelimiter.
        /// Each filter contains two or three fields separated by fieldDelimiter, e.g.:
        ///     propertyName::operation::value
        /// 
        /// Supported operations are (as defined in MetraTech.DataAccess.FilterElement.OperationType (DataAccess\Statement.cs)):
        ///     Like, Like_W, Equal, NotEqual, Greater, GreaterEqual, Less, LessEqual, In, IsNull, IsNotNull
        /// The value field should be omitted for the IsNull and IsNotNull operations.
        /// 
        /// If the format of valueStr is invalid, the method throws a System.FormatException.
        /// </summary>
        /// <param name="valueStr">a string specifying filters to apply to a search</param>
        /// <param name="valueDelimiter">the string separating individual filter values within valueStr</param>
        /// <param name="fieldDelimiter">the string separating fields within an individual filter value</param>
        /// <returns>a list of filters to apply to the search</returns>
        /// <exception cref="System.FormatException">if valueStr does not have the expected format</exception>
        [NonAction]
        public List<FilterElement> ParseFilterValues(string valueStr, string valueDelimiter = ";;", string fieldDelimiter = "::")
        {
            /// TODO: Move this utility method to a location where it can be used by other code too?

            var resourcesManager = new ResourcesManager();
            List<FilterElement> filters = new List<FilterElement>();
            string[] valueDelims = {valueDelimiter};
            string[] fieldDelims = {fieldDelimiter};

            if ((valueStr == null) || (valueStr.Length == 0))
            {
                return filters;
            }

            string[] values = valueStr.Split(valueDelims, StringSplitOptions.RemoveEmptyEntries);

            foreach (string value in values)
            {
                _Log.LogTrace("Processing filter value: {0}", value);

                string[] fields = value.Split(fieldDelims, StringSplitOptions.None);
                if ((fields.Count() < 2) || (fields.Count() > 3) ||
                    (fields[0].Length == 0) || (fields[1].Length == 0) ||
                    ((fields.Count() == 3) && (fields[2].Length == 0)))
                {
                    string errmsg = String.Format(resourcesManager.GetLocalizedResource("TEXT_BADLY_FORMATTED_FILTER"), value);
                    _Log.LogError(errmsg);
                    throw new FormatException(errmsg);
                }

                string propName = fields[0];
                FilterElement.OperationType op;
                object propValue = null;

                if (!Enum.TryParse(fields[1], false, out op))
                {
                    string errmsg = String.Format(resourcesManager.GetLocalizedResource("TEXT_INVALID_OP_IN_FILTER"), fields[1]);
                    _Log.LogError(errmsg);
                    throw new FormatException(errmsg);
                }
                if (fields.Count() == 3)
                {
                    if ((op == FilterElement.OperationType.IsNull) || (op == FilterElement.OperationType.IsNotNull))
                    {
                        string errmsg = String.Format(resourcesManager.GetLocalizedResource("TEXT_BADLY_FORMATTED_FILTER"), value);
                        _Log.LogError(errmsg);
                        throw new FormatException(errmsg);
                    }
                    propValue = fields[2];  // Might need to change type of propValue based on propName, esp. for datetime?
                }

                _Log.LogTrace("Adding filter element: propName={0}, op={1}, propValue={2}", propName, op, propValue);
                filters.Add(new FilterElement(propName, op, propValue));
            }

            _Log.LogTrace("ParseFilterValues() returning {0} filters", filters.Count);
            return filters;
        }


        /// <summary>
        /// Parses sorting information out of the valueStr parameter,
        /// which defines one or more values (sort criteria), separated by valueDelimiter.
        /// Each value specifies a property name, prefixed by an optional '+' (for ascending sort)
        /// or '-' (for descending sort).  The default sort direction is ascending.
        /// 
        /// Example:  To specify two sort criteria -- ascending sort by template name
        /// and descending sort by date of last update -- valueStr would look like this:
        /// 
        ///     AgreementTemplateName;;-UpdatedDate
        /// 
        /// If the format of valueStr is invalid, the method throws a System.FormatException.
        /// </summary>
        /// <param name="valueStr">a string specifying sort criteria to apply to a search</param>
        /// <param name="valueDelimiter">the string separating individual sort criteria within valueStr</param>
        /// <returns>a list of sort criteria to apply to the search</returns>
        /// <exception cref="System.FormatException">if valueStr does not have the expected format</exception>
        [NonAction]
        public List<SortCriteria> ParseSortValues(string valueStr, string valueDelimiter = ";;")
        {
            /// TODO: Move this utility method to a location where it can be used by other code too?

            var resourcesManager = new ResourcesManager();
            List<SortCriteria> sorters = new List<SortCriteria>();
            string[] valueDelims = { valueDelimiter };

            if ((valueStr == null) || (valueStr.Length == 0))
            {
                return sorters;
            }

            string[] values = valueStr.Split(valueDelims, StringSplitOptions.RemoveEmptyEntries);

            foreach (string value in values)
            {
                _Log.LogTrace("Processing sort value: {0}", value);

                SortDirection direction = SortDirection.Ascending;
                int startIndex = 0;
                if (value[0] == '+')
                {
                    startIndex = 1;
                }
                else if (value[0] == '-')
                {
                    direction = SortDirection.Descending;
                    startIndex = 1;
                }
                string propName = value.Substring(startIndex);

                if (propName.Length == 0)
                {
                    string errmsg = String.Format(resourcesManager.GetLocalizedResource("TEXT_BADLY_FORMATTED_SORT"), valueStr);
                    _Log.LogError(errmsg);
                    throw new FormatException(errmsg);
                }

                _Log.LogTrace("Adding sort criteria: propName={0}, direction={1}",
                              propName, direction.ToString());
                sorters.Add(new SortCriteria(propName, direction));
            }

            _Log.LogTrace("ParseSortValues() returning {0} sort criteria", sorters.Count);
            return sorters;
        }

    }
}

using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MetraTech.Agreements.Models;
using MetraTech.DataAccess;
using MetraTech.Interop.MTServerAccess;
using MetraTech.UI.Common;

namespace MetraTech.Agreements.Controllers
{
    /// <summary>
    /// The TemplateController defines actions related to Agreement Templates.
    /// </summary>
    public class TemplateController : MTBaseController
    {
        //private const string m_urlBase = "~/Template/";
        private string m_urlBase = "~/Template/";
        private string m_apiBase;
        private IAgreementTemplateServices m_agrTmplSvc = AgreementTemplateServicesFactory.GetAgreementTemplateService();

        /// <summary>
        /// Gets the MetraTech logger object
        /// </summary>
        private Logger m_logger = new Logger("[TemplateController]");

        /// <summary>
        /// Default constructor
        /// </summary>
        public TemplateController()
        {
             IMTServerAccessDataSet serverAccess = new MTServerAccessDataSetClass();
            serverAccess.Initialize();
            IMTServerAccessData server = serverAccess.FindAndReturnObject("AgreementTemplates");
            m_urlBase = "http://" + server.ServerName + "/Agreements/Template/";
            m_apiBase = "http://" + server.ServerName + "/Agreements/api/templateapi/";
            ViewBag.ApiUrl = m_apiBase;
            ViewBag.Action = TemplateActions.None;
            ViewBag.TemplateNotFoundPage = m_urlBase + "TemplateNotFound/";
            ViewBag.ServerErrorPage = m_urlBase + "ServerError/";
        }


        /// <summary>
        /// Displays a grid of all the agreement templates on the system.
        /// Handles request:  GET: /Template/
        /// </summary>
        /// <returns></returns>
        public ActionResult Index()
        {
            ViewBag.Message = "This page will display a grid of all the Agreement Templates on the system.";
            return View("ShowAllTemplates");
        }

        /// <summary>
        /// Displays a form to create a new agreement template.
        /// Handles request:  GET: /Template/Create
        /// </summary>
        /// <returns></returns>
        public ActionResult Create()
        {
            int accountId = System.Convert.ToInt32(HttpContext.Session["AccountId"]);
            UIManager manager = ActiveUsers[accountId];

            if (manager.CoarseCheckCapability("Manage Agreement Template"))
            {
                var eligibleAgreementTemplateEntities =
                    m_agrTmplSvc.GetAgreementTemplateEntities(
                        new AgreementEntitiesModel());

                //var target = new TemplateApiController(m_agrTmplSvc);
                AgreementTemplateViewModel templateViewModel =
                    new AgreementTemplateViewModel(new AgreementTemplateModel());
                templateViewModel.CoreTemplateProperties.CreatedBy = accountId;

                ViewBag.EligibleAgreementTemplateEntities = eligibleAgreementTemplateEntities;
                ViewBag.NextPage = m_urlBase + "CreateSuccess/";
                ViewBag.Action = TemplateActions.Create;
                return View(templateViewModel);
            }
            else
            {
                ViewBag.Message = "You do not have the required capabilities to perform this operation.";
                return RedirectToAction("Index");
            }
        }

        /// <summary>
        /// Displays the page that should follow after successfully editing an agreement template.
        /// Handles request:  GET: /Template/CreateSuccess/
        /// </summary>
        /// <param name="id">template ID</param>
        /// <returns></returns>
        public ActionResult CreateSuccess(int? id)
        {
            ViewBag.Message = "Successfully created Agreement Template ID #" + id;
            return RedirectToAction("Index");
        }


        /// <summary>
        /// Displays a form to edit the specified agreement template.
        /// Handles request:  GET: /Template/Edit/5
        /// </summary>
        /// <param name="id">template ID</param>
        /// <returns></returns>
        public ActionResult Edit(int id)
        {
            var resourcesManager = new ResourcesManager();
                
            ViewBag.TemplateId = id;
            ViewBag.Action = TemplateActions.Edit;
            var eligibleAgreementTemplateEntities =
                m_agrTmplSvc.GetAgreementTemplateEntities(
                    new AgreementEntitiesModel());

            //var target = new TemplateApiController(m_agrTmplSvc);
            try
            {
                AgreementTemplateViewModel templateViewModel =
                    new AgreementTemplateViewModel(m_agrTmplSvc.GetAgreementTemplate(id));
                ViewBag.EligibleAgreementTemplateEntities = eligibleAgreementTemplateEntities;
                ViewBag.NextPage = m_urlBase + "EditSuccess/";
                return View(templateViewModel);
            }
            catch (DataException e)
            {
                m_logger.LogException(
                    String.Format(resourcesManager.GetLocalizedResource("TEXT_CANT_FIND_TEMPLATE"), id), e);
                return RedirectToAction("TemplateNotFound");
            }
            catch (Exception e)
            {
                m_logger.LogException(String.Format(resourcesManager.GetLocalizedResource("TEXT_CANT_LOAD_TEMPLATE"), id), e);
                return RedirectToAction("TemplateNotFound");
            }
        }

        /// <summary>
        /// Display the page that should follow when a specific template could not be found
        /// </summary>
        /// <param name="id">the page that could not be found</param>
        /// <returns>the failure view</returns>
        public ActionResult TemplateNotFound(int? id)
        {
            var resourcesManager = new ResourcesManager();
            ViewBag.Message = String.Format(resourcesManager.GetLocalizedResource("TEXT_CANT_FIND_TEMPLATE"), id);
            return RedirectToAction("Index");
        }

        /// <summary>
        /// Display the page that should follow when a server error occurs
        /// </summary>
        /// <param name="message">A message from the calling page</param>
        /// <returns>the failure view</returns>
        public ActionResult ServerError(string message)
        {
            ViewBag.Message = "Server error occurred" + message;
            //return View("ShowAllTemplates");
            return RedirectToAction("Index");
        }

        /// <summary>
        /// Displays the page that should follow after successfully editing an agreement template.
        /// Handles request:  GET: /Template/EditSuccess/5
        /// </summary>
        /// <param name="id">template ID</param>
        /// <returns></returns>
        public ActionResult EditSuccess(int? id)
        {
            ViewBag.Message = "Successfully edited Agreement Template ID #" + id;
            return RedirectToAction("Index");
        }


        public ActionResult ShowAllTemplates()
        {
            ViewBag.NextPage = m_urlBase + "Create";
            string temp = Request.QueryString["AccountId"];
            if (!String.IsNullOrEmpty(temp))
            {
                Session.Add("AccountId", temp);
            }
            return View();
        }


        /// <summary>
        /// Selects all agreement templates in the system
        /// Handles request:  GET: /Template/SelectAgreementTemplates/
        /// </summary>
        /// <returns></returns>
        [System.Web.Mvc.HttpGet]
        public ActionResult SelectAgreementTemplates(JQueryDataTableParamModel param)
        {
            ViewBag.Action = TemplateActions.ShowTemplates;
            try
            {
                //Create Filter
                var filters = new List<FilterElement>();
                int i = -1;
                do
                {
                    i++; 
                    FilterElement.OperationType op;
                    var filterVal = Convert.ToString(Request["filterValue_" + i]);
                    //Don't add empty filter values to filter.
                    if (String.IsNullOrEmpty(filterVal)) continue;
                    Enum.TryParse(Convert.ToString(Request["filterOp_" + i]), out op);
                    var fe = new FilterElement(propertyName: Convert.ToString(Request["filterName_" + i]),
                                               op: op,
                                               value: filterVal);
                    filters.Add(fe);
                } while (Convert.ToString(Request["filterName_" + i]) != null) ;

                //Sort criteria
                var sorters = new List<SortCriteria>();
                for (i = 0; i < param.iSortingCols; i++)
                {
                    int sortCol = Convert.ToInt32(Request["iSortCol_" + i]);
                    string sortColName = Convert.ToString(Request["mDataProp_" + sortCol]);
                    sortColName =
                        sortColName.Substring(sortColName.LastIndexOf('.') == -1 ? 0 : sortColName.LastIndexOf('.') + 1);
                    sorters.Add(new SortCriteria(sortColName,
                                                 Request["sSortDir_" + i] == "asc"
                                                     ? SortDirection.Ascending
                                                     : SortDirection.Descending));
                }

                var templateList = new List<AgreementTemplateModel>();
                int totalResultsCount = m_agrTmplSvc.GetAgreementTemplates(filters, sorters,
                                                                           pageSize: param.iDisplayLength,
                                                                           pageNum:
                                                                               (param.iDisplayStart/param.iDisplayLength +
                                                                                1), templateList: out templateList);
                var viewModelList = templateList.Select(model => new AgreementTemplateViewModel(model)).ToList();

                return Json(new
                                {
                                    sEcho = param.sEcho,
                                    iTotalRecords = totalResultsCount,
                                    iTotalDisplayRecords = totalResultsCount,
                                    aaData = viewModelList
                                },
                            JsonRequestBehavior.AllowGet);

            }
            catch (Exception exc)
            {
                var resourcesManager = new ResourcesManager();
                m_logger.LogException(resourcesManager.GetLocalizedResource("TEXT_CANT_DISPLAY_TEMPLATE_LIST"), exc);
                //return View();
                throw;
            }

        }



        /// <summary>
        /// Displays a form to select entities (product offerings, RMEs) for the specified agreement template.
        /// Handles request:  GET: /Template/SelectEntities/5
        /// </summary>
        /// <returns></returns>
        public ActionResult SelectEntities(int templateId)
        {
            //return View();
            return RedirectToAction("Index");
        }


        /// <summary>
        /// Stores the submitted choice of entities for the specified agreement template IN MEMORY.
        /// Handles request:  POST: /Template/SelectEntities/5
        /// </summary>
        /// <returns></returns>
        [System.Web.Mvc.HttpPost]
        public ActionResult SelectEntities(int templateId, FormCollection collection)
        {
            try
            {
                // TODO: Add update logic here

                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }


        /// <summary>
        /// Displays an error page.
        /// Handles request:  GET: /Template/Error
        /// </summary>
        /// <returns></returns>
        public ActionResult Error()
        {
            //ViewBag.Message = "foo";
            return View("Error");
        }
    }

    public enum TemplateActions
    {
        None, Create, Edit, ShowTemplates
    }
}

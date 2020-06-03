using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CloudController.Models;

namespace CloudController.Controllers
{
    public class AnalysisController : Controller
    {
        // GET: Analysis
        public ActionResult Index(string guid)
        {
            var x = new UtilityAnalysis(guid);
            x.RunAnalysis();
            ViewBag.guid = guid;
            return View(x);
        }

        public ActionResult ComparisonPartial(int[] list,string guid)
        {
            var ll = list as int[];
            var x = new UtilityAnalysis(guid);
            x.RunAnalysis();
            List<AnalysisSummary> model = new List<AnalysisSummary>();
            var selected = ll.ToList();
            for (int i = 0; i < x.AnalysisSummaries.Count; i++)
            {
                if(selected.Contains(i+1))
                    model.Add(x.AnalysisSummaries[i]);
            }
            ViewBag.AnalysisSummaries= model;
            ViewBag.AnalysisSummariesIndices = list.ToList().OrderBy(s=>s);
            return View(x);
        }
    }
}
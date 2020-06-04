using System;
using System.Collections.Generic;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CloudController.Models;
using CloudController.Models.Optimization;

namespace CloudController.Controllers
{
    public class OptimizationController : Controller
    {
        // GET: Optimization
        public ActionResult Genetic(string guid)
        {
            OptimizationByGenetic algo = new OptimizationByGenetic(guid);
            algo.RunOptimization();
            return Content(DateTime.Now.ToString());
        }

        public ActionResult DumpGenetic()
        {
            Coordinator.Instance.DumpDeploymentInformation();
            return Content("Success");
        }
    }
}
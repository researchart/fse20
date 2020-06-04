using System.Web.Optimization;

namespace CloudController
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            //bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
            //            "~/Scripts/jquery-{version}.js"));

            //bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
            //            "~/Scripts/jquery.validate*"));

            //// Use the development version of Modernizr to develop with and learn from. Then, when you're
            //// ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            //bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
            //            "~/Scripts/modernizr-*"));

            //bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
            //          "~/Scripts/bootstrap.js",
            //          "~/Scripts/respond.js"));

            //bundles.Add(new StyleBundle("~/Content/css").Include(
            //          "~/Content/bootstrap.css",
            //          "~/Content/site.css"));

            bundles.Add(new ScriptBundle("~/bundles/kendo").Include(
            "~/Content/Kendo/js/kendo.all.min.js",
            //"~/Content/Kendo/js/cultures/kendo.culture.fa-IR.min.js",
            // "~/Scripts/kendo/kendo.timezones.min.js", // uncomment if using the Scheduler
            "~/Content/Kendo/js/kendo.aspnetmvc.min.js"));

            bundles.Add(new StyleBundle("~/Content/kendo/css").Include(
                "~/Content/kendo/styles/kendo.common-material.min.css",
                //"~/Content/kendo/styles/kendo.rtl.min.css",
                "~/Content/kendo/styles/kendo.material.min.css",
                "~/Content/kendo/styles/kendo.common-material.moboile.min.css",
                "~/Content/kendo/styles/kendo.dataviz.min.css",
                "~/Content/kendo/styles/kendo.dataviz.material.min.css"



            //"~/Content/kendo/styles/kendo.bootstrap.min.css"
            ));

            bundles.IgnoreList.Clear();
        }
    }
}
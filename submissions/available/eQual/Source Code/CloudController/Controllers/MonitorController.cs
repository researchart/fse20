using System;
using System.Collections.Generic;
using System.Data.Entity.Core.Common.CommandTrees;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Xml.Serialization;
using CloudController.Models;
using Microsoft.AspNet.SignalR;
using CloudController.HttpHelper;
using DomainPro.Analyst;
using Kendo.Mvc.Extensions;
using Kendo.Mvc.UI;

namespace CloudController.Controllers
{
    [System.Web.Mvc.Authorize]
    public class MonitorController : Controller
    {
        private string Guid { set; get; }
        // GET: Monitor
        public ActionResult Index(string guid )
        {
            this.Guid = guid;
            ViewBag.guid = guid;
            PopulateWaitingList(guid);
            Task deployTask = new Task(() => DeploySimulationsToNodes(guid));
            deployTask.Start();
            var monitorViewModel = new MonitorViewModel(guid);
            ViewData["watchedTypes"] = (from  items in monitorViewModel.QAList select  new {Type= items.WatchedType}).Distinct();
            return View(monitorViewModel);
        }

 
        private void PopulateWaitingList(string guid)
        {
            Coordinator.Instance.CreateWaitingList(guid);
            //reading the simulation overrides in {id}/SimulationFiles/{folders}
            var simOverrides = ReadSimulationOverrides(guid);
            //each one of these is added to waiting list to be ran on a node
            foreach (var item in simOverrides)
            {
                Coordinator.Instance.SimWaitingList[guid].Enqueue(item.Key);
            }
        }

        //This logic results in starvations for more than two instances runnign simultaneously 
        //This code should be modified to be more fault tolerant and retry failed simulations
        public void DeploySimulationsToNodes(string guid)
        {
            if (!Coordinator.Instance.SimWaitingList.ContainsKey(guid))
                return;
            while (!Coordinator.Instance.AvailablePool.IsEmpty && Coordinator.Instance.SimWaitingList[guid].Count>0)
            {
                Node node;
                var dequedNodeSuccess = Coordinator.Instance.AvailablePool.TryDequeue(out node);
                if (!dequedNodeSuccess)
                    continue;
                string path;
                var dequedSimSuccess = Coordinator.Instance.SimWaitingList[guid].TryDequeue(out path);
                if (!dequedSimSuccess)
                {
                    Coordinator.Instance.AvailablePool.Enqueue(node);
                    continue;
                }
                try
                {
                    var info = SendFilesToNode(guid, node, path);
                    Coordinator.Instance.DeploymentInfromationList.Add(new DeploymentInformation() {
                        Guid= guid,
                        Hook = info.Hook.ToString().Replace("\"", ""),
                        Node = node,
                        SimulationPath = path
                    });
                    //Coordinator.Instance.NodeHookList.Add(new KeyValuePair<string, Node>(info.Hook.ToString().Replace("\"", ""), node));
                    //run the simulation on the node
                    HttpWebRequest request = (HttpWebRequest)WebRequest.Create(node.URL + "/RunSimulation?guid=" + guid + "&hook=" + info.Hook.ToString().Replace("\"", ""));
                    HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                }                    
                catch
                {
                    Coordinator.Instance.AvailablePool.Enqueue(node);
                    continue;
                }
            }
            if (Coordinator.Instance.SimWaitingList[guid].Count == 0)
            {
                SendSimulationsCompleteCommand(guid);
                //send the complete command to browser and wait for analyses command
            }
        }
        [AllowAnonymous]
        public ActionResult RelaySimulationProgress(string guid, string hook, int progress)
        {
            var res = new
            {
                Guid = guid,
                Hook = hook,
                Progress = progress
            };
            if (progress == 1000)
            {
                var node =
                    (from items in Coordinator.Instance.DeploymentInfromationList where items.Hook == hook select items).First().Node;
                Coordinator.Instance.AvailablePool.Enqueue(node);
                Task t = new Task(()=>DeploySimulationsToNodes(guid));
                Coordinator.Instance.SimulationDeployerProcess();
                t.Start();
            }
            var context = GlobalHost.ConnectionManager.GetHubContext<CloudControllerHub>();
            context.Clients.Group(guid).updateProgress(res);
            return Json(res, JsonRequestBehavior.AllowGet);
        }

        private void SendSimulationsCompleteCommand(string guid)
        {
            var context = GlobalHost.ConnectionManager.GetHubContext<CloudControllerHub>();
            context.Clients.Group(guid).simulationsComplete();
        }

       
        [AllowAnonymous]
        public ActionResult SaveSimulationResults(string guid, string hook, HttpPostedFileBase results=null)
        {

            //deserialize the results
            //save resutls in the right location
            var deploymentInfo = (from items in Coordinator.Instance.DeploymentInfromationList where items.Hook == hook select items).FirstOrDefault();
            results.SaveAs(Path.Combine(deploymentInfo.SimulationPath, "results.xml"));
            Coordinator.Instance.UpdateSimulationResults(deploymentInfo);
            return Json(true, JsonRequestBehavior.AllowGet);
        }
        private List<KeyValuePair<string, List<PropertyOverride>>> ReadSimulationOverrides(string guid)
        {
            string directory = Server.MapPath("~/SimulationFiles") + "/" + guid + "/Simulations/";
            var dirs = Directory.GetDirectories(directory);
            var res = new List<KeyValuePair<string, List<PropertyOverride>>>();
            foreach (var path in dirs)
            {
                XmlSerializer deserializer = new XmlSerializer(typeof(List<PropertyOverride>));

                using (TextReader textReader = new StreamReader(path + "/Properties.xml"))
                {
                    List<PropertyOverride> overrides =
                        (List<PropertyOverride>)deserializer.Deserialize(textReader);
                    textReader.Close();
                    res.Add(new KeyValuePair<string, List<PropertyOverride>>(path, overrides));
                }
            }
            return res;
        }
        private dynamic SendFilesToNode(string guid, Node node, string savePath)
        {
            string url = node.URL +"/UploadFiles";
            string t = String.Format("{0}\\{1}\\{2}\\", Server.MapPath("~/SimulationFiles"), guid, "Simulations");
            HttpForm form = new HttpForm(url);
            string modDirectory = String.Format("{0}\\{1}\\{2}", Server.MapPath("~/SimulationFiles"), guid, "Model");
            string[] modFiles = Directory.GetFiles(modDirectory, "*.zip");
            string langDirectory = String.Format("{0}\\{1}\\{2}", Server.MapPath("~/SimulationFiles"), guid, "Language");
            string[] langFiles = Directory.GetFiles(langDirectory, "*.zip");
            string properties = savePath + "\\Properties.xml";
            string nodeInfo = savePath + "\\ Node.xml";
            form.AttachFile("model", modFiles[0]);
            form.AttachFile("language", langFiles[0]);
            form.AttachFile("properties", properties);
            var response = form.Submit();
            using (Stream stream = response.GetResponseStream())
            {
                StreamReader reader = new StreamReader(stream, Encoding.UTF8);
                String responseString = reader.ReadToEnd();
                SaveNodeInformation(nodeInfo, node.NodeID, responseString);
                return new
                {
                    NodeInfo = nodeInfo,
                    NodeID = node.NodeID,
                    Hook = responseString
                };
            }

        }

        private void SaveNodeInformation(string path, string nodeID, string hook)
        {
            string[] lines = { nodeID, hook };
            System.IO.File.WriteAllLines(path, lines);
        }

        public ActionResult GetSeriesNameList(WatchedTypeKinds kind)
        {
            List<SeriesType> list = new List<SeriesType>();
            List<string> seriesNameList = null;
            switch (kind)
            {
                case WatchedTypeKinds.Component:
                    seriesNameList = new List<string>() {"Blocking Methods",
            "Executing Methods"};
                    break;
                case WatchedTypeKinds.Method:
                    seriesNameList = new List<string>() {"Number of Invocations",
            "Invocation Interval",
            "Average Invocation Interval",
            "Blocking Time",
            "Average Blocking Time",
            "Maximum Blocking Time",
            "Executing Time",
            "Average Executing Time",
            "Maximum Executing Time"};
                    break;
                case WatchedTypeKinds.Data:
                    seriesNameList = new List<string>() { "Value" };
                    break;
                case WatchedTypeKinds.Resource:
                    seriesNameList = new List<string>() { "Idle Capacity",
            "Queue Length"};
                    break;
            }
            foreach (var item in seriesNameList)
            {
                list.Add(new SeriesType()
                {
                    WatchedTypeKind = kind,
                    SerieName = item
                });

            }
            return Json(list,JsonRequestBehavior.AllowGet);
        }

        public ActionResult QAList(string guid)
        {
            ViewBag.guid = guid;
            return View();
        }
        public ActionResult QA_Read([DataSourceRequest] DataSourceRequest request,string guid )
        {
            return Json(MonitorViewModel.ReadQAs(guid).ToDataSourceResult(request));
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult QA_Create([DataSourceRequest] DataSourceRequest request, QualityAttributeMappingModel model,string guid)
        {
            if (model != null && ModelState.IsValid)
            {
                MonitorViewModel.CreateQA(model,guid);
            }

            return Json(new[] { model }.ToDataSourceResult(request, ModelState));
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult QA_Update([DataSourceRequest] DataSourceRequest request, QualityAttributeMappingModel model, string guid)
        {
            if (model != null && ModelState.IsValid)
            {
                MonitorViewModel.UpdateQA(model, guid);
            }

            return Json(new[] { model }.ToDataSourceResult(request, ModelState));
        }


        public ActionResult Test()
        {
           
            return null;
        }



    }
}

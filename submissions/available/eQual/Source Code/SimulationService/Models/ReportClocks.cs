using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using CloudController.HttpHelper;
using DomainPro.Analyst.Engine;
using DomainPro.Core.Models;

namespace SimulationService.Models
{
    public class ReportClockBase
    {
        
    }
    public class ReportClock
    {
        private object obj = new object();
        private DP_Simulation simulation;
        private SimulationRunner _simRunner;
        System.Timers.Timer secTimer = new System.Timers.Timer(300);
        private string guid;
        private string hook;

        public string ProgressUrl
        {
            get
            {
                return SimulationServiceConfiguration.Instance.CloudUrl + "Monitor/RelaySimulationProgress";
            }
        }
        public string ResultsUrl
        {
            get
            {
                return SimulationServiceConfiguration.Instance.CloudUrl + "Monitor/SaveSimulationResults";
            }
        }
        
        private int counter = 0;
        List<int> progress = new List<int>();
        public ReportClock(DP_Simulation sim, string guid, string hook, SimulationRunner simrunner)
        {
            simulation = sim;
            secTimer.Elapsed += Tick;
            this.guid = guid;
            this.hook = hook;
            _simRunner = simrunner;
        }

        public void Start()
        {
            secTimer.Start();
        }

        public void Stop()
        {
            secTimer.Stop();

            counter++;
        }

        private void Tick(object sender, EventArgs e)
        {
            if (secTimer.Enabled)
                ReportProgressToCloudController();
            int t = simulation.Progress;
        }

        private void ReportProgressToCloudController()
        {
            lock (obj)
            {
                progress.Add(simulation.Progress);
                if (simulation.Progress == 1000)
                {
                    this.Stop();
                    ReportFinalResultsToCloudController();
                }
                // send report to cloud controller
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(ProgressUrl + "?guid=" + guid + "&hook=" + hook + "&progress=" + simulation.Progress.ToString());
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();


                if (simulation.Progress == 1000)
                {
                    Coordinator.Instance.IsRunning = false;
                    //this is the dequeu part
                    _simRunner.Dispose();
                    KeyValuePair<string, string> item;
                    bool dequeusuccess = Coordinator.Instance.RequestedHooks.TryDequeue(out item);
                    if (!dequeusuccess)
                        return;
                    SimulationRunner simRun = new SimulationRunner(item.Key, item.Value);
                    simRun.Initialize();
                    simRun.Run();
                }
                //HttpForm form = new HttpForm(URL);
                //form.Method = "POST";
                //form.SetValue("guid", guid).SetValue("hook", hook).SetValue("progress", simulation.Progress.ToString());
                //form.Submit();
            }
        }
        private void SendHttpResults(string path)
        {
            HttpForm form = new HttpForm(ResultsUrl);

            form.AttachFile("results", path);
            form.SetValue("guid", guid);
            form.SetValue("hook", hook);
            var response = form.Submit();
            string responseString = "";
            using (Stream stream = response.GetResponseStream())
            {
                StreamReader reader = new StreamReader(stream, Encoding.UTF8);
                responseString = reader.ReadToEnd();
            }
        }
        private async void ReportFinalResultsToCloudController()
        {
            List<DP_WatchedTypeOutput> list = new List<DP_WatchedTypeOutput>();
            foreach (var item in this.simulation.CurrentRun.WatchedDict)
            {
                list.Add(item.Value.ExportToText(item.Key));
            }
            //serialize the text as xml

            var serializedPath = list.SerializeObjectToFile();
            SendHttpResults(serializedPath);
            //send the list to cloudcontroller

            //receive and deserialize it at cloud controller
        }

    }
}
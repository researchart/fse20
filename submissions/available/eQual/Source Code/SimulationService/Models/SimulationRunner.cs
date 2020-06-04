using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Web;
using System.Windows.Forms;
using System.Xml.Serialization;
using CloudController.Models;
using Ionic.Zip;
using DomainPro.Analyst;
using DomainPro.Analyst.Engine;
using DomainPro.Core.Models;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Hosting;
using CloudController.HttpHelper;

namespace SimulationService.Models
{
    public class SimulationRunner : IDisposable
    {

        private string Hook { set; get; }
        private string Guid { set; get; }
        private DomainProAnalyst App { set; get; }
        private ReportClock clock { set; get; }

        public SimulationRunner(string guid, string hook)
        {
            Hook = hook;
            Guid = guid;
        }

        public void Initialize()
        {
            try
            {
                //Extract lang
                RetrieveModelDppFile(Hook);
                //Extract model
                RetrieveLanguageDplFile(Hook);
                //Read in the properties file
                //var overrides = ReadProperties(Hook);
                FixTheOverrides(Hook);
                //Create the instance for running simulation w
                //set the environment local to the with adding +Hook , but in that case needs the code to copy the assembly and language dpl files to that place
                App = new DomainProAnalyst(HostingEnvironment.MapPath("~/SimulationFiles/"));
                App.LoadProjectForCloud(RetrieveModelDppFile(Hook),
                    RetrieveLanguageDplFile(Hook));
                //var sims = App.LoadedSimulations;
                //sims.RemoveRange(1, sims.Count - 1);
                //sims[0].PropertyOverrides.Clear();
                //foreach (var item in overrides)
                //{
                //    sims[0].PropertyOverrides.Add(new DP_PropertyOverride()
                //    {
                //        Property = item.Property,
                //        Type = item.Type,
                //        Value = item.Value
                //    });
                //}
                App.LoadModelAssembly();
                clock = new ReportClock(App.SelectedSimulation, Guid, Hook, this);
            }
            catch (Exception exName)
            {
                Logger.WriteExceptionToLogFile(exName);
            }
            //set the overrides for sim instance
            //run the simulation
            //gather the results
            //send the feedback and results back to caller
        }

        private void FixTheOverrides(string hook)
        {
            string path = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + hook + "/Properties/" + "Properties.xml";
            XmlSerializer deserializer = new XmlSerializer(typeof(List<PropertyOverride>));
            TextReader textReader = new StreamReader(path);
            List<PropertyOverride> propList = (List<PropertyOverride>)deserializer.Deserialize(textReader);
            textReader.Close();
            List<DP_Simulation> simList = null;

            string path2 = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + hook + "/model/SmartRedundancyModified/" + "SmartRedundancySimList.xml";
            //string path2 = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + hook + "/model/SmartRedundancyModified/" + "SmartRedundancySimList2.xml";
            //File.Copy(paths,path2,true);
            FileStream fileStream = new FileStream(path2, FileMode.OpenOrCreate,FileAccess.ReadWrite, FileShare.ReadWrite);
            XmlSerializer deserializer2 = new XmlSerializer(typeof(List<DP_Simulation>));

            TextReader textReader2 = new StreamReader(fileStream);
            simList = (List<DP_Simulation>)deserializer2.Deserialize(textReader2);
            //textReader2.Close();
            //textReader2.Dispose();

            simList.RemoveRange(1, simList.Count - 1);
            simList[0].PropertyOverrides.Clear();

            foreach (var item in propList)
            {
                simList[0].PropertyOverrides.Add(new DP_PropertyOverride()
                {
                    Property = item.Property,
                    Value = item.Value,
                    Type = item.Type
                });
            }

            XmlSerializer serializer = new XmlSerializer(typeof(List<DP_Simulation>));
            fileStream.Flush();
            fileStream.Seek(0, 0);
            //if (!Directory.Exists(path2))
            //{
            //    Directory.CreateDirectory(path2);
            //}
            TextWriter textWriter = new StreamWriter(fileStream);
            serializer.Serialize(textWriter, simList);
            textWriter.Close();
            fileStream.Close();
            fileStream.Dispose();
        }

        public void Run()
        {
            //Thread simThread = new Thread(new ThreadStart(SelectedSimulation.Simulator.Run));
            //App.SelectedSimulation.CurrentRun.WatchedDict.First().Value.ExportToText("as");
            App.SelectedSimulation.Progress = 0;
            Task task = Task.Factory.StartNew(() => App.RunSimClick(null, null)).ContinueWith(ExceptionHanlder, TaskContinuationOptions.OnlyOnFaulted);

            //Thread simThread = new Thread(() => App.RunSimClick(null, null))
            //{
            //    Priority = ThreadPriority.Lowest,
            //    Name = "MainSimLoop: " + App.SelectedSimulation.Name
            //};
            //simThread.Start();
            clock.Start();

        }

        static void ExceptionHanlder(Task task)
        {
            Logger.WriteExceptionToLogFile(task.Exception);
        }
        private string RetrieveModelDppFile(string guid)
        {
            string modDirectory = String.Format("{0}\\{1}\\{2}", System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles"), guid, "Model");
            string[] modFiles = Directory.GetFiles(modDirectory, "*.zip");
            using (ZipFile zip = new ZipFile(modFiles[0]))
            {
                if (!Directory.Exists(modFiles[0].Substring(0, modFiles[0].IndexOf(".zip"))))
                    zip.ExtractAll(modDirectory, ExtractExistingFileAction.OverwriteSilently);

            }
            string modelDPPFile = Directory.GetFiles(modDirectory, "*.dpp")[0];

            //---- fixing the root folder for model file
            StringBuilder result = new StringBuilder();

            if (System.IO.File.Exists(modelDPPFile))
            {
                using (StreamReader streamReader = new StreamReader(modelDPPFile))
                {
                    String line;
                    while ((line = streamReader.ReadLine()) != null)
                    {
                        string newLine = line;
                        if (line.IndexOf("Root", StringComparison.Ordinal) == 0 && line.IndexOf("\\") != -1)
                        {
                            string name = line.Substring(line.LastIndexOf("\\") + 1);
                            newLine = "Root " + name;
                        }
                        result.AppendLine(newLine);
                    }
                }
            }
            using (FileStream fileStream = new FileStream(modelDPPFile, FileMode.Create, FileAccess.ReadWrite))
            {
                StreamWriter streamWriter = new StreamWriter(fileStream);
                streamWriter.Write(result);
                streamWriter.Close();
                fileStream.Close();
            }
            // -- endof fixing the root folder for model file

            return modelDPPFile;
        }

        private string RetrieveLanguageDplFile(string guid)
        {
            string langDirectory = String.Format("{0}\\{1}\\{2}", System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles"), guid, "Language");
            string[] langFiles = Directory.GetFiles(langDirectory, "*.zip");
            using (ZipFile zip = new ZipFile(langFiles[0]))
            {
                if (!Directory.Exists(langFiles[0].Substring(0, langFiles[0].IndexOf(".zip"))))
                    zip.ExtractAll(langDirectory, ExtractExistingFileAction.OverwriteSilently);
            }
            string dplDirectory = Directory.GetDirectories(langDirectory)[0];
            string langDPLFile = Directory.GetFiles(dplDirectory, "*.dpl")[0];
            return langDPLFile;

        }
        private List<PropertyOverride> ReadProperties(string guid)
        {
            string path = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + guid + "/Properties/" + "Properties.xml";
            XmlSerializer deserializer = new XmlSerializer(typeof(List<PropertyOverride>));
            TextReader textReader = new StreamReader(path);
            List<PropertyOverride> simList = (List<PropertyOverride>)deserializer.Deserialize(textReader);
            textReader.Close();
            return simList;
        }
        public void Dispose()
        {

        }
    }





}
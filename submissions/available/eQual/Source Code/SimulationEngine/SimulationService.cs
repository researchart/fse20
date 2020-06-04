using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using System.Xml.Serialization;
using DomainPro.Analyst;
using DomainPro.Analyst.Engine;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Types;
using DomainPro.Core.Application;
using DomainPro.Core.Interfaces;
using DomainPro.Designer.Interfaces;

using DP_ModelBuilder = DomainPro.Analyst.Engine.DP_ModelBuilder;


namespace SimulationEngine
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "Service1" in both code and config file together.
    public class SimulationService : ISimulationService
    {
        private List<DP_Simulation> simulations = new List<DP_Simulation>();
        private DP_Project Project { set; get; }
        private DP_Language Language { set; get; }
        public Assembly LanguageAssembly { set; get; }
        public DP_IModelFactory ModelFactory { set; get; }
        public DP_ModelType ModelType { set; get; }
        public DP_IModel Model { set; get; }
        public string GetData(int value)
        {
            throw new NotImplementedException();
        }

        public CompositeType GetDataUsingDataContract(CompositeType composite)
        {
            throw new NotImplementedException();
        }


        
        public bool LoadProjectData(string modelConfig, string modelXml, string modelSimList, string languageManifest, string languageXml)
        {
            //BuildLanguageForCloud();
            Project = ReadProjectFile(modelConfig);
            Project.File = @"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\";
            Project.RootFolder = @"D:\Projects\DomainPro\trunk\Models\SmartRedundancy";
            Language = ReadLanguageFile(languageManifest);
            Language.File = @"D:\Projects\DomainPro\trunk\Languages\VolunteerComputing\";
            //buildSim(true);
            ReadAndInitializeSimulations(Project);
            
            //var ModelAssembly = Assembly.LoadFile(@"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\bin\SmartRedundancy.dll");
            
            simulations[0].Simulator = new DP_Simulator(simulations[0]);

            simulations[0].Simulator.RunForCloud();
            return true;
        }
        protected  void ReadAndInitializeSimulations(DP_Project project)
        {
            LanguageAssembly = Assembly.LoadFile(@"D:\Projects\DomainPro\trunk\Languages\VolunteerComputing\bin\VolunteerComputing.dll");
            ModelFactory = (DP_IModelFactory)LanguageAssembly.CreateInstance(Language.AnalystFactoryName);
            //ModelType = (DP_ModelType)ModelFactory.LoadModel(Path.Combine(Project.RootFolder, Project.ModelFile));

            ModelType = (DP_ModelType)ModelFactory.LoadModel(@"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\SmartRedundancy.xml");
            //ModelType.Initialize();
            //DP_ModelType model = (DP_ModelType)ModelFactory.LoadModel(Path.Combine(Project.RootFolder, Project.ModelFile));
            ModelType.Initialize();


            //simulations = ReadSimulationList(Path.Combine(Project.RootFolder, Project.Name + "SimList.xml"));
            simulations = ReadSimulationList(@"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\SmartRedundancySimList.xml");
                
                foreach (DP_Simulation sim in simulations)
                {
                    
                    //sim.SetProjectAndLanguage(Project, Language);
                    
                    sim.InitializeForCloud(LoadModelAssembly() , LanguageAssembly,ModelFactory, project, Language);
                }

                if (simulations.Count > 0)
                {
                    
                }
            
        }

        private Assembly LoadModelAssembly()
        {
            return Assembly.LoadFile(@"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\bin\SmartRedundancy.dll");
        }

        private DP_IModel LoadModel()
        {
            var modelAssembly = Assembly.LoadFile(@"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\bin\SmartRedundancy.dll");
            return (DP_IModel)modelAssembly.CreateInstance("Simulation." + ModelType.Name);
        }

        private List<DP_Simulation> ReadSimulationList(string listFile)
        {
            if (File.Exists(listFile))
            {
                try
                {
                    XmlSerializer deserializer = new XmlSerializer(typeof(List<DP_Simulation>));
                    TextReader textReader = new StreamReader(listFile);
                    List<DP_Simulation> simList = (List<DP_Simulation>)deserializer.Deserialize(textReader);
                    textReader.Close();
                    return simList;
                }
                catch (Exception e)
                {
                    MessageBox.Show(
                        string.Format("DomainPro Analyst was unable to load the simulation data for project \"{0}.\"\n\n" + "Exception: {1}", Project.Name, e.Message),
                        @"DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                }
            }
            return new List<DP_Simulation>();
        }
        private DP_Project ReadProjectFile(string projString)
        {
            DP_Project newProj = new DP_Project();

            TextReader reader = new StringReader(projString);

            string line = reader.ReadLine();
            while (line != null)
            {
                string[] words = line.Split(new[] { ' ' }, 2);
                if (words[0] == "Name")
                {
                    newProj.Name = words[1];
                }
                else if (words[0] == "Language")
                {
                    newProj.Language = words[1];
                }
                else if (words[0] == "Assembly")
                {
                    newProj.Assembly = words[1];
                }
                else if (words[0] == "Root")
                {
                    newProj.RootFolder = words[1];
                }
                else if (words[0] == "Model")
                {
                    newProj.ModelFile = words[1];
                }

                line = reader.ReadLine();
            }

            reader.Close();

            return newProj;
        }
        private DP_Language ReadLanguageFile(string languageFile)
        {
            DP_Language newLang = new DP_Language();


            TextReader reader = new StringReader(languageFile);

            string line = reader.ReadLine();
            while (line != null)
            {
                string[] words = line.Split(' ');
                if (words[0] == "Name")
                {
                    newLang.Name = words[1];
                }
                else if (words[0] == "Assembly")
                {
                    newLang.Assembly = words[1];
                }
                else if (words[0] == "DesignerFactory")
                {
                    newLang.DesignerFactoryName = words[1];
                }
                else if (words[0] == "AnalystFactory")
                {
                    newLang.AnalystFactoryName = words[1];
                }

                line = reader.ReadLine();
            }

            reader.Close();
            return newLang;
        }
        private void buildSim(bool inDebugMode)
        {
            DP_ModelBuilder builder = new DP_ModelBuilder();
             LanguageAssembly = Assembly.LoadFile(@"D:\Projects\DomainPro\trunk\Languages\VolunteerComputing\bin\VolunteerComputing.dll");
             ModelFactory = (DP_IModelFactory)LanguageAssembly.CreateInstance(Language.AnalystFactoryName);
            //ModelType = (DP_ModelType)ModelFactory.LoadModel(Path.Combine(Project.RootFolder, Project.ModelFile));

             ModelType = (DP_ModelType)ModelFactory.LoadModel(@"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\SmartRedundancy.xml");
            //ModelType.Initialize();
            //DP_ModelType model = (DP_ModelType)ModelFactory.LoadModel(Path.Combine(Project.RootFolder, Project.ModelFile));
            ModelType.Initialize();

            string fileList = builder.Build(ModelType, Project.RootFolder);

            Project.Assembly = Path.Combine("bin", Project.Name + ".dll");

          

            Process compileProcess = new Process();
            compileProcess.StartInfo.UseShellExecute = false;
            compileProcess.StartInfo.FileName = Environment.ExpandEnvironmentVariables("%windir%\\Microsoft.NET\\Framework\\v4.0.30319\\Csc.exe");
            compileProcess.StartInfo.CreateNoWindow = true;
            compileProcess.StartInfo.WorkingDirectory = Project.RootFolder;

            string args = "";
            if (inDebugMode)
                args = "/noconfig /warn:4 /define:DEBUG;TRACE /debug+ /debug:full /filealign:512 /optimize- ";
            else
                args = "/noconfig /warn:4 /define:TRACE /filealign:512 /optimize+ ";

            string dpRefs =
                "/reference:\"" + Path.Combine(@"D:\Projects\DomainPro\trunk\DomainPro\", "DomainPro Analyst.exe") + "\" " +
                "/reference:\"" + Path.Combine(@"D:\Projects\DomainPro\trunk\DomainPro\", "Assemblies\\DomainProCore.dll") + "\" " +
                "/reference:\"" + Path.Combine(Path.GetDirectoryName(Language.File), Language.Assembly) + "\" ";
            string frameworkRefs = Environment.ExpandEnvironmentVariables("/reference:System.Core.dll /reference:System.Data.DataSetExtensions.dll /reference:System.Data.dll /reference:System.dll /reference:System.Windows.Forms.dll /reference:System.Xml.dll /reference:System.Xml.Linq.dll ");
            string output = "/out:" + Project.Assembly + " /target:library ";
            string include = "Properties\\AssemblyInfo.cs " + fileList;
            compileProcess.StartInfo.Arguments = args + dpRefs + frameworkRefs + output + include;
            compileProcess.StartInfo.RedirectStandardOutput = true;
            compileProcess.StartInfo.RedirectStandardError = true;

            compileProcess.Start();

            DateTime startCompileTime = DateTime.Now;
            TimeSpan compileDuration = DateTime.Now - startCompileTime;
            while (!compileProcess.HasExited && compileDuration.Seconds < 10)
            {
                compileDuration = DateTime.Now - startCompileTime;
            }
            if (!compileProcess.HasExited)
            {
                compileProcess.Kill();
            }

            compileProcess.Dispose();

        
        }

    }
}

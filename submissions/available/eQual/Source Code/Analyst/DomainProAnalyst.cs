/*
Copyright 2013 George Edwards

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License. 
*/
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Reflection;
using System.Windows.Forms;
using System.IO;
using System.Xml.Serialization;
using System.Threading;
using System.Diagnostics;
using DomainPro.Core;
using DomainPro.Core.Interfaces;
using DomainPro.Core.Types;
using DomainPro.Core.Application;
using DomainPro.Analyst.Controls;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst
{

    public partial class 
        DomainProAnalyst : DP_Application
    {

        // TBD
        public Assembly ModelAssembly;

        // Selection state fields
        /*
        private List<DP_Simulation> currentSimulations;

        public List<DP_Simulation> CurrentSimulations
        {
            get { return currentSimulations; }
            set { currentSimulations = value; }
        }
         * */

        private DP_Simulation selectedSimulation;

        public DP_Simulation SelectedSimulation
        {
            get { return selectedSimulation; }
            set { selectedSimulation = value; }
        }

        // Windows

        // Misc local fields
        private FileSystemWatcher watcher;
        private List<DP_Simulation> simulations = new List<DP_Simulation>();


        // Default constructor
        public DomainProAnalyst(string currentDirectory = null) : base(currentDirectory)
        {

            ContextProvider.IsCloudSim = currentDirectory != null;
            InitializeComponent();

            AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(LanguageAssemblyResolveHandler);

            DomainProAnalyst.instance = this;

            openToolStripMenuItem.Click += OpenClick;

            openToolButton.Click += OpenClick;
            saveToolButton.Click += SaveClick;
            closeToolButton.Click += CloseClick;
            buildModelButton.Click += BuildClick;
            newSimulationButton.Click += NewSimClick;
            deleteSimulationButton.Click += DeleteSimClick;
            runButton.Click += RunSimClick;
            advanceButton.Click += AdvanceSimClick;
            pauseButton.Click += PauseSimClick;
            stopButton.Click += StopSimClick;

            consoleTextBox.TextChanged += ConsoleTextChanged;

            saveToolButton.Enabled = false;
            closeToolButton.Enabled = false;
            buildModelButton.Enabled = false;
            newSimulationButton.Enabled = false;
            deleteSimulationButton.Enabled = false;
            runButton.Enabled = false;
            advanceButton.Enabled = false;
            pauseButton.Enabled = false;
            stopButton.Enabled = false;

            //languageComboBox.Enabled = false;
            //languageComboBox.TextChanged += ChangeLanguageClick;
        }

        protected override void OpenWindows()
        {

        }

        protected override void CloseWindows()
        {

        }

        protected override void CreateProjectData()
        {

        }

        protected override void WriteProjectData(DP_Project project)
        {
            WriteSimulationList(simulations);
        }

        protected override void ReadProjectData(DP_Project project)
        {
            simulations = ReadSimulationList(Path.Combine(Project.RootFolder, Project.Name + "SimList.xml"));
            try
            {
                foreach (DP_Simulation sim in simulations)
                {
                    sim.Initialize();
                }

                if (simulations.Count > 0)
                {
                    simulations[0].Select();
                }
            }
            catch (Exception e)
            {
                DialogResult result = MessageBox.Show(
                    "DomainPro Analyst was unable to load the model data for project \"" + Project.Name + ".\"\n\n" +
                    "Exception:\n" +
                    e.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
            }
        }

        protected override void DestroyProjectData()
        {
            SelectedSimulation = null;
            Project = null;
            ModelAssembly = null;

            watcher.Changed -= ModelChanged;
            watcher.EnableRaisingEvents = false;
            watcher.Dispose();

            foreach (DP_Simulation sim in simulations)
            {
                sim.Destroy();
            }

            simulations.Clear();
        }

        protected override void LoadLanguage(DP_Language language)
        {
            try
            {
                var loadedAssembiles = AppDomain.CurrentDomain.GetAssemblies();
                var loadedLanguage = from items in loadedAssembiles where items.FullName.Contains(language.Name) select items;
                if (loadedLanguage.Any())
                    LanguageAssembly = loadedLanguage.FirstOrDefault();
                else
                {
                    LanguageAssembly = Assembly.LoadFile(Path.Combine(Path.GetDirectoryName(language.File), language.Assembly));
                }
                ModelFactory = (DP_IModelFactory)LanguageAssembly.CreateInstance(language.AnalystFactoryName);
            }
            catch (Exception e)
            {
                if (language.Name == "LanguageBuilder")
                {
                    DialogResult result = MessageBox.Show(
                        "The project \"" + Project.Name + "\" appears to be a metamodel. Try opening this project in DomainPro Designer instead.\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                }
                else
                {
                    DialogResult result = MessageBox.Show(
                        "DomainPro Analyst was unable to load the language \"" + language.Name + ".\" Try regenerating the language assembly.\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                }
            }
        }

        protected override void DisplayProject()
        {
            saveToolButton.Enabled = true;
            closeToolButton.Enabled = true;
            buildModelButton.Enabled = true;
            newSimulationButton.Enabled = true;

            modelNameText.Text = Project.Name;

            watcher = new FileSystemWatcher();
            watcher.Path = Project.RootFolder;
            watcher.Filter = Project.ModelFile;
            watcher.NotifyFilter = NotifyFilters.LastWrite;
            watcher.Changed += ModelChanged;
            watcher.EnableRaisingEvents = true;
        }

        protected override void HideProject()
        {
            saveToolButton.Enabled = false;
            closeToolButton.Enabled = false;
            buildModelButton.Enabled = false;
            newSimulationButton.Enabled = false;
            deleteSimulationButton.Enabled = false;
            runButton.Enabled = false;
            advanceButton.Enabled = false;

            modelNameText.Text = "";
            modelLanguageText.Text = "";
            simulationTabControl.TabPages.Clear();
        }

        protected override void DisplayLanguage()
        {
            modelLanguageText.Text = Language.Name;
        }

        protected override void HideLanguage()
        {
            modelLanguageText.Text = "";
        }

        /*
        private void ClearSimDataPanel()
        {
            nowExecutingText.Text = "";
            startedAtText.Text = "";
            runningTimeText.Text = "";
            estimatedCompletionText.Text = "";
            simTimeText.Text = "";
            
        }
         * */

        private void ModelChanged(object sender, FileSystemEventArgs e)
        {
            watcher.Changed -= ModelChanged;
            watcher.EnableRaisingEvents = false;
            watcher.Dispose();

            this.Invoke((MethodInvoker)delegate
            {
                Report("The model " + " was been modified. Rebuild the model to incorporate the changes.");
                Report("********************************************************************************");
                Report("");
            });

            watcher = new FileSystemWatcher();
            watcher.Path = Project.RootFolder;
            watcher.Filter = Project.ModelFile;
            watcher.NotifyFilter = NotifyFilters.LastWrite;
            watcher.Changed += ModelChanged;
            watcher.EnableRaisingEvents = true;
        }

        /*
        private void CheckReload()
        {
            DialogResult checkReload = MessageBox.Show("The model has been modified.\n\nDo you want to reload it?",
                "DomainPro",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Exclamation);

            if (checkReload == DialogResult.Yes)
            {
                // TODO
                string projectFile = Project.File;
                SaveProject();
                CloseProject();
                LoadProject(projectFile);
            }
        }
         * */

        /*
        public void ReloadProject(object sender, EventArgs e)
        {
            reloadDialog.Dispose();
            string projectFile = Project.File;
            SaveProject();
            CloseProject();
            LoadProject(projectFile);
        }
         * */

        private void WriteSimulationList(List<DP_Simulation> simList)
        {
            try
            {
                XmlSerializer serializer = new XmlSerializer(typeof(List<DP_Simulation>));
                TextWriter textWriter = new StreamWriter(Path.Combine(Project.RootFolder, Project.Name + "SimList.xml"));
                serializer.Serialize(textWriter, simList);
                textWriter.Close();
            }
            catch (Exception e)
            {
                DialogResult result = MessageBox.Show(
                        "DomainPro Analyst was unable to save the simulation data for project \"" + Project.Name + ".\"\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
            }
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
                    DialogResult result = MessageBox.Show(
                        "DomainPro Analyst was unable to load the simulation data for project \"" + Project.Name + ".\"\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                }
            }
            return new List<DP_Simulation>();
        }

        private void RunSimulation()
        {
            Thread simThread = new Thread(new ThreadStart(SelectedSimulation.Simulator.Run));
            simThread.Priority = ThreadPriority.Lowest;
            simThread.Name = "MainSimLoop: " + SelectedSimulation.Name;
            simThread.Start();
        }

        private void AdvanceSimulation()
        {
            Thread simThread = new Thread(new ThreadStart(SelectedSimulation.Simulator.Advance));
            simThread.Priority = ThreadPriority.Lowest;
            simThread.Name = "MainSimLoop: " + SelectedSimulation.Name;
            simThread.Start();
        }

        private void ConsoleTextChanged(object sender, EventArgs e)
        {
            consoleTextBox.SelectionStart = consoleTextBox.Text.Length;
            consoleTextBox.ScrollToCaret();
        }



        private void BuildClick(object sender, EventArgs e)
        {
            buildSim(true);
        }

      
        private void buildSim(bool inDebugMode)
        {
            Report("Building model " + Project.Name + "...");

            DP_ModelBuilder builder = new DP_ModelBuilder();

            DP_ModelType model = (DP_ModelType)ModelFactory.LoadModel(Path.Combine(Project.RootFolder, Project.ModelFile));
            model.Initialize();

            string fileList = builder.Build(model, Project.RootFolder);

            Project.Assembly = Path.Combine("bin", Project.Name + ".dll");

            Report("Compiling model " + Project.Name + "...");

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
                "/reference:\"" + Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainPro Analyst.exe") + "\" " +
                "/reference:\"" + Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "Assemblies\\DomainProCore.dll") + "\" " +
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

            Report(compileProcess.StandardOutput.ReadToEnd());
            Report(compileProcess.StandardError.ReadToEnd());

            if (!compileProcess.HasExited)
            {
                compileProcess.Kill();
            }

            compileProcess.Dispose();

            Report("********************************************************************************");
            Report("");
        }

        public DP_ModelType ModelType
        {
            get
            {
                DP_ModelType model = (DP_ModelType)ModelFactory.LoadModel(Path.Combine(Project.RootFolder, Project.ModelFile));
                model.Initialize();
                return model;
            }
        }

        public void LoadModelAssembly()
        {
            try
            {
                ModelAssembly = Assembly.LoadFile(Path.Combine(Path.GetFullPath(Project.RootFolder), Project.Assembly));

                
            }
            catch (Exception exception)
            {
                DialogResult result = MessageBox.Show(
                    "DomainPro Analyst was unable to load the model \"" + Project.Name + ".\" Try rebuilding the model assembly.\n\n" +
                    "Exception: " +
                    exception.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
                return;
            }
        }
        public void RunSimClick(object sender, EventArgs e)
        {
            if (ModelAssembly == null)
            {
                try
                {
                    ModelAssembly = Assembly.LoadFile(Path.Combine(Path.GetFullPath(Project.RootFolder), Project.Assembly));
                }
                catch (Exception exception)
                {
                    DialogResult result = MessageBox.Show(
                        "DomainPro Analyst was unable to load the model \"" + Project.Name + ".\" Try rebuilding the model assembly.\n\n" +
                        "Exception: " +
                        exception.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                    return;
                }
            }

            if (SelectedSimulation.Status == "Idle")
            {
                SelectedSimulation.Simulator = new DP_Simulator(SelectedSimulation);
            }

            pauseButton.Enabled = true;
            stopButton.Enabled = true;

            RunSimulation();
        }

        private void AdvanceSimClick(object sender, EventArgs e)
        {
            if (ModelAssembly == null)
            {
                try
                {
                    ModelAssembly = Assembly.LoadFile(Path.Combine(Path.GetFullPath(Project.RootFolder), Project.Assembly));
                }
                catch (Exception exception)
                {
                    DialogResult result = MessageBox.Show(
                        "DomainPro Analyst was unable to load the model \"" + Project.Name + ".\" Try rebuilding the model assembly.\n\n" +
                        "Exception: " +
                        exception.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                    return;
                }
            }

            if (SelectedSimulation.Status == "Idle")
            {
                SelectedSimulation.Simulator = new DP_Simulator(SelectedSimulation);
            }

            AdvanceSimulation();
        }

        private void PauseSimClick(object sender, EventArgs e)
        {
            if (SelectedSimulation.Status == "Executing")
            {
                SelectedSimulation.Status = "Paused";

                pauseButton.Enabled = false;
                stopButton.Enabled = false;
            }
        }

        private void StopSimClick(object sender, EventArgs e)
        {
            if (SelectedSimulation.Status == "Executing")
            {
                SelectedSimulation.Status = "Idle";

                pauseButton.Enabled = false;
                stopButton.Enabled = false;
            }
        }

        private void NewSimClick(object sender, EventArgs e)
        {
            DP_Simulation simulation = new DP_Simulation();
            simulation.Position = simulations.Count;
            simulation.Initialize();
            simulations.Add(simulation);
            simulation.Select();
        }

        private void DeleteSimClick(object sender, EventArgs e)
        {
            for (int i = SelectedSimulation.Position; i < simulations.Count; i++)
            {
                simulations[i].Position--;
            }

            simulations.Remove(SelectedSimulation);
            SelectedSimulation.Destroy();
        }

        public void SelectSim(DP_Simulation sim)
        {
            if (SelectedSimulation == sim)
            {
                return;
            }
            if (SelectedSimulation != null)
            {
                SelectedSimulation.Deselect();
            }
            SelectedSimulation = sim;
            if (SelectedSimulation != null)
            {
                runButton.Enabled = true;
                advanceButton.Enabled = true;
                deleteSimulationButton.Enabled = true;
            }
        }

        public static DomainProAnalyst instance;

        public static DomainProAnalyst Instance
        {
            get { return instance; }
        }

        public void Report(string s)
        {
            if (ContextProvider.IsCloudSim)
            {
                consoleTextBox.Text += s + "\n";
            }
            else this.Invoke((MethodInvoker)delegate
            {
                consoleTextBox.Text += s + "\n";
            });

        }

        private Assembly LanguageAssemblyResolveHandler(object sender, ResolveEventArgs e)
        {
            if (e.Name.Contains(Language.Name))
            {
                return LanguageAssembly;
            }
            else
            {
                return null;
            }
        }


        public List<DP_Simulation> LoadedSimulations
        {
            get { return simulations; }
        } 

    }

}

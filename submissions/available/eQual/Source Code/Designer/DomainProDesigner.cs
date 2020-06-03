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
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Reflection;
using System.Diagnostics;
using Infragistics.Win.UltraWinDock;
using DomainPro.Core;
using DomainPro.Core.Interfaces;
using DomainPro.Core.Types;
using DomainPro.Core.Application;
using DomainPro.Designer.Types;
using DomainPro.Designer.Interfaces;
using DomainPro.Designer.Controls;

namespace DomainPro.Designer
{
    public partial class DomainProDesigner : DP_Application
    {
        public Color SelectionColor
        {
            get { return Color.Green; }
        }

        public Size SelectionMarkerSize
        {
            get { return new Size(5, 5); }
        }

        public int SelectionBorderWidth
        {
            get { return 2; }
        }

        public int StartDragSize
        {
            get { return 2; }
        }

        public int StartSelectSize
        {
            get { return 4; }
        }

        public int SnapSize
        {
            get { return 15; }
        }

        public int LineEndSize
        {
            get { return 15; }
        }

        private DP_ModelType model;

        public DP_ModelType Model
        {
            get { return model; }
            set { model = value; }
        }

        private DP_Diagram mainDiagram;

        public DP_Diagram MainDiagram
        {
            get { return mainDiagram; }
            set { mainDiagram = value; }
        }

        private DP_Diagram lastMainDiagram;

        public DP_Diagram LastMainDiagram
        {
            get { return lastMainDiagram; }
            set { lastMainDiagram = value; }
        }

        // Selection state fields

        public class DP_ConcreteTypeCollection
        {
            private readonly DP_TypeCollection<DP_ConcreteType> selected = new DP_TypeCollection<DP_ConcreteType>();

            private readonly DomainProDesigner designer;

            internal DP_ConcreteTypeCollection(DomainProDesigner designerInstance)
            {
                designer = designerInstance;
            }

            public DP_ConcreteType this[int index]
            {
                get { return selected[index]; }
            }

            public void Add(DP_ConcreteType type)
            {
                if (!selected.Contains(type))
                {
                    type.Selected = true;
                    selected.Add(type);
                    designer.propertyGrid.SelectedObjects = selected.ToArray();
                }
            }

            public void Remove(DP_ConcreteType type)
            {
                if (selected.Contains(type))
                {
                    type.Selected = false;
                    selected.Remove(type);
                }
            }

            public bool Contains(DP_ConcreteType type)
            {
                return selected.Contains(type);
            }

            public int Count
            {
                get { return selected.Count; }
            }

            public void Clear()
            {
                foreach (DP_ConcreteType type in selected)
                {
                    type.Selected = false;
                }
                selected.Clear();
                designer.propertyGrid.SelectedObject = null;
            }

            public IEnumerator GetEnumerator()
            {
                return selected.GetEnumerator();
            }
        }

        private readonly DP_ConcreteTypeCollection selected;

        public DP_ConcreteTypeCollection Selected
        {
            get { return selected; }
        }

        public class DP_ConnectionSpec
        {
            private DP_ConcreteType attached;

            public DP_ConcreteType Attached
            {
                get { return attached; }
                set { attached = value; }
            }

            private Point offset;

            public Point Offset
            {
                get { return offset; }
                set { offset = value; }
            }
        }

        private DP_ConnectionSpec connectionStart;

        public DP_ConnectionSpec ConnectionStart
        {
            get { return connectionStart; }
            set { connectionStart = value; }
        }

        // Windows
        private DP_DiagramWindow diagramWin = new DP_DiagramWindow();

        // Misc private fields
        private const string designerGeneratorName = "LanguageBuilder.Generators.DP_DesignerGenerator";
        private const string analystGeneratorName = "LanguageBuilder.Generators.DP_AnalystGenerator";

        // Default constructor
        public DomainProDesigner()
        {
            InitializeComponent();

            DomainProDesigner.instance = this;
            selected = new DP_ConcreteTypeCollection(this);

            // File menu
            newToolStripMenuItem.Click += NewClick;
            saveToolStripMenuItem.Click += SaveClick;
            saveAsToolStripMenuItem.Click += SaveAsClick;
            openToolStripMenuItem.Click += OpenClick;
            closeToolStripMenuItem.Click += CloseClick;
            exitToolStripMenuItem.Click += ExitClick;

            // Edit menu
            copyToolStripMenuItem.Click += CopyClick;
            pasteToolStripMenuItem.Click += PasteClick;
            projectSettingsToolStripMenuItem.Click += ChangeProjectSettingsClick;

            // Window menu
            modelTreeToolStripMenuItem.Click += ShowHideModelTreeClick;
            propertiesToolStripMenuItem.Click += ShowHidePropertiesClick;
            textEditorToolStripMenuItem.Click += ShowHideTextEditorClick;
            outputToolStripMenuItem.Click += ShowHideOutputClick;
            dockManager.AfterPaneButtonClick += DockManagerPaneButtonClick;

            if (dockManager.ControlPanes[modelTreeView].Closed)
            {
                modelTreeToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                modelTreeToolStripMenuItem.CheckState = CheckState.Checked;
            }

            if (dockManager.ControlPanes[propertyGrid].Closed)
            {
                propertiesToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                propertiesToolStripMenuItem.CheckState = CheckState.Checked;
            }

            if (dockManager.ControlPanes[textTabControl].Closed)
            {
                textEditorToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                textEditorToolStripMenuItem.CheckState = CheckState.Checked;
            }

            if (dockManager.ControlPanes[outputTextBox].Closed)
            {
                outputToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                outputToolStripMenuItem.CheckState = CheckState.Checked;
            }

            // Help menu
            aboutDomainProToolStripMenuItem.Click += AboutClick;

            // Toolbar
            newToolButton.Click += NewClick;
            saveToolButton.Click += SaveClick;
            openToolButton.Click += OpenClick;
            projectSettingsToolButton.Click += ChangeProjectSettingsClick;
            closeToolButton.Click += CloseClick;

            generateToolButton.Click += InterpretClick;

            createToolButton.Click += CreateToolClick;
            connectToolButton.Click += ConnectToolClick;
            connectToolButton.CheckedChanged += ConnectToolCheckChanged;
            deleteToolButton.Click += DeleteToolClick;
            copyToolButton.Click += CopyClick;
            pasteToolButton.Click += PasteClick;
            bringToFrontToolButton.Click += BringToFrontClick;
            alignHorizontalToolButton.Click += AlignHorizontalClick;
            alignVeriticalToolButton.Click += AlignVerticalClick;

            backToolButton.Click += BackClick;
            upToolButton.Click += UpClick;
            downToolButton.Click += DownClick;
            undoToolButton.Click += UndoClick;
            redoToolButton.Click += RedoClick;

            newToolStripMenuItem.Enabled = false;
            saveToolStripMenuItem.Enabled = false;
            saveAsToolStripMenuItem.Enabled = false;
            projectSettingsToolStripMenuItem.Enabled = false;
            //openToolStripMenuItem.Enabled = true;
            closeToolStripMenuItem.Enabled = false;

            newToolButton.Enabled = false;
            saveToolButton.Enabled = false;
            //openToolButton.Enabled = false;
            projectSettingsToolButton.Enabled = false;
            closeToolButton.Enabled = false;

            generateToolButton.Enabled = false;
            checkToolButton.Enabled = false;

            createToolButton.Enabled = false;
            connectToolButton.Enabled = false;
            deleteToolButton.Enabled = false;
            copyToolButton.Enabled = false;
            pasteToolButton.Enabled = false;
            bringToFrontToolButton.Enabled = false;
            alignHorizontalToolButton.Enabled = false;
            alignVeriticalToolButton.Enabled = false;

            backToolButton.Enabled = false;
            upToolButton.Enabled = false;
            downToolButton.Enabled = false;
            undoToolButton.Enabled = false;
            redoToolButton.Enabled = false;

            modelTreeView.KeyDown += TreeKeyDown;
            modelTreeView.NodeMouseClick += TreeNodeMouseClick;
            modelTreeView.NodeMouseDoubleClick += TreeNodeMouseDoubleClick;
            modelTreeView.AfterLabelEdit += TreeNodeAfterLabelEdit;
            modelTreeView.AfterSelect += TreeAfterSelect;
            modelTreeView.ExpandAll();

            foreach (DP_Language lang in languages)
            {
                languageComboBox.Items.Add(lang.Name);
            }
            languageComboBox.SelectedIndexChanged += ChangeLanguageClick;
            languageComboBox.KeyUp += LanguageKeyUp;

            languageComboBox.SelectedItem = "LanguageBuilder";

            ProcessCommandLine();
        }

        protected override void OpenWindows()
        {
            diagramWin = new DP_DiagramWindow();

            //diagramWin.TopLevel = false;
            //diagramWin.FormBorderStyle = FormBorderStyle.None;

            //dockManager.DockControls(new Control[] { diagramWin }, DockedLocation.Floating, ChildPaneStyle.TabGroup);

            diagramWin.MdiParent = this;
            diagramWin.WindowState = FormWindowState.Maximized;
            //diagramWin.StartPosition = FormStartPosition.Manual;
            diagramWin.Show();
        }

        protected override void CloseWindows()
        {
            diagramWin.Close();
        }

        protected override void CreateProjectData()
        {
            Model = (DP_ModelType) ModelFactory.CreateModel();
        }

        protected override void WriteProjectData(DP_Project project)
        {
            ModelFactory.SaveModel(Model, Path.Combine(project.RootFolder, project.ModelFile));
        }

        protected override void ReadProjectData(DP_Project project)
        {
            Model = (DP_ModelType) ModelFactory.LoadModel(Path.Combine(project.RootFolder, project.ModelFile));
        }

        protected override void DestroyProjectData()
        {
            Model = null;
            MainDiagram = null;
            LastMainDiagram = null;
            modelTreeView.Nodes.Clear();
            propertyGrid.SelectedObject = null;
        }

        protected override void LoadLanguage(DP_Language language)
        {
            LanguageAssembly =
                Assembly.LoadFile(
                    (Path.Combine(Environment.ExpandEnvironmentVariables(Path.GetDirectoryName(language.File)),
                        language.Assembly)));
            ModelFactory = (DP_IModelFactory) LanguageAssembly.CreateInstance(language.DesignerFactoryName);
        }

        protected override void DisplayProject()
        {
            languageComboBox.Enabled = false;

            saveToolStripMenuItem.Enabled = true;
            saveAsToolStripMenuItem.Enabled = true;
            projectSettingsToolStripMenuItem.Enabled = true;
            closeToolStripMenuItem.Enabled = true;

            saveToolButton.Enabled = true;
            projectSettingsToolButton.Enabled = true;
            closeToolButton.Enabled = true;

            if (Language.Name == "LanguageBuilder")
            {
                generateToolButton.Enabled = true;
            }
            checkToolButton.Enabled = true;

            createToolButton.Enabled = true;
            connectToolButton.Enabled = true;
            deleteToolButton.Enabled = true;
            copyToolButton.Enabled = true;
            pasteToolButton.Enabled = true;
            bringToFrontToolButton.Enabled = true;
            alignHorizontalToolButton.Enabled = true;
            alignVeriticalToolButton.Enabled = true;

            backToolButton.Enabled = true;
            upToolButton.Enabled = true;
            downToolButton.Enabled = true;
            undoToolButton.Enabled = true;
            redoToolButton.Enabled = true;


            InitializeModel();
        }

        private void InitializeModel()
        {
            // Adds the diagram panel to the window and sets its size
            diagramWin.Add(Model);

            // Adds the root node node to the model tree
            modelTreeView.Nodes.Add(Model.TreeRoot);
            modelTreeView.SelectedNode = Model.TreeRoot;

            Model.Initialize();
        }

        protected override void HideProject()
        {
            languageComboBox.Enabled = true;
            saveToolStripMenuItem.Enabled = false;
            saveAsToolStripMenuItem.Enabled = false;
            projectSettingsToolStripMenuItem.Enabled = false;
            closeToolStripMenuItem.Enabled = false;

            saveToolButton.Enabled = false;
            projectSettingsToolButton.Enabled = false;
            closeToolButton.Enabled = false;

            generateToolButton.Enabled = false;
            checkToolButton.Enabled = false;

            createToolButton.Enabled = false;
            createToolButton.Checked = false;
            connectToolButton.Enabled = false;
            connectToolButton.Checked = false;
            deleteToolButton.Enabled = false;
            deleteToolButton.Checked = false;
            copyToolButton.Enabled = false;
            pasteToolButton.Enabled = false;
            bringToFrontToolButton.Enabled = false;
            alignHorizontalToolButton.Enabled = false;
            alignVeriticalToolButton.Enabled = false;

            backToolButton.Enabled = false;
            upToolButton.Enabled = false;
            downToolButton.Enabled = false;
            undoToolButton.Enabled = false;
            redoToolButton.Enabled = false;
        }

        protected override void DisplayLanguage()
        {
            newToolStripMenuItem.Enabled = true;
            openToolStripMenuItem.Enabled = true;

            newToolButton.Enabled = true;

            if (!languageComboBox.Items.Contains(Language.Name))
            {
                languageComboBox.Items.Add(Language.Name);
            }
            languageComboBox.SelectedItem = Language.Name;
            languageComboBox.Text = Language.Name;
        }

        protected override void HideLanguage()
        {
        }

        private void CopyClick(object sender, EventArgs e)
        {
            Model.DiagramPanel.Copy();
        }

        private void PasteClick(object sender, EventArgs e)
        {
            Model.DiagramPanel.Paste();
        }

        private void DockManagerPaneButtonClick(object sender, PaneButtonEventArgs e)
        {
            if (e.Button == PaneButton.Close)
            {
                if (e.Pane.Text == "Model Tree")
                {
                    modelTreeToolStripMenuItem.CheckState = CheckState.Unchecked;
                }
                else if (e.Pane.Text == "Properties")
                {
                    propertiesToolStripMenuItem.CheckState = CheckState.Unchecked;
                }
                else if (e.Pane.Text == "Text Editor")
                {
                    textEditorToolStripMenuItem.CheckState = CheckState.Unchecked;
                }
                else if (e.Pane.Text == "Output")
                {
                    outputToolStripMenuItem.CheckState = CheckState.Unchecked;
                }
            }
        }

        private void ShowHideModelTreeClick(object sender, EventArgs e)
        {
            if (modelTreeView.Visible)
            {
                dockManager.ControlPanes[modelTreeView].Closed = true;
                modelTreeToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                dockManager.ControlPanes[modelTreeView].Closed = false;
                modelTreeToolStripMenuItem.CheckState = CheckState.Checked;
            }
        }

        private void ShowHidePropertiesClick(object sender, EventArgs e)
        {
            if (propertyGrid.Visible)
            {
                dockManager.ControlPanes[propertyGrid].Closed = true;
                propertiesToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                dockManager.ControlPanes[propertyGrid].Closed = false;
                propertiesToolStripMenuItem.CheckState = CheckState.Checked;
            }
        }

        private void ShowHideTextEditorClick(object sender, EventArgs e)
        {
            if (textTabControl.Visible)
            {
                dockManager.ControlPanes[textTabControl].Closed = true;
                textEditorToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                dockManager.ControlPanes[textTabControl].Closed = false;
                textEditorToolStripMenuItem.CheckState = CheckState.Checked;
            }
        }

        private void ShowHideOutputClick(object sender, EventArgs e)
        {
            if (outputTextBox.Visible)
            {
                dockManager.ControlPanes[outputTextBox].Closed = true;
                outputToolStripMenuItem.CheckState = CheckState.Unchecked;
            }
            else
            {
                dockManager.ControlPanes[outputTextBox].Closed = false;
                outputToolStripMenuItem.CheckState = CheckState.Checked;
            }
        }

        private void AboutClick(object sender, EventArgs e)
        {
        }

        private void CreateToolClick(object sender, EventArgs e)
        {
            connectToolButton.Checked = false;
            deleteToolButton.Checked = false;
            copyToolButton.Checked = false;
        }

        private void CreateToolDoubleClick(object sender, EventArgs e)
        {
            connectToolButton.Checked = false;
            deleteToolButton.Checked = false;
            copyToolButton.Checked = false;
        }

        private void ConnectToolCheckChanged(object sender, EventArgs e)
        {
            if (ConnectionStart != null)
            {
                if (ConnectionStart.Attached != null)
                {
                    Model.DiagramPanel.MouseMove -= ConnectionStart.Attached.Parent.DiagramPanelConnLineDrag;
                    Model.DiagramPanel.Paint -= ConnectionStart.Attached.Parent.DiagramPanelDrawConnLine;
                }
                else
                {
                    Model.DiagramPanel.MouseMove -= MainDiagram.DiagramPanelConnLineDrag;
                    Model.DiagramPanel.Paint -= MainDiagram.DiagramPanelDrawConnLine;
                }
                Model.DiagramPanel.Invalidate(false);
            }
            ConnectionStart = null;
        }

        private void ConnectToolClick(object sender, EventArgs e)
        {
            createToolButton.Checked = false;
            deleteToolButton.Checked = false;
            copyToolButton.Checked = false;
            Selected.Clear();
        }

        private void DeleteToolClick(object sender, EventArgs e)
        {
            connectToolButton.Checked = false;
            createToolButton.Checked = false;
            copyToolButton.Checked = false;
        }

        private void BringToFrontClick(object sender, EventArgs e)
        {
            foreach (DP_ConcreteType type in Selected)
            {
                type.Parent.Types.Remove(type);
                type.Parent.Types.Add(type);
                type.Invalidate();
            }
        }

        private void AlignHorizontalClick(object sender, EventArgs e)
        {
            int ySum = 0;
            foreach (DP_ConcreteType type in Selected)
            {
                if (type is DP_Shape)
                {
                    ySum += type.Center.Y;
                }
            }
            int avgY = (int) Math.Round(ySum/(double) Selected.Count);
            foreach (DP_ConcreteType type in Selected)
            {
                if (type is DP_Shape)
                {
                    type.Location = new Point(type.Left, avgY - type.Height/2);
                }
            }
        }

        private void AlignVerticalClick(object sender, EventArgs e)
        {
            int xSum = 0;
            foreach (DP_ConcreteType type in Selected)
            {
                if (type is DP_Shape)
                {
                    xSum += type.Center.X;
                }
            }
            int avgX = (int) Math.Round(xSum/(double) Selected.Count);
            foreach (DP_ConcreteType type in Selected)
            {
                if (type is DP_Shape)
                {
                    type.Location = new Point(avgX - type.Width/2, type.Top);
                }
            }
        }

        private void UpClick(object sender, EventArgs e)
        {
            if (MainDiagram.Parent != null && MainDiagram.Parent.Parent != null)
            {
                Selected.Clear();
                MainDiagram.Parent.Parent.MakeMainDiagram();
                Selected.Add(LastMainDiagram.Parent);
            }
        }

        private void BackClick(object sender, EventArgs e)
        {
            if (LastMainDiagram != null)
            {
                Selected.Clear();
                LastMainDiagram.MakeMainDiagram();
            }
        }

        private void DownClick(object sender, EventArgs e)
        {
            if (Selected.Count > 0)
            {
                if (Selected[0].Diagram != null)
                {
                    Selected[0].Diagram.MakeMainDiagram();
                }
            }
        }

        private void UndoClick(object sender, EventArgs e)
        {
        }

        private void RedoClick(object sender, EventArgs e)
        {
        }

        private void BuildLanguageForCloud()
        {
            if (Language.Name != "LanguageBuilder")
            {
                return;
            }

            if (Project.Name == null || Project.RootFolder == null)
            {
                if (!ProjectSettingsDialog(Project))
                {
                    return;
                }
            }

            TextWriter dplWriter = File.CreateText(Path.Combine(Project.RootFolder, Project.Name + ".dpl"));

            dplWriter.WriteLine("Name " + Model.Name);
            dplWriter.WriteLine("Assembly " + "bin\\" + Model.Name + ".dll");
            dplWriter.WriteLine("DesignerFactory Designer.Factories." + Model.Name + "ModelFactory");
            dplWriter.WriteLine("AnalystFactory Analyst.Factories." + Model.Name + "ModelFactory");

            dplWriter.Close();

            Directory.CreateDirectory(Path.Combine(Project.RootFolder, "Properties"));
            TextWriter assemblyWriter = File.CreateText(Path.Combine(Project.RootFolder, "Properties\\AssemblyInfo.cs"));

            assemblyWriter.WriteLine("using System.Reflection;");
            assemblyWriter.WriteLine("using System.Runtime.CompilerServices;");
            assemblyWriter.WriteLine("using System.Runtime.InteropServices;");

            assemblyWriter.WriteLine("[assembly: AssemblyTitle(\"" + model.Name + "\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyDescription(\"\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyConfiguration(\"\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyCompany(\"Blue Cell Software LLC\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyProduct(\"" + model.Name + "\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyCopyright(\"Copyright © Blue Cell Software LLC 2011\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyTrademark(\"\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyCulture(\"\")]");
            assemblyWriter.WriteLine("[assembly: ComVisible(false)]");
            assemblyWriter.WriteLine("[assembly: Guid(\"" + Guid.NewGuid() + "\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyVersion(\"0.0.0.0\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyFileVersion(\"0.0.0.0\")]");
            assemblyWriter.WriteLine();
            assemblyWriter.Close();

            string fileList = "";
            try
            {
                DP_IGenerator designerGenerator = (DP_IGenerator) LanguageAssembly.CreateInstance(designerGeneratorName);
                //fileList = designerGenerator.Generate(Model, Path.GetFullPath(Project.RootFolder));
            }
            catch (Exception exception)
            {
                DialogResult result = MessageBox.Show(
                    "Unable to generate designer code for project \"" + Project.Name + ".\"\n\n" +
                    "Exception: " +
                    exception.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
                return;
            }

            try
            {
                DP_IGenerator analystGenerator =
                    (DP_IGenerator)
                        LanguageAssembly.CreateInstance("LanguageBuilder.Generators.DP_AnalystGenerator");
                fileList += analystGenerator.Generate(Model, Path.GetFullPath(Project.RootFolder));
            }
            catch (Exception exception)
            {
                DialogResult result = MessageBox.Show(
                    "Unable to generate analyst code for project \"" + Project.Name + ".\"\n\n" +
                    "Exception: " +
                    exception.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
                return;
            }


            Directory.CreateDirectory(Path.Combine(Project.RootFolder, "bin\\"));

            Project.Assembly = Path.Combine("bin\\", Project.Name + ".dll");

            Report("Compiling model " + Project.Name + "...");

            Process compileProcess = new Process();
            compileProcess = new Process();
            compileProcess.StartInfo.UseShellExecute = false;
            compileProcess.StartInfo.FileName =
                Environment.ExpandEnvironmentVariables("%windir%\\Microsoft.NET\\Framework\\v4.0.30319\\Csc.exe");
            compileProcess.StartInfo.CreateNoWindow = true;
            compileProcess.StartInfo.WorkingDirectory = Project.RootFolder;

            string args = "/noconfig /warn:4 /define:TRACE /filealign:512 /optimize+ ";
            string dpRefs =
                "/reference:\"" + Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainPro Designer.exe") + "\" " +
                "/reference:\"" + Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainPro Analyst.exe") + "\" " +
                "/reference:\"" +
                Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "Assemblies\\DomainProCore.dll") +
                "\" ";
            string frameworkRefs =
                Environment.ExpandEnvironmentVariables(
                    "/reference:System.Core.dll /reference:System.Data.DataSetExtensions.dll /reference:System.Data.dll /reference:System.dll /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Xml.dll /reference:System.Xml.Linq.dll ");
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
        }

        private void InterpretClick(object sender, EventArgs e)
        {
            //BuildLanguageForCloud();
            //return;
            // remove above lines to revert back to original version. 
            // Should Design separate logic for this part.
            if (Language.Name != "LanguageBuilder")
            {
                return;
            }

            if (Project.Name == null || Project.RootFolder == null)
            {
                if (!ProjectSettingsDialog(Project))
                {
                    return;
                }
            }

            TextWriter dplWriter = File.CreateText(Path.Combine(Project.RootFolder, Project.Name + ".dpl"));

            dplWriter.WriteLine("Name " + Model.Name);
            dplWriter.WriteLine("Assembly " + "bin\\" + Model.Name + ".dll");
            dplWriter.WriteLine("DesignerFactory Designer.Factories." + Model.Name + "ModelFactory");
            dplWriter.WriteLine("AnalystFactory Analyst.Factories." + Model.Name + "ModelFactory");

            dplWriter.Close();

            Directory.CreateDirectory(Path.Combine(Project.RootFolder, "Properties"));
            TextWriter assemblyWriter = File.CreateText(Path.Combine(Project.RootFolder, "Properties\\AssemblyInfo.cs"));

            assemblyWriter.WriteLine("using System.Reflection;");
            assemblyWriter.WriteLine("using System.Runtime.CompilerServices;");
            assemblyWriter.WriteLine("using System.Runtime.InteropServices;");

            assemblyWriter.WriteLine("[assembly: AssemblyTitle(\"" + model.Name + "\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyDescription(\"\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyConfiguration(\"\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyCompany(\"Blue Cell Software LLC\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyProduct(\"" + model.Name + "\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyCopyright(\"Copyright © Blue Cell Software LLC 2011\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyTrademark(\"\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyCulture(\"\")]");
            assemblyWriter.WriteLine("[assembly: ComVisible(false)]");
            assemblyWriter.WriteLine("[assembly: Guid(\"" + Guid.NewGuid() + "\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyVersion(\"0.0.0.0\")]");
            assemblyWriter.WriteLine("[assembly: AssemblyFileVersion(\"0.0.0.0\")]");
            assemblyWriter.WriteLine();
            assemblyWriter.Close();

            string fileList = "";
            try
            {
                DP_IGenerator designerGenerator = (DP_IGenerator) LanguageAssembly.CreateInstance(designerGeneratorName);
                fileList = designerGenerator.Generate(Model, Path.GetFullPath(Project.RootFolder));
            }
            catch (Exception exception)
            {
                DialogResult result = MessageBox.Show(
                    "Unable to generate designer code for project \"" + Project.Name + ".\"\n\n" +
                    "Exception: " +
                    exception.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
                return;
            }

            try
            {
                DP_IGenerator analystGenerator = (DP_IGenerator) LanguageAssembly.CreateInstance(analystGeneratorName);
                fileList += analystGenerator.Generate(Model, Path.GetFullPath(Project.RootFolder));
            }
            catch (Exception exception)
            {
                DialogResult result = MessageBox.Show(
                    "Unable to generate analyst code for project \"" + Project.Name + ".\"\n\n" +
                    "Exception: " +
                    exception.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
                return;
            }


            Directory.CreateDirectory(Path.Combine(Project.RootFolder, "bin\\"));

            Project.Assembly = Path.Combine("bin\\", Project.Name + ".dll");

            Report("Compiling model " + Project.Name + "...");

            Process compileProcess = new Process();
            compileProcess = new Process();
            compileProcess.StartInfo.UseShellExecute = false;
            compileProcess.StartInfo.FileName =
                Environment.ExpandEnvironmentVariables("%windir%\\Microsoft.NET\\Framework\\v4.0.30319\\Csc.exe");
            compileProcess.StartInfo.CreateNoWindow = true;
            compileProcess.StartInfo.WorkingDirectory = Project.RootFolder;

            string args = "/noconfig /warn:4 /define:TRACE /filealign:512 /optimize+ ";
            string dpRefs =
                "/reference:\"" +
                Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainPro Designer.exe") + "\" " +
                "/reference:\"" +
                Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainPro Analyst.exe") + "\" " +
                "/reference:\"" +
                Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "Assemblies\\DomainProCore.dll") +
                "\" ";
            string frameworkRefs =
                Environment.ExpandEnvironmentVariables(
                    "/reference:System.Core.dll /reference:System.Data.DataSetExtensions.dll /reference:System.Data.dll /reference:System.dll /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Xml.dll /reference:System.Xml.Linq.dll ");
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
        }

        private void LanguageKeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Delete || e.KeyCode == Keys.Back)
            {
                if (languageComboBox.Text != "Load New...")
                {
                    int tempIndex = languageComboBox.SelectedIndex;
                    RemoveLanguage(languageComboBox.Text);
                    languageComboBox.Items.Remove(languageComboBox.Text);
                    if (tempIndex < languageComboBox.Items.Count)
                    {
                        languageComboBox.SelectedIndex = tempIndex;
                    }
                    else
                    {
                        languageComboBox.SelectedIndex = languageComboBox.Items.Count - 1;
                    }
                }
            }
        }

        /*
        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);

            Size appSize = new Size(this.Size.Width - 24, this.Size.Height - 114);

            int x1 = Math.Max(188, (int)Math.Floor(0.15 * appSize.Width));
            int x2 = Math.Max(400, (int)Math.Floor(0.65 * appSize.Width));
            int x3 = Math.Max(200, appSize.Width - x1 - x2);

            int y1 = (int)Math.Max(200, 0.67 * appSize.Height);
            int y2 = Math.Max(150, appSize.Height - y1);

            treeWin.Location = new Point(0, 0);
            treeWin.Size = new Size(x1, y1 + y2);

            diagramWin.Location = new Point(x1, 0);
            diagramWin.Size = new Size(x2, y1);

            textWin.Location = new Point(x1, y1);
            textWin.Size = new Size(x2, y2);

            propertiesWin.Location = new Point(x1 + x2, 0);
            propertiesWin.Size = new Size(x3, y1);

            statusWin.Location = new Point(x1 + x2, y1);
            statusWin.Size = new Size(x3, y2);
        }
         * */

        private static DomainProDesigner instance;

        public static DomainProDesigner Instance
        {
            get { return instance; }
        }

        public void Report(string s)
        {
            this.Invoke((MethodInvoker) delegate { outputTextBox.Text += s + "\n"; });
        }

        public void DisplayTextPage(TabPage page)
        {
            textTabControl.TabPages.Add(page);
        }

        public void HideTextPage(TabPage page)
        {
            textTabControl.TabPages.Remove(page);
        }

        private void TreeKeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Delete || e.KeyCode == Keys.Back)
            {
                if (modelTreeView.SelectedNode.Tag is DP_ConcreteType)
                {
                    ((DP_ConcreteType) modelTreeView.SelectedNode.Tag).Destroy();
                }
            }
        }

        private void TreeNodeMouseClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            if (e.Node.Tag is DP_AbstractModelType)
            {
                DomainProDesigner.Instance.Selected.Clear();
                ((DP_ModelType) e.Node.Tag).Selected = true;
            }
            else if (e.Node.Tag is DP_ConcreteType)
            {
                DomainProDesigner.Instance.Model.Selected = false;
                DP_ConcreteType type = e.Node.Tag as DP_ConcreteType;
                if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
                {
                    if (DomainProDesigner.Instance.Selected.Contains(type))
                    {
                        DomainProDesigner.Instance.Selected.Remove(type);
                    }
                    else
                    {
                        DomainProDesigner.Instance.Selected.Add(type);
                    }
                }
                else
                {
                    DomainProDesigner.Instance.Selected.Clear();
                    DomainProDesigner.Instance.Selected.Add(type);
                }
            }
        }

        private void TreeAfterSelect(object sender, TreeViewEventArgs e)
        {
            if (e.Node.Tag is DP_AbstractModelType)
            {
                DomainProDesigner.Instance.Model.Selected = true;
            }
            else if (e.Node.Tag is DP_ConcreteType)
            {
                DomainProDesigner.Instance.Model.Selected = false;
            }
        }

        private void TreeNodeMouseDoubleClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            e.Node.Expand();
            if (e.Node.Tag is DP_ModelType)
            {
                DomainProDesigner.Instance.Selected.Clear();
                DP_ModelType model = (DP_ModelType) e.Node.Tag;
                model.Diagram.MakeMainDiagram();
                ((DP_Text) model.Text).Visible = true;
            }
            else if (e.Node.Tag is DP_ConcreteType)
            {
                ((DP_ConcreteType) e.Node.Tag).TypeMouseDoubleClick(sender, e);
            }
        }

        private void TreeNodeAfterLabelEdit(object sender, NodeLabelEditEventArgs e)
        {
            // e.Label == null if no change was made to the node label
            if (e.Label != null)
            {
                // If the user provided a name that was not empty
                if (e.Label != "")
                {
                    ((DP_AbstractType) e.Node.Tag).Name = e.Label;
                }
                else
                {
                    e.CancelEdit = true;
                }
            }
        }
    }
}
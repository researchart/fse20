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
using System.Linq;
using System.Text;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using System.Xml;
using DomainPro.Core.Controls;
using DomainPro.Core.Application;
using DomainPro.Core.Interfaces;

namespace DomainPro.Core
{
    
    public  class DP_Application : Form
    {
        private DP_Language language;

        public DP_Language Language
        {
            get { return language; }
            set { language = value; }
        }

        private Assembly languageAssembly;

        public Assembly LanguageAssembly
        {
            get { return languageAssembly; }
            set { languageAssembly = value; }
        }

        private DP_Project project;

        public DP_Project Project
        {
            get { return project; }
            set { project = value; }
        }

        private DP_IModelFactory modelFactory;

        public DP_IModelFactory ModelFactory
        {
            get { return modelFactory; }
            set { modelFactory = value; }
        }

        public enum DP_ModelState { OpenSaved, OpenChanged, Closed };

        private DP_ModelState modelState = DP_ModelState.Closed;

        public DP_ModelState ModelState
        {
            get { return modelState; }
            set { modelState = value; }
        }

        protected List<DP_Language> languages = new List<DP_Language>();

        protected virtual void OpenWindows()  {}
        protected virtual void CloseWindows()  {}
                  
        protected virtual void CreateProjectData()  {}
        protected virtual void ReadProjectData(DP_Project project)  {}
        protected virtual void WriteProjectData(DP_Project project)  {}
        protected virtual void DestroyProjectData()  {}
                  
        protected virtual void LoadLanguage(DP_Language language)  {}
                  
        protected virtual void DisplayProject()  {}
        protected virtual void HideProject()  {}
        protected virtual void DisplayLanguage()  {}
        protected virtual void HideLanguage()  {}

        public DP_Application()
        {
            FormClosing += ExitClick;
            ReadPreviouslyLoadedLanguageFiles();
        }
        public DP_Application(string currentDirectory)
        {
            if (currentDirectory != null)
                Environment.SetEnvironmentVariable("DP_ROOT", currentDirectory);
            FormClosing += ExitClick;
            ReadPreviouslyLoadedLanguageFiles();
        }

        protected void ProcessCommandLine()
        {
            if (Environment.GetCommandLineArgs().GetLength(0) > 1)
            {
                string filename = Environment.GetCommandLineArgs()[1];
                if (filename.EndsWith(".dpp", StringComparison.OrdinalIgnoreCase))
                {
                    try
                    {
                        Project = ReadProjectFile(filename);
                        Environment.CurrentDirectory = Path.GetDirectoryName(Project.File);
                        ChangeLanguage(Project.Language);
                        if (Language.Name == Project.Language)
                        {
                            ReadProjectData(Project);
                            modelState = DP_ModelState.OpenSaved;
                            OpenWindows();
                            DisplayProject();
                        }
                    }
                    catch (Exception e)
                    {
                        DialogResult result = MessageBox.Show(
                            "DomainPro was unable to load the model data for project \"" + Project.Name + ".\"\n\n" +
                            "Exception:\n" +
                            e.Message,
                            "DomainPro",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Exclamation);
                    }
                }
                else if (filename.EndsWith(".dpl", StringComparison.OrdinalIgnoreCase))
                {
                    try
                    {
                        DP_Language lang = ReadLanguageFile(filename);
                        languages.Add(lang);
                        ChangeLanguage(lang.Name);
                    }
                    catch (Exception e)
                    {
                        DialogResult result = MessageBox.Show(
                            "Unable to read the language file \"" + filename + ".\" Check that the file path is correct and the file is not corrupted.\n\n" +
                            "Exception: " +
                            e.Message,
                            "DomainPro",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Exclamation);
                    }
                }
            }
        }

        protected void NewClick(object sender, EventArgs e)
        {
            if (ModelState == DP_ModelState.OpenSaved)
            {
                DestroyProjectData();
                CloseWindows();
                ModelState = DP_ModelState.Closed;
            }
            else if (ModelState == DP_ModelState.OpenChanged)
            {
                if (CheckSaveDialog())
                {
                    DestroyProjectData();
                    CloseWindows();
                    ModelState = DP_ModelState.Closed;
                }
                else
                {
                    return;
                }
            }

            DP_Project newProj = new DP_Project();

            try
            {
                Project = newProj;
                OpenWindows();
                CreateProjectData();
                DisplayProject();
                ModelState = DP_ModelState.OpenSaved;
            }
            catch (Exception exception)
            {
                DialogResult result = MessageBox.Show(
                    "DomainPro was unable to create new project \"" + Project.Name + ".\"\n\n" +
                    "Exception:\n" +
                    exception.Message,
                    "DomainPro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Exclamation);
                return;
            }
        }

        protected void OpenClick(object sender, EventArgs e)
        {
            if (modelState == DP_ModelState.OpenSaved)
            {
                DestroyProjectData();
                CloseWindows();
                modelState = DP_ModelState.Closed;
            }
            else if (modelState == DP_ModelState.OpenChanged)
            {
                if (CheckSaveDialog())
                {
                    DestroyProjectData();
                    CloseWindows();
                    modelState = DP_ModelState.Closed;
                }
                else
                {
                    return;
                }
            }

            OpenWindows();
            if (LoadProjectDialog())
            {
                modelState = DP_ModelState.OpenSaved;

                DisplayProject();
            }
            else
            {
                CloseWindows();
                modelState = DP_ModelState.Closed;

                HideProject();
            }

        }

        protected void SaveClick(object sender, EventArgs e)
        {
            SaveProject(Project.File);
        }

        protected void SaveAsClick(object sender, EventArgs e)
        {
            SaveProject(null);
        }

        protected void CloseClick(object sender, EventArgs e)
        {
            if (ModelState == DP_ModelState.OpenSaved || CheckSaveDialog())
            {
                DestroyProjectData();
                CloseWindows();
                ModelState = DP_ModelState.Closed;
                HideProject();
            }
        }

        protected void ChangeProjectSettingsClick(object sender, EventArgs e)
        {
            if (ProjectSettingsDialog(Project))
            {
                ModelState = DP_ModelState.OpenChanged;
            }
        }

        protected void ChangeLanguageClick(object sender, EventArgs e)
        {
            ChangeLanguage(((Control)sender).Text);
        }

        protected void ExitClick(object sender, EventArgs e)
        {
            if (ModelState == DP_ModelState.OpenSaved)
            {
                DestroyProjectData();
                CloseWindows();
                ModelState = DP_ModelState.Closed;
                ExitApp();
            }
            else if (ModelState == DP_ModelState.OpenChanged)
            {
                if (CheckSaveDialog())
                {
                    DestroyProjectData();
                    CloseWindows();
                    ModelState = DP_ModelState.Closed;
                    ExitApp();
                }
                else
                {
                    if (e.GetType() == typeof(FormClosingEventArgs))
                    {
                        ((FormClosingEventArgs)e).Cancel = true;
                    }
                }
            }
            else
            {
                ExitApp();
            }
        }

        protected bool ProjectSettingsDialog(DP_Project project)
        {
            DP_ProjectSettingsDialog projSettingsDialog = new DP_ProjectSettingsDialog();
            projSettingsDialog.ProjectName = project.Name;
            projSettingsDialog.LanguageName = Language.Name;
            projSettingsDialog.Folder = project.RootFolder;
            if (projSettingsDialog.ShowDialog() == DialogResult.OK)
            {
                project.Name = projSettingsDialog.ProjectName;
                if (project.File == null)
                {
                    project.RootFolder = RelativePath(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), Path.GetFullPath(projSettingsDialog.Folder));
                    Environment.CurrentDirectory = Environment.ExpandEnvironmentVariables("%DP_ROOT%");
                }
                else
                {
                    project.RootFolder = RelativePath(Path.GetDirectoryName(project.File), Path.GetFullPath(projSettingsDialog.Folder));
                    Environment.CurrentDirectory = Path.GetDirectoryName(project.File);
                }
                

                project.Language = projSettingsDialog.LanguageName;
                project.ModelFile = project.Name + ".xml";
                projSettingsDialog.Dispose();
                return true;
            }
            else
            {
                projSettingsDialog.Dispose();
                return false;
            }
        }

        public bool LoadProjectForCloud(string modelPath,string languagePath)
         {

            try
            {
                Project = ReadProjectFile(modelPath);
                Environment.CurrentDirectory = Path.GetDirectoryName(Project.File);
                DP_Language lang = ReadLanguageFile(languagePath);
                languages.Add(lang);
                Language = lang;
                LoadLanguage(lang);
                DisplayLanguage();
                //ChangeLanguage(Project.Language);
                if (Language.Name == Project.Language)
                {
                    ReadProjectData(Project);
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception e)
            {
                return false;
            }
        }
        private bool LoadProjectDialog()
        {
            OpenFileDialog openProjectDialog = new OpenFileDialog();
            //openProjectDialog.InitialDirectory = Environment.ExpandEnvironmentVariables("%DP_ROOT%");
            openProjectDialog.Filter = "DomainPro Project (*.dpp)|*.dpp";
            openProjectDialog.Title = "Load DomainPro Project";
            openProjectDialog.RestoreDirectory = true;

            if (openProjectDialog.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    Project = ReadProjectFile(openProjectDialog.FileName);
                    openProjectDialog.Dispose();
                    Environment.CurrentDirectory = Path.GetDirectoryName(Project.File);
                    ChangeLanguage(Project.Language);
                    if (Language.Name == Project.Language)
                    {
                        ReadProjectData(Project);
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                catch (Exception e)
                {
                    DialogResult result = MessageBox.Show(
                        "DomainPro was unable to load the model data for project \"" + Project.Name + ".\"\n\n" +
                        "Exception:\n" +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                    return false;
                }
            }
            else
            {
                openProjectDialog.Dispose();
                return false;
            }
        }

        private bool CheckSaveDialog()
        {
            DialogResult checkSave = MessageBox.Show("Do you want to save the changes to " + Project.Name + "?",
                "DomainPro",
                MessageBoxButtons.YesNoCancel,
                MessageBoxIcon.Exclamation);

            if (checkSave == DialogResult.Yes)
            {
                return SaveProject(Project.File);
            }
            else if (checkSave == DialogResult.No)
            {
                return true;
            }
            else // checkSave == DialogResult.Cancel
            {
                return false;
            }
        }

        private bool SaveProject(string projectFile)
        {
            if (Project.RootFolder == null || Project.Name == null)
            {
                if (!ProjectSettingsDialog(Project))
                {
                    return false;
                }
            }
            if (projectFile == null)
            {
                SaveFileDialog saveProjectDialog = new SaveFileDialog();
                saveProjectDialog.Filter = "DomainPro Project (*.dpp)|*.dpp";
                saveProjectDialog.Title = "Save DomainPro Project";
                saveProjectDialog.RestoreDirectory = true;

                // If the file name is not an empty string open it for saving.
                if (saveProjectDialog.ShowDialog() == DialogResult.OK)
                {
                    projectFile = saveProjectDialog.FileName;
                }
                else
                {
                    return false;
                }
                saveProjectDialog.Dispose();
            }

            if (projectFile != null)
            {
                try
                {
                    Project.File = projectFile;
                    Project.RootFolder = RelativePath(Path.GetDirectoryName(Project.File), Path.GetFullPath(Project.RootFolder));
                    Environment.CurrentDirectory = Path.GetDirectoryName(project.File);
                    WriteProjectFile(Project);
                    WriteProjectData(Project);
                    ModelState = DP_ModelState.OpenSaved;
                }
                catch (Exception e)
                {
                    DialogResult result = MessageBox.Show(
                        "DomainPro was unable to save the model data for project \"" + Project.Name + ".\"\n\n" +
                        "Exception:\n" +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                    return false;
                }
            }

            return true;
        }

        private void ChangeLanguage(string languageName)
        {
            if (Language != null && languageName == Language.Name)
            {
                return;
            }

            DP_Language lang = languages.Find(
                    delegate(DP_Language l)
                    {
                        return l.Name == languageName;
                    });

            if (lang == null)
            {
                lang = LoadNewLanguageFile(languageName);
                if (lang != null)
                {
                    languages.Add(lang);
                }
            }

            if (lang != null)
            {
                try
                {
                    Language = lang;
                    LoadLanguage(lang);
                    DisplayLanguage();
                }
                catch (Exception e)
                {
                    DialogResult result = MessageBox.Show(
                        "DomainPro Designer was unable to load the language \"" + language.Name + ".\" Try regenerating the language assembly.\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                }
            }
        }

        private DP_Language ReadLanguageFile(string langFile)
        {
            DP_Language newLang = new DP_Language();
            langFile = Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), langFile);
            newLang.File = Path.GetFullPath(langFile);
            TextReader reader = File.OpenText(langFile);

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

        private DP_Language LoadNewLanguageFile(string languageName)
        {
            OpenFileDialog loadLanguageDialog = new OpenFileDialog();
            //loadLanguageDialog.InitialDirectory = Environment.ExpandEnvironmentVariables("%DP_ROOT%");
            loadLanguageDialog.Filter = "DomainPro Language (*.dpl)|*.dpl";
            loadLanguageDialog.Title = "Load DomainPro Language";
            loadLanguageDialog.RestoreDirectory = true;
            if (languageName != "Load New...")
            {
                loadLanguageDialog.FileName = languageName + ".dpl";
                // Needed because of Microsoft Windows bug ID: 525070
                loadLanguageDialog.AutoUpgradeEnabled = false;
            }

            if (loadLanguageDialog.ShowDialog() == DialogResult.OK)
            {
                // Using paths relative to %DP_ROOT%
                try
                {
                    DP_Language lang = ReadLanguageFile(loadLanguageDialog.FileName);
                    //TextWriter writer = File.CreateText(Environment.ExpandEnvironmentVariables("%DP_ROOT%\\DomainProConfig.cfg"));

                    /*
                    foreach (DP_Language language in languages)
                    {
                        string relativePath = RelativePath(
                            Environment.ExpandEnvironmentVariables("%DP_ROOT%"),
                            Path.GetDirectoryName(language.File));
                        writer.WriteLine("language\t" + Path.Combine(relativePath, Path.GetFileName(language.File)));
                    }
                     * */

                    string langRelativePath = RelativePath(
                            Environment.ExpandEnvironmentVariables("%DP_ROOT%"),
                            Path.GetDirectoryName(lang.File));
                    string langPath = Path.Combine(langRelativePath, Path.GetFileName(lang.File));
                    //writer.WriteLine("language\t" + Path.Combine(langRelativePath, Path.GetFileName(lang.File)));
                    if (!Properties.Settings.Default.Languages.Contains(langPath))
                    {
                        Properties.Settings.Default.Languages.Add(langPath);
                        Properties.Settings.Default.Save();
                    }

                    //writer.Close();
                    loadLanguageDialog.Dispose();
                    return lang;
                }
                catch (Exception e)
                {
                    DialogResult result = MessageBox.Show(
                        "Unable to read the file \"" + loadLanguageDialog.FileName + ".\" Check that the file path is correct and the file is not corrupted.\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);

                    return null;
                }
            }
            else
            {
                loadLanguageDialog.Dispose();
                return null;
            }
        }

        private void WriteProjectFile(DP_Project project)
        {
            Directory.CreateDirectory(project.RootFolder);

            TextWriter dppWriter = File.CreateText(project.File);
            dppWriter.WriteLine("Name " + project.Name);
            dppWriter.WriteLine("Language " + project.Language);
            dppWriter.WriteLine("Root " + project.RootFolder);
            dppWriter.WriteLine("Model " + project.ModelFile);
            dppWriter.WriteLine("Assembly " + project.Assembly);
            dppWriter.Close();
        }

        private DP_Project ReadProjectFile(string projFile)
        {
            DP_Project newProj = new DP_Project();
            projFile = Environment.ExpandEnvironmentVariables(projFile);
            TextReader reader = File.OpenText(projFile);

            newProj.File = projFile;

            string line = reader.ReadLine();
            while (line != null)
            {
                string[] words = line.Split(new char[]{' '}, 2);
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

        protected void ReadPreviouslyLoadedLanguageFiles()
        {
            foreach (string langPath in Properties.Settings.Default.Languages)
            {
                try
                {
                    DP_Language lang = ReadLanguageFile(langPath);
                    languages.Add(lang);
                }
                catch (Exception e)
                {
                    DialogResult result = MessageBox.Show(
                        "Unable to read the language file \"" + langPath + ".\" Check that the file path is correct and the file is not corrupted.\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                    //Properties.Settings.Default.Languages.Remove(langPath);
                    //Properties.Settings.Default.Save();
                }
            }

            /*
            if (!File.Exists(Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainProConfig.cfg")))
            {
                TextWriter writer = File.CreateText(Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainProConfig.cfg"));
                writer.WriteLine("language\tLanguageBuilder.dpl");
                writer.Close();
            }

            TextReader reader = File.OpenText(Path.Combine(Environment.ExpandEnvironmentVariables("%DP_ROOT%"), "DomainProConfig.cfg"));

            string line = reader.ReadLine();
            while (line != null)
            {
                string[] words = line.Split('\t');
                if (words[0] == "language")
                {
                    try
                    {
                        DP_Language lang = ReadLanguageFile(words[1]);
                        languages.Add(lang);
                    }
                    catch (Exception e)
                    {
                        DialogResult result = MessageBox.Show(
                            "Unable to read the language file \"" + words[1] + ".\" Check that the file path is correct and the file is not corrupted.\n\n" +
                            "Exception: " +
                            e.Message,
                            "DomainPro",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Exclamation);
                    }
                }
                line = reader.ReadLine();
            }

            reader.Close();
             * */

        }

        protected void RemoveLanguage(string languageName)
        {
            DP_Language lang = languages.Find(
                    delegate(DP_Language l)
                    {
                        return l.Name == languageName;
                    });

            if (lang != null)
            {
                languages.Remove(lang);
                string langRelativePath = RelativePath(
                            Environment.ExpandEnvironmentVariables("%DP_ROOT%"),
                            Path.GetDirectoryName(lang.File));
                string langPath = Path.Combine(langRelativePath, Path.GetFileName(lang.File));
                Properties.Settings.Default.Languages.Remove(langPath);
                Properties.Settings.Default.Save();
            }
        }

        private void ExitApp()
        {
            System.Windows.Forms.Application.Exit();
        }

        public string RelativePath(string from, string to)
        {
            /*
            if (File.Exists(from))
            {
                FileAttributes attr = File.GetAttributes(from);

                if ((attr & FileAttributes.Directory) != FileAttributes.Directory)
                {
                    from = from.Substring(0, from.LastIndexOf(Path.DirectorySeparatorChar));
                }
            }

            if (File.Exists(to))
            {
                FileAttributes attr = File.GetAttributes(to);

                if ((attr & FileAttributes.Directory) != FileAttributes.Directory)
                {
                    to = to.Substring(0, to.LastIndexOf(Path.DirectorySeparatorChar));
                }
            }
             * */

            string[] path1 = from.Trim(Path.DirectorySeparatorChar).Split(Path.DirectorySeparatorChar);
            string[] path2 = to.Trim(Path.DirectorySeparatorChar).Split(Path.DirectorySeparatorChar);
            

            int counter = 0;
            for (int i = 0; i < Math.Min(path1.Length, path2.Length); i++)
            {
                if (path1[i].ToLower() != path2[i].ToLower())
                {
                    break;
                }
                counter++;
            }

            if (counter == 0)
            {
                return to;
            }

            string newPath = String.Empty;
            for (int i = counter; i < path1.Length; i++)
            {
                if (i > counter)
                {
                    newPath += Path.DirectorySeparatorChar;
                }
                newPath += "..";
            }
            if (newPath.Length == 0)
            {
                newPath = ".";
            }
            for (int i = counter; i < path2.Length; i++)
            {
                newPath += Path.DirectorySeparatorChar;
                newPath += path2[i];
            }
            return newPath;
        }

    }
}

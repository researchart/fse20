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

namespace DomainPro.Core.Application
{
    public class DP_Project
    {
        private string name;

        public string Name
        {
            get { return name; }
            set { name = value; }
        }

        private string file;

        public string File
        {
            get { return file; }
            set { file = value; }
        }

        private string language;

        public string Language
        {
            get { return language; }
            set { language = value; }
        }

        private string assembly;

        public string Assembly
        {
            get { return assembly; }
            set { assembly = value; }
        }

        private string rootFolder;

        public string RootFolder
        {
            get { return rootFolder; }
            set { rootFolder = value; }
        }

        private string modelFile;

        public string ModelFile
        {
            get { return modelFile; }
            set { modelFile = value; }
        }
    }
}

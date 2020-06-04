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
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Windows.Forms;

namespace DomainPro.Core.Types
{
    public abstract class DP_AbstractModelType : DP_AbstractType
    {
                /*
        private string file;

        public string File
        {
            get { return file; }
            set { file = value; }
        }


        public string Path
        {
            get { return File.Substring(0, File.LastIndexOf('\\')); }
        }
         * */

        public virtual void Initialize()
        {
            Structure.Initialize(null);
        }
    }
}

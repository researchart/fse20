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
using System.ComponentModel;
using System.Drawing.Design;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace DomainPro.Core.Types
{
    [XmlType("Worker")]
    public class DP_Worker
    {
        private string name = "NewWorker";

        [Category("Properties"),
        Description("Sets the name of the worker.")]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }

        private List<string> queues = new List<string>();

        [Category("Properties"),
        Description("Sets the queues processed by the worker."),
        Editor("System.Windows.Forms.Design.StringCollectionEditor, System.Design, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a", typeof(System.Drawing.Design.UITypeEditor))]
        public List<string> Queues
        {
            get { return queues; }
            set { queues = value; }
        }

        private string capacity;

        [Category("Properties"),
        DefaultValue("1"),
        Description("Sets the capacity of the worker.")]
        public string Capacity
        {
            get { return capacity; }
            set { capacity = value; }
        }

        private string velocity = "1.0";

        [Category("Properties"),
        DefaultValue("1.0"),
        Description("Sets the velocity of the worker.")]
        public string Velocity
        {
            get { return velocity; }
            set { velocity = value; }
        }
    }
}

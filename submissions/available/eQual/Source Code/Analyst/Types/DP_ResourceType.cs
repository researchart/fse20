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
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.ComponentModel;
using DomainPro.Core.Types;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Types
{
    public class DP_ResourceType : DP_ConcreteType
    {
        private List<DP_Worker> workers = new List<DP_Worker>();

        [DisplayName("Workers"),
        Category("Simulation"),
        Description("A list of workers provided by the resource.")]
        public List<DP_Worker> Workers
        {
            get { return workers; }
            set { workers = value; }
        }

        private List<DP_Queue> queues = new List<DP_Queue>();

        [DisplayName("Queues"),
        Category("Simulation"),
        Description("A list of job categories handled by the resource.")]
        public List<DP_Queue> Queues
        {
            get { return queues; }
            set { queues = value; }
        }

        public override void Initialize(DP_AbstractStructure parentStructure)
        {
            base.Initialize(parentStructure);
        }
    }
}

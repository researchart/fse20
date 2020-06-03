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
using System.Xml.Serialization;
using DomainPro.Core.Types;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Controls;

namespace DomainPro.Analyst.Types
{
    public class DP_FlowType : DP_ConcreteType
    {
        public override void Initialize(DP_AbstractStructure parentStructure)
        {
            base.Initialize(parentStructure);

            if (Role1Id != Guid.Empty)
            {
                Role1Attached = (DP_ConcreteType)Parent.Parent.FindTypeById(Role1Id);
                if (Role1Attached is DP_MethodType)
                {
                    ((DP_MethodType)Role1Attached).Flows.Add(this);
                }             
            }
            if (Role2Id != Guid.Empty)
            {
                Role2Attached = (DP_ConcreteType)Parent.Parent.FindTypeById(Role2Id);
                if (Role2Attached is DP_MethodType)
                {
                    ((DP_MethodType)Role2Attached).Flows.Add(this);
                }  
            }
        }

        /*
        private DP_IFlowDef flowDef;

        [XmlIgnore]
        public DP_IFlowDef FlowDef
        {
            get
            {
                if (flowDef == null)
                {
                    string fullName = Name;

                    //DP_ConcreteType nextParent = Parent.Parent;

                    //while (nextParent != null)
                    //{
                    //    fullName = nextParent.Name + "." + fullName;
                    //    nextParent = nextParent.Parent.Parent;
                    //}

                    fullName = app.Model.Name + "." + fullName;

                    flowDef = (DP_IFlowDef)app.ModelAssembly.CreateInstance(fullName);

                    if (flowDef != null)
                    {
                        flowDef.Flow = this;
                        flowDef.Initialize();
                    }

                }
                return flowDef;
            }
        }
         * */

        /*
        public bool Go()
        {

            if (FlowDef != null)
            {
                return FlowDef.Trigger();
            }

            return false;
        }
         * */
    }
}

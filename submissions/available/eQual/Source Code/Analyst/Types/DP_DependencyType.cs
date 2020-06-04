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
using DomainPro.Core.Types;

namespace DomainPro.Analyst.Types
{
    public class DP_DependencyType :  DP_ConcreteType
    {
        public override void Initialize(DP_AbstractStructure parentStructure)
        {
            base.Initialize(parentStructure);

            if (Role1Id != Guid.Empty)
            {
                if (Parent.Parent == null)
                {
                    foreach (DP_AbstractSemanticType type in Parent.Types)
                    {
                        DP_ConcreteType temp = type.FindTypeById(Role1Id) as DP_ConcreteType;
                        if (temp != null)
                        {
                            Role1Attached = temp;
                            break;
                        }
                    }
                }
                else
                {
                    Role1Attached = Parent.Parent.FindTypeById(Role1Id) as DP_ConcreteType;
                }
                Role1Attached.Dependencies.Add(this);
            }
            if (Role2Id != Guid.Empty)
            {
                if (Parent.Parent == null)
                {
                    foreach (DP_AbstractSemanticType type in Parent.Types)
                    {
                        DP_ConcreteType temp = type.FindTypeById(Role2Id) as DP_ConcreteType;
                        if (temp != null)
                        {
                            Role2Attached = temp;
                            break;
                        }
                    }
                }
                else
                {
                    Role2Attached = Parent.Parent.FindTypeById(Role2Id) as DP_ConcreteType;
                }
                Role2Attached.Dependencies.Add(this);
            }
        }
    }
}

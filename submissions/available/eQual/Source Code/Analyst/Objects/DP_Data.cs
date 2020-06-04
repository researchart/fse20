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
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Types;

namespace DomainPro.Analyst.Objects
{
    public class DP_Data : DP_Object
    {
        public new DP_DataType Type
        {
            get { return type as DP_DataType; }
            set { type = value; }
        }

        public event DP_DataChangedEventHandler DataChanged;

        protected object val;

        public object Value
        {
            get
            {
                return val;
            }
            set
            {
                OnDataChanged(new DP_DataChangedEventArgs(Id, Context.Id, Model.Simulation.Simulator.Scheduler.Time, value));
                val = value;
            }
        }

        protected void OnDataChanged(DP_DataChangedEventArgs e)
        {
            if (DataChanged != null)
            {
                DataChanged(this, e);
            }
        }

    }
}

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

namespace DomainPro.Analyst.Engine
{
    public class DP_PropertyOverride
    {
        private string type;

        public string Type
        {
            get { return type; }
            set { type = value; }
        }

        private string property;

        public string Property
        {
            get { return property; }
            set { property = value; }
        }

        private object val;

        public object Value
        {
            get { return val; }
            set { val = value; }
        }
    }
}

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
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace DomainPro.Core.Types
{
    [XmlType("Queue")]
    public class DP_Queue
    {
        private string name = "NewQueue";

        [DisplayName("Name"),
        Category("Properties"),
        Description("Sets the name of the queue.")]
        public string Name
        {
            get { return name; }
            set { name = value; }
        }

        public enum QueueOrdering { FIFO, LIFO };

        private QueueOrdering ordering;

        [DisplayName("Ordering"),
        Category("Properties"),
        Description("Sets the order in which requests in the queue are processed.")]
        public QueueOrdering Ordering
        {
            get { return ordering; }
            set { ordering = value; }
        }
    }
}

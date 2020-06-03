using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace CloudController.Models
{
    public class PropertyOverride
    {
        [XmlIgnore]
        public PropertyOverride Parent { set; get; }
        public string PrimitiveType { set; get; }
        public string Type { set; get; }
        public string Property { set; get; }
        public object Value { set; get; }
        
    }
}
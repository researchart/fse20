using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Configuration;

namespace CloudController.Models
{
    class CloudControllerConfiguration : ConfigurationSection
    {
        private static CloudControllerConfiguration _instance = null;
        public static CloudControllerConfiguration Instance
        {
            get
            {
                if (_instance == null)
                    _instance = (CloudControllerConfiguration)WebConfigurationManager.GetSection("cloudController");
                return _instance;
            }
        }
        [ConfigurationProperty("numberOfSlaves", IsRequired=true)]
        public int NumberOfSlaves
        {
            get { return (int)base["numberOfSlaves"]; }
            set { base["numberOfSlaves"] = value; }
        }
        [ConfigurationProperty("", IsRequired = true, IsKey = false, IsDefaultCollection = true)]
        public SlaveGroupCollection SlaveNodes
        {
            get { return (SlaveGroupCollection)base[""]; }
            set { base[""] = value; }
        }


        public class SlaveGroupCollection : ConfigurationElementCollection
        {
            const string ELEMENT_NAME = "SlaveNode";
            public override ConfigurationElementCollectionType CollectionType
            {
                get { return ConfigurationElementCollectionType.BasicMap; }
            }
            protected override ConfigurationElement CreateNewElement()
            {
                return new SlaveNodeElement();
            }
            protected override object GetElementKey(ConfigurationElement element)
            {
                return ((SlaveNodeElement)element).NodeID;
            }
            protected override string ElementName
            {
                get { return ELEMENT_NAME; }
            }

        }
        public class SlaveNodeElement : ConfigurationElement
        {
            const string NODEID = "NodeID";
            const string URL = "Url";
            [ConfigurationProperty(NODEID,IsRequired=true)]
            public string NodeID
            {
                get { return (string)base[NODEID]; }
            }

            [ConfigurationProperty(URL, IsRequired = true)]
            public string Url
            {
                get { return (string)base[URL]; }
            }

        }
    }
}

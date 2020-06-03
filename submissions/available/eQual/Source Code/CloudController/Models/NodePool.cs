using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CloudController.Models
{
    public class NodePool
    {
        public static List<Node> Pool {
            get
            {
                List<Node> res = new List<Node>();
                var t = CloudControllerConfiguration.Instance.SlaveNodes;
                foreach(CloudController.Models.CloudControllerConfiguration.SlaveNodeElement slave in t)
                {
                    res.Add(new Node()
                    {
                        NodeID  = slave.NodeID,
                        URL = slave.Url
                    });
                
                }
                return res;
            }
        }
         
    }
}
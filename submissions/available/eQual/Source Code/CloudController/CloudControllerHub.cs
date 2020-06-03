using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Lifetime;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;

namespace CloudController
{
    [HubName("cloudController")]
    public class CloudControllerHub : Hub
    {
        public string GetUpdatesFromNodes()
        {
            Clients.All.updateProgress("salam");
            return null;
        }
        
        public override Task OnConnected()
        {
            var t = Context.Request;
            var tt = t.GetHttpContext();
            return base.OnConnected();
        }
        public void SubscribeToGuid(string guid)
        {
            Groups.Add(Context.ConnectionId, guid);
        }
    }
}
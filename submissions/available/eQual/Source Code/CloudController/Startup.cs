using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.Owin;
using Owin;

[assembly: OwinStartup("CloudConfiguration",typeof(CloudController.Startup))]
namespace CloudController
{
    public partial class Startup
    {   
        public async void Configuration(IAppBuilder app)
        {
            app.MapSignalR();
            ConfigureAuth(app);
            await RegisterAdminAndRoles();
        }
    }
}
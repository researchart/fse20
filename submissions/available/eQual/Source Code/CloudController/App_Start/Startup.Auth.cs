using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.Identity;
using Microsoft.Owin;
using Owin;
using Microsoft.Owin.Security.Cookies;
using System.Threading.Tasks;
using CloudController.Models;
using Microsoft.AspNet.Identity.EntityFramework;

namespace CloudController
{
	public partial class Startup
	{
        public void ConfigureAuth(IAppBuilder app)
        {
            app.UseCookieAuthentication(new CookieAuthenticationOptions()
            {
                AuthenticationType = DefaultAuthenticationTypes.ApplicationCookie,
                LoginPath = new PathString("/Account/Login")
            });

            // For more information on how to configure your application, visit http://go.microsoft.com/fwlink/?LinkID=316888
        }

	    public async static Task RegisterAdminAndRoles()
	    {
	        using (var context = new EqualDbContext())
	        {
	            using (var userStore = new UserStore<EqualUser>(context))
	            using (var userManager = new UserManager<EqualUser>(userStore))
	            {
	                var firstOrDefault = userStore.Users.FirstOrDefault(s => s.UserName == "admin");
	                if (firstOrDefault != null)
	                {
	                    var adminUser = new EqualUser()
	                    {
	                        UserName = "x",
	                        Email = "x",
	                        FirstName = "x",
	                        LastName = "x",
	                        Organization = "x"
	                    };
	                    await userManager.CreateAsync(adminUser, "x");
	                }
	            }
	            using (var roleStore = new RoleStore<IdentityRole>(context))
	            using (var roleManager = new RoleManager<IdentityRole>(roleStore))
	            {
	                if (roleManager.Roles.FirstOrDefault(s=>s.Name=="admin") == null)
	                {
	                    await roleManager.CreateAsync(new IdentityRole("admin"));
	                }
                    if (roleManager.Roles.FirstOrDefault(s => s.Name == "customer") == null)
                    {
                        await roleManager.CreateAsync(new IdentityRole("customer"));
                    }

                }
	        }
	    }

    }
}
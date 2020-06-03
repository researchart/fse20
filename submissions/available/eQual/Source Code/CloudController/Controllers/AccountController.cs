using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using CloudController.Models;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin.Security;

namespace CloudController.Controllers
{
    [Authorize]
    public class AccountController : Controller
    {

        private readonly UserManager<EqualUser> UserManager;

        public AccountController()
        {
            UserManager = new UserManager<EqualUser>(new UserStore<EqualUser>(new EqualDbContext()));
        } 
        // GET: Account
        public ActionResult Index()
        {
            using (var context = new EqualDbContext())
            using (var userStore = new UserStore<EqualUser>(context))
            using (var userManager = new UserManager<EqualUser>(userStore))
            {
                var users = userManager.Users;
                return View(users);
            } 
        }
        [AllowAnonymous]
        public ActionResult Login(string returnUrl)
        {
            ViewBag.ReturnUrl = returnUrl;
            return View();
        }
        [HttpPost]
        [AllowAnonymous]
        public async Task<ActionResult> Login( string email, string password,bool? rememberMe)
        {
            var user = await UserManager.FindAsync(email,password);
            if (user == null)
            {
                ModelState.AddModelError(string.Empty, "The user with the supplied credentials does not exist");
                ViewBag.email = email;
                ViewBag.rememberMe = rememberMe;
                return View();
            }
            var roles = UserManager.GetRoles(user.Id);
            var authManager = HttpContext.GetOwinContext().Authentication;
            var userIdentity = await UserManager.CreateIdentityAsync(user, DefaultAuthenticationTypes.ApplicationCookie);
            authManager.SignIn(
                new AuthenticationProperties() { IsPersistent = rememberMe??false }, userIdentity);
            return RedirectToAction("List","Main");
        }
        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Register(string email, string password, string confirmPassword, string firstName, string lastName)
        {
            var t = await UserManager.CreateAsync(new EqualUser()
            {
                UserName = email,
                Email = email,
                FirstName = firstName,
                LastName = lastName
            }, password);
            if (t.Succeeded)
                return RedirectToAction("List", "Main");
            else
            {

                return View();
            }
        }
    }
}
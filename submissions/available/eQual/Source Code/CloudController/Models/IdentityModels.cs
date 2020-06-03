using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;

namespace CloudController.Models
{

    public class EqualUser : IdentityUser
    {
        public string FirstName { set; get; }
        public string LastName { set; get; }
        public string Organization { set; get; }
        public async Task<ClaimsIdentity> GenerateUserIdentityAsync(UserManager<EqualUser> manager)
        {
            var userIdentity = await manager.CreateIdentityAsync(this, DefaultAuthenticationTypes.ApplicationCookie);
            return userIdentity;
        } 
    }
    public class EqualDbContext : IdentityDbContext<EqualUser>
    {
        public EqualDbContext() : base("DefaultConnection",throwIfV1Schema:false)
        {
            
        }

        public static EqualDbContext Create()
        {
            return new EqualDbContext();
        }

        protected override void OnModelCreating(System.Data.Entity.DbModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<IdentityUser>().ToTable("User").Property(p => p.Id).HasColumnName("ID");
            modelBuilder.Entity<EqualUser>().ToTable("User").Property(p => p.Id).HasColumnName("ID");
            modelBuilder.Entity<IdentityUserRole>().ToTable("UserRole");
            modelBuilder.Entity<IdentityUserLogin>().ToTable("UserLogin");
            modelBuilder.Entity<IdentityUserClaim>().ToTable("UserClaim");
            modelBuilder.Entity<IdentityRole>().ToTable("Role");


        }
    }


}
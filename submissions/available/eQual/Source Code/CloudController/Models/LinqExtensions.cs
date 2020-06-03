using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DomainPro.Core.Models;

namespace CloudController.Models
{
    public static class LinqExtensions
    {
       // public static  IQueryable<T> Active<T>(this IQueryable<T> source)
       //where T : object
       // {
       //     //return source.Where(a => ((a.publishEnd > DateTime.Now) || (a.publishEnd == null))
       //     //                  && ((a.publishStart <= DateTime.Now) || (a.publishStart == null))
       //     //                  && a.active == true);
       //     return null;
       // }
        public static Range SeriesRange<T>(this List<T> source) where T : Pair<double, double>
        {
            return new Range()
            {
                LowerBound = source.Min(s=>s.Value),
                UpperBound = source.Max(s=>s.Value)
            };
        }
        public static double Integrate<T>(this List<T> source) where T: Pair<double, double>
        {
            if (source.Count == 1)
                return source[0].Value;
            var l = source as List<Pair<double, double>>;
            double result = 0;
            for (int i = 1;i<l.Count;  i++)
            {
                result += l[i - 1].Value*(l[i].Key - l[i - 1].Key);
            }
            return result;
        }

        public static double ContinuousVariance<T>(this List<T> source) where T : Pair<double, double>
        {
            if (source.Count == 1)
                return 0;
            //calculate xf(x) integral as u
            double u = 0;
            for (int i = 1; i < source.Count; i++)
            {
                u += source[i - 1].Value * (Math.Pow( source[i].Key,2) - Math.Pow(source[i - 1].Key,2)) /2;
            }
            //calculate x2f(x) integral
            double x2fx = 0;
            for (int i = 1; i < source.Count; i++)
            {
                x2fx += source[i - 1].Value * (Math.Pow(source[i].Key, 3) - Math.Pow(source[i - 1].Key, 3)) / 3;
            }
            //return x2f(x) integral - u2
            return x2fx - Math.Pow(u, 2);
        } 
        public static double ContinuousAverage<T>(this List<T> source) where T : Pair<double, double>
        {
            if (source.Count == 1)
                return source[0].Value;
            var l = source as List<Pair<double, double>>;
            double integration = source.Integrate();
            double range = l.Max(s => s.Key)-l.Min(s=>s.Key);
            return integration/range;
        }

        public static double StandardDeviation<T>(this List<T> source) where T : Pair<double, double>
        {
            if (source.Count == 1)
                return 0;
            var doubles = source.Select(s => s.Value).ToList();
            double average = doubles.Average();
            double sumOfSquaresOfDifferences = doubles.Select(val => (val - average) * (val - average)).Sum();
            double sd = Math.Sqrt(sumOfSquaresOfDifferences / doubles.Count());
            return sd;
        } 
    }
}
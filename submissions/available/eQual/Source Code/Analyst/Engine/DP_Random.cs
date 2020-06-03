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

namespace DomainPro.Analyst.Engine
{
    public class DP_Random
    {
        private uint w;
        private uint z;

        public DP_Random()
        {
            // Any pair of unsigned integers can be used as the seeds.
            w = 521288629;
            z = 362436069;
        }

        public void Seed(uint u, uint v)
        {
            if (u != 0)
            {
                w = u;
            }
            if (v != 0)
            {
                z = v;
            }
        }

        public void Seed(uint u)
        {
            w = u;
        }

        public void SeedFromSystemTime()
        {
            DateTime dt = DateTime.Now;
            long x = dt.ToFileTime();
            Seed((uint)(x >> 16), (uint)(x % 4294967296));
        }

        // Returns an unsigned integer between 0 and 2^32 - 1
        public uint Uint()
        {
            z = 36969 * (z & 65535) + (z >> 16);
            w = 18000 * (w & 65535) + (w >> 16);
            return (z << 16) + w;
        }

        // Returns an unsigned integer: min <= value < max
        public uint Uint(uint min, uint max)
        {
            return (uint)Math.Floor(Uniform(min, max));
        }

        // Returns a double 0 < value < 1
        public double Uniform()
        {
            return (Uint() + 1.0) * 2.328306435454494e-10;
        }

        // Returns a double min < value < max
        public double Uniform(double min, double max)
        {
            if (min >= max)
            {
                throw new ArgumentOutOfRangeException("Unable to generate random sample from uniform distribution. Max must be greater than min. Received min " + min + " and max " + max + ".");
            }
            return Uniform() * (max - min) + min;
        }
        
        public double Normal()
        {
            double u1 = Uniform();
            double u2 = Uniform();
            double r = Math.Sqrt(-2.0 * Math.Log(u1));
            double theta = 2.0 * Math.PI * u2;
            return r * Math.Sin(theta);
        }
        
        public double Normal(double mean, double standardDeviation)
        {
            if (standardDeviation <= 0.0)
            {
                throw new ArgumentOutOfRangeException("Unable to generate random sample from normal distribution. Standard deviation must be positive. Received " + standardDeviation + ".");
            }
            return mean + standardDeviation * Normal();
        }
        
        public double Exponential()
        {
            return -Math.Log( Uniform() );
        }

        public double Exponential(double mean)
        {
            if (mean <= 0.0)
            {
                throw new ArgumentOutOfRangeException("Unable to generate random sample from exponential distribution. Mean must be positive. Received " + mean + ".");
            }
            return mean * Exponential();
        }

        public double Gamma(double shape, double scale)
        {     
            if (shape >= 1.0)
            {
                double d = shape - 1.0 / 3.0;
                double c = 1.0 / Math.Sqrt(9.0 * d);

                for (;;)
                {
                    double x, v;
                    do
                    {
                        x = Normal();
                        v = 1.0 + c * x;
                    } while (v <= 0.0);

                    v = v * v * v;
                    double u = Uniform();
                    double xsquared = x * x;
                    if (u < 1.0 - .0331 * xsquared * xsquared || Math.Log(u) < 0.5 * xsquared + d * (1.0 - v + Math.Log(v)))
                    {
                        return scale * d * v;
                    }
                }
            }
            else if (shape <= 0.0)
            {
                throw new ArgumentOutOfRangeException("Unable to generate random sample from gamma distribution. Shape must be positive. Received " + shape + ".");
            }
            else
            {
                double g = Gamma(shape + 1.0, 1.0);
                double w = Uniform();
                return scale * g * Math.Pow(w, 1.0 / shape);
            }
        }

        public double ChiSquared(double degreesOfFreedom)
        {
            return Gamma(0.5 * degreesOfFreedom, 2.0);
        }

        public double InverseGamma(double shape, double scale)
        {
            return 1.0 / Gamma(shape, 1.0 / scale);
        }

        public double Weibull(double shape, double scale)
        {
            if (shape <= 0.0 || scale <= 0.0)
            {
                throw new ArgumentOutOfRangeException("Unable to generate random sample from Weibull distribution. Shape and scale parameters must be positive. Recieved shape " + shape + " and scale " + scale + ".");
            }
            return scale * Math.Pow(-Math.Log(Uniform()), 1.0 / shape);
        }

        public double Cauchy(double median, double scale)
        {
            if (scale <= 0)
            {
                throw new ArgumentException("Unable to generate random sample from Cauchy distribution. Scale must be positive. Received " + scale + ".");
            }

            double p = Uniform();
            return median + scale * Math.Tan(Math.PI * (p - 0.5));
        }

        public double StudentsT(double degreesOfFreedom)
        {
            if (degreesOfFreedom <= 0)
            {
                throw new ArgumentException("Unable to generate random sample from student's t-distribution. Degrees of freedom must be positive. Received " + degreesOfFreedom + ".");
            }

            double y1 = Normal();
            double y2 = ChiSquared(degreesOfFreedom);
            return y1 / Math.Sqrt(y2 / degreesOfFreedom);
        }

        public double Laplace(double mean, double scale)
        {
            double u = Uniform();
            return (u < 0.5) ? mean + scale * Math.Log(2.0 * u) : mean - scale * Math.Log(2 * (1 - u));
        }

        public double LogNormal(double mu, double sigma)
        {
            return Math.Exp(Normal(mu, sigma));
        }

        public double Beta(double a, double b)
        {
            if (a <= 0.0 || b <= 0.0)
            {
                throw new ArgumentOutOfRangeException("Unable to generate random sample from beta distribution. Beta parameters must be positive. Received " + a + " and " + b + ".");
            }

            double u = Gamma(a, 1.0);
            double v = Gamma(b, 1.0);
            return u / (u + v);
        }
    }
}

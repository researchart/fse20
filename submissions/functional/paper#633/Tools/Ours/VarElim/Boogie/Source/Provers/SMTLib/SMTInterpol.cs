using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Diagnostics.Contracts;
using System.IO;
using System.Text.RegularExpressions;


namespace Microsoft.Boogie.SMTLib
{
    class SMTInterpol
    {
        static string _proverPath;

        static string CodebaseString()
        {
            Contract.Ensures(Contract.Result<string>() != null);
            return Path.GetDirectoryName(cce.NonNull(System.Reflection.Assembly.GetExecutingAssembly().Location));
        }

        public static string ExecutablePath()
        {
            if (_proverPath == null)
                FindExecutable();
            return _proverPath;
        }

        static void FindExecutable()
        // throws ProverException, System.IO.FileNotFoundException;
        {
            Contract.Ensures(_proverPath != null);

            // Command line option 'smtinterpolexe' always has priority if set 
            // not implemented
           
            var proverExe = "smtinterpol-2.5-7-g64ec65d.jar";

            if (_proverPath == null)
            {
                // Initialize '_proverPath'
                _proverPath = Path.Combine(CodebaseString(), proverExe);
                string firstTry = _proverPath;

                if (File.Exists(firstTry))
                {
                    if (CommandLineOptions.Clo.Trace)
                    {
                        Console.WriteLine("[TRACE] Using prover: " + _proverPath);
                    }
                    return;
                }

                if (!File.Exists(_proverPath))
                {
                    throw new ProverException("Cannot find prover: " + _proverPath);
                }

            }
        }


        public static void SetupOptions(SMTLibProverOptions options)
        {
             FindExecutable();
         
            //options.AddWeakSmtOption("produce-unsat-cores", "true");
            //options.AddWeakSmtOption("smt-lib-version", "2.0");
            //options.AddWeakSmtOption("produce-models", "true");
            options.AddWeakSmtOption("produce-proofs", "true");
        }


    }
}

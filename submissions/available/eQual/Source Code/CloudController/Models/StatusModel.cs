using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CloudController.Models
{
    public class StatusModel
    {
        public static int CreateProject(int currentStat)
        {
            return currentStat | 1;
        }

        public static int UploadedModelFile(int currentStat)
        {
            return currentStat | (1<<1);
        }
        public static int UploadedLanguageFile(int currentStat)
        {
            return currentStat | (1<<2);
        }
        public static int AnalyzedModel(int currentStat)
        {
            return currentStat | (1<<3);
        }
        public static int SavedBoundaries(int currentStat)
        {
            return currentStat | (1 << 4);
        }
        public static int StartedOptization(int currentStat)
        {
            return currentStat | (1 << 5);
        }
    }
}
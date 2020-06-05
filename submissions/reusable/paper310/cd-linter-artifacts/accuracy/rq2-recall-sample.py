import numpy as np
import pandas
import random
import re
import sys
from scipy.stats import pearsonr, spearmanr


def computeProjectSet(list, splitRule, categories):
    resulting_set = set()
    base_link = "https://gitlab.com"

    for name in list:
        if splitRule != "":
            splittedName = name.split(splitRule)

            new_name = base_link

            for token in splittedName:
                if token in categories:
                    break
                else:
                    token = re.sub(r"[ <>#%\"{}|^'`;\[\]/?:@&=+$,\.()\\\\]", my_replace, token)
                    new_name += "/" + token
            resulting_set.add(new_name)

    return resulting_set


def my_replace(match):
    return "-"


def recallSample(start_data_file, rqone_file, rqtwo_file, output_file, categories):
    with open(start_data_file) as dataset_reader, open(rqone_file, 'r', encoding="utf-8") as rqone_reader, open(rqtwo_file) as rqtwo_reader:
        dataset = pandas.read_csv(dataset_reader)
        # hasYaml	hasRequirements	hasPoms
        dataset = dataset.loc[dataset['hasYaml']]
        rqone = pandas.read_csv(rqone_reader)
        rqtwo = pandas.read_csv(rqtwo_reader)

        dataset_len = dataset.shape[0]
        rqone_len = rqone.shape[0]
        rqtwo_len = rqtwo.shape[0]
        print("Dataset's size: " + str(dataset_len))
        print("RQ1's size: " + str(rqone_len))
        print("RQ2's size: " + str(rqtwo_len))

        header = dataset.shape[0]
        dataset_proj = dataset['project']
        rqone_proj = rqone['id']
        rqtwo_proj = rqtwo['ID']

        # note that in RQ2 some issues (of different type) belong to the same project and some project are shared by
        # RQ1 and RQ2
        dataset_set = computeProjectSet(dataset_proj, "/", categories)
        rqone_set = computeProjectSet(rqone_proj, "__", categories)
        rqtwo_set = computeProjectSet(rqtwo_proj, "__", categories)
        print("Dataset's size (unique): " + str(len(dataset_set)))
        print("RQ1's size (unique): " + str(len(rqone_set)))
        print("RQ2's size (unique): " + str(len(rqtwo_set)))

        # compute the candidate set
        d0 = dataset_set.difference(rqone_set)
        print("d0 (dataset - RQ1): " + str(len(d0)))
        # print(d0)
        d1 = d0.difference(rqtwo_set)
        print("d1 (d0 - RQ2): " + str(len(d1)))
        # print(d1)
        print("---")

        # compute the recall sample and save it
        sample_size = 100
        recall_sample = random.sample(d1, sample_size)
        recall_projects = {'project': recall_sample}
        recall_df = pandas.DataFrame(recall_projects)
        recall_df.to_csv(output_file, index=False)

    return


if __name__ == '__main__':

    start_data_file = sys.argv[1] # "analyzedprojects.csv"
    rqtwo_precision = sys.argv[2] # "rq2-precision.csv"
    rq1cdsmells = sys.argv[3] # "rq1-cdsmells.csv"
    output_file = sys.argv[4]
    
    print("\n### RQ2 generate recall sample ###\n")
    categories = {"Job-Allow-Failure", "Job-Retry", "Manual-Job", "Versioning"}
    recallSample(start_data_file, rq1cdsmells, rqtwo_precision, output_file, categories)


from Binary.Scripts.TreeLearning import *
from Binary.Scripts.Denasrule import *


def transferRuleSet(RuleSet):
    NewRuleSet = set()
    for rule in RuleSet:
        str_rule = []
        for r in rule:
            str_rule.append(r[0] * BIT + r[1])
        str_rule = np.sort(str_rule)
        new_s = ''
        for r in str_rule:
            new_s += str(r) + '_'
        NewRuleSet.add(new_s)
    return NewRuleSet



def calculate_stability(testnum):
    x, y = loaddata("../data/train_model_data.pkl")
    x = x + 1
    RuleSet_1 = generateDTreeRuleSet(x, testnum)[:50]
    R_1 = transferRuleSet(RuleSet_1)
    RuleSet_2 = generateDTreeRuleSet(x, testnum)[:50]
    R_2 = transferRuleSet(RuleSet_2)

    return len(R_1 & R_2) / (len(R_1 | R_2))



def DenasValue():
    model = load_model("../model/rnn_model.h5")
    puppetModel = getPuppetModel("../model/rnn_model.h5")
    R_1 = gerenateDenasRule(puppetModel, model, 5, maxlength=5, rule_number=50)
    R_1 = transferRuleSet(R_1)
    R_2 = gerenateDenasRule(puppetModel, model, 5, maxlength=5, rule_number=50)
    R_2 = transferRuleSet(R_2)
    return len(R_1 & R_2) / (len(R_1 | R_2))



def baseline_stability():
    testnum = 1000
    print('DTExtract   1000:',calculate_stability(testnum))
    testnum = 5000
    print('DTExtract   5000:',calculate_stability(testnum))
    testnum = 10000
    print('DTExtract   10000:', calculate_stability(testnum))



if __name__ == '__main__':
    print('Denas:', DenasValue())
    baseline_stability()

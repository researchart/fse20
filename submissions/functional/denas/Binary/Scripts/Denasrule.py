from Binary.Scripts.utils import *
from Binary.Scripts.utils import *


def generateNewfeature(rule, featureNum, puppetModel , model):
    activationState = calAcStateFromRule(rule, model)
    contributionVec = calContributionVec(puppetModel, activationState)
    for pt in rule:
        contributionVec[int(pt / BIT), int(pt % BIT)] = 0
    newfeatureList = []
    for i in range(featureNum):
        newpt = np.argmax(contributionVec)

        pos = int(newpt / BIT)
        val = newpt % BIT
        newfeatureList.append([pos, val])
        contributionVec[pos] = 0
    return newfeatureList


def gerenateDenasRule( puppetModel , model, featureNum, maxlength = 10, rule_number = 10):
    RuleSet = [[]]
    while len(RuleSet):
        rule = RuleSet[0]
        RuleSet = RuleSet[1:]
        if len(rule) == maxlength:
            return RuleSet
        else:
            newrule = [r[0] * BIT + r[1] for r in rule]
            newfeatureList = generateNewfeature(newrule, featureNum, puppetModel , model)
            for pt in newfeatureList:
                cp_rule = rule.copy()
                cp_rule.append(pt)
                RuleSet.append(cp_rule)
            RuleSet = RuleSet[:rule_number]
    return RuleSet
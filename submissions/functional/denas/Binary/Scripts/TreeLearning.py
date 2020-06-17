from keras.models import load_model
import numpy as np
import pickle as pickle
from Binary.Scripts.utils import loaddata


class Node():
    def __init__(self):
        self.Pos = None
        self.EdgeList = []
        self.NodeList = []
        self.Parent = None
        self.Hidden = []
        self.HMM = []

    def generateRule(self):
        if self.Pos == None:
            return [self.Hidden]
        RuleSet = []
        for i in range(len(self.EdgeList)):
            SonRuleSet = self.NodeList[i].generateRule()
            if SonRuleSet != []:
                for sonrule in SonRuleSet:
                    rule = [[self.Pos, self.EdgeList[i]]]
                    rule.extend(sonrule)
                    RuleSet.append(rule)
            else:
                rule = [[self.Pos, self.EdgeList[i]]]
                RuleSet = [rule]
        return RuleSet


def decideLeafNode(data, label, feature):
    if (label == 1).all():
        return True, None
    index = np.nonzero(feature)[0]
    if len(index) == 0 or (data[:,index] == data[0,index]).all():
        rule = []
        for i in range(len(index)):
            rule.append([index[i], data[0, index[i]]])
        return True, rule
    return False,None


def calInforEntropy(data, label):
    pos_pk = np.sum(label) / len(label)
    neg_pk = 1 - pos_pk
    if pos_pk == 0:
        EntD = - neg_pk * np.log2(neg_pk)
        return  EntD
    if neg_pk == 0:
        EntD = -pos_pk * np.log2(pos_pk)
        return EntD
    return -(pos_pk * np.log2(pos_pk) + neg_pk * np.log2(neg_pk))


def selectBestFeature(data, label, feature):
    infEntropy = np.zeros([len(feature), 1])
    for i in range(len(feature)):
        if feature[i] == 0:    #this  feature has been selected
            infEntropy[i] = -100000
            continue
        else:
            possibleVal = getpossibleVal(data, label, i)
            for val in possibleVal:
                dataSubSet, labelSubSet = getSubData(data,label, i, val)
                infEntropy[i] -= calInforEntropy(dataSubSet, labelSubSet)

    bestPos = np.argmax(infEntropy)
    return bestPos


def getpossibleVal(data, label, pos):
    index = np.nonzero(label)[0]
    data = data[index,pos]
    dic = {}
    for d in data:
        if d in dic.keys():
            dic[d] += 1
        else:
            dic[d] = 1
    sorted(dic.items(),key=lambda item:item[1])
    valset = []
    for d in dic:
        valset.append(d)
    return valset


def getSubData(data, label, pos ,val):
    pos = int(pos)
    index = np.where(data[:, pos] == val)
    DataSet = data[index]
    labelset = label[index]
    return DataSet, labelset


def generateRuleTree(data, label, feature, height = 0):
    newNode = Node()
    isLeaf, Lag = decideLeafNode(data, label, feature)
    if  isLeaf == True:
        if Lag != None:
            newNode.Hidden = Lag
        else:
            newNode.HMM = None
        return newNode
    else:
        featurecopy = np.copy(feature)
        bestPos = int(selectBestFeature(data, label, featurecopy))
        if bestPos == None:
            return Node
        newNode.Pos = bestPos
        valList = getpossibleVal(data, label, bestPos)
        for val in valList:
            nextfeature = np.copy(feature)
            nextfeature[bestPos] = 0
            SubData, SubLabel = getSubData(data, label, bestPos, val)
            sonNode = generateRuleTree(SubData, SubLabel, nextfeature, height + 1)
            sonNode.Parent = newNode
            newNode.EdgeList.append(val)
            newNode.NodeList.append(sonNode)
        return newNode


def generateDTreeRuleSet(x, test_num):
    index = np.random.choice(np.arange(len(x)), test_num)
    x = x[index]
    model = load_model("../model/rnn_model.h5")

    pred_y = (model.predict(x, batch_size = 2000)[:, :, 1] > 0.5)
    test_x = np.zeros([len(x) * 140, 61])
    test_y = np.zeros([len(x) * 140, 1])
    nowsize = 0
    for i in range(len(x)):
        for j in range(30, 170):
            test_x[nowsize] = x[i][j - 30 : j + 31]
            test_y[nowsize] = pred_y[i][j]
            nowsize += 1
    feature = np.ones([61, 1])

    Root = generateRuleTree(test_x, test_y, feature, height=0)
    RuleSet = Root.generateRule()
    NewRuleSet = []
    for rindex in range(len(RuleSet)):
        rule = RuleSet[rindex]
        newrule = [[r[0] + 70, r[1]] for r in rule]
        NewRuleSet.append(newrule)
    return NewRuleSet


def main():
    x, y =  loaddata("../data/train_model_data.pkl")
    x = x + 1
    print("total data length is ", len(x), "total positive data is", np.sum(y))
    RuleSet = generateDTreeRuleSet(x, 100000)

    f = open("../RuleSet/"  + "tre.pkl", "wb")
    pickle.dump(RuleSet, f)
    f.close()


if __name__ == '__main__':
    main()





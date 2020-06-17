from Binary.Scripts.utils import  *
import datetime
import queue


VECSIZE = [0]


def generateNewpt(NowNode, puppetModel, model):
    activationState = calAcStateFromRule(NowNode.rule, model)
    contributionVec = calContributionVec(puppetModel, activationState)
    oldcontributionVec = contributionVec.copy()

    for pt in NowNode.rule:
        contributionVec[int(pt / BIT) - STARTINDEX] = -100000
    NewNodeList = []

    global VECSIZE
    while len(NowNode.dataset) >= np.max(VECSIZE):
        NewNode = None
        predy = 0
        while NewNode == None:
            newpt = np.argmax(contributionVec)
            newpt += STARTINDEX * BIT
            pos = int(newpt / BIT)
            val = newpt % BIT
            NewNode = NowNode.SplitNode(newpt)
            if NewNode != None:
                predy = calPredy(oldcontributionVec, NewNode.rule)
            contributionVec[pos - STARTINDEX, val] = -10000
        NewNode.SetPredy(predy)
        NewNodeList.append(NewNode)
        VECSIZE.append(len(NewNode.dataset))
    VECSIZE.append(len(NowNode.dataset))
    return NewNodeList, NowNode


def completeSingleNode(NowNode, puppetModel, model):
    activationState = calAcStateFromRule(NowNode.rule, model)
    contributionVec = calContributionVec(puppetModel, activationState)

    for pt in NowNode.rule:
        contributionVec[int(pt / BIT)] = 0

    while len(NowNode.rule) <= TerminationLength or NowNode.predy <= 0:
        newpt = np.argmax(np.abs(contributionVec))
        if contributionVec[newpt] > 0:
            newpt = newpt * 2 + 1
        else:
            newpt = newpt * 2

        pos = int(newpt / BIT)
        val = newpt % BIT

        if  NowNode.dataset[0, pos] == val:
            NowNode.rule.append(newpt)
            predy = calPredy(contributionVec, NowNode.rule)
            NowNode.SetPredy(predy)

        contributionVec[pos] = 0
    return NowNode




def main():
    model = load_model("../model/rnn_model.h5")
    puppetModel = getPuppetModel("../model/rnn_model.h5")
    x, y =  loaddata("../data/train_model_data.pkl")
    pos = np.where(y > 0)
    fs = int(np.sum(y))
    pos_x = np.zeros([fs, FEANUM])
    print("total input data number is ", len(x), "total function start is", np.sum(y))
    for i in range(len(pos[0])):
        row = pos[0][i]
        col = pos[1][i]
        st = np.max([pos[1][i] - 20, 0])
        ed = np.min([pos[1][i] + 21, FEANUM])
        pos_x[i, (100 - col + st):(100 - col + ed)] = x[row, st:ed]
    pos_x += 1

    # pos_x = pos_x[np.where(pos_x[:, 100] == 86)]

    global  VECSIZE
    VECSIZE.append(len(pos_x))

    node = RuleStructure(pos_x, [])
    node.SetPredy(-100)
    myque = queue.PriorityQueue()
    myque.put(node)

    RuleSet = []
    SingLeRuleSet = []
    CoveredSum = 0
    while myque.qsize() and len(RuleSet) < 1000:
        print("=========================================================================")
        print("NOW there are ", myque.qsize(), "DataSet in the QUEUE")
        print("=========================================================================")
        st_time = datetime.datetime.now()
        NowNode = myque.get()
        del VECSIZE[np.argmax(VECSIZE)]
        print("Now the Dataset size is ", len(NowNode.dataset), ", The rule length is", len(NowNode.rule))
        if len(NowNode.dataset) <= 1:
            print("the rest data is the single point")
            break
        if NowNode.decideRule() == True:
            RuleSet.append(NowNode.rule)
            print("Find a rule cover data number is ", len(NowNode.dataset))
            CoveredSum += len(NowNode.dataset)
        else:
            NewNodeList, NowNode = generateNewpt(NowNode, puppetModel, model)
            for NewNode in NewNodeList:
                if len(NewNode.dataset) != 1:
                    myque.put(NewNode)
                else:
                    SingLeRuleSet.append(NewNode)
            if len(NowNode.dataset) != 1:
                myque.put(NowNode)
            else:
                SingLeRuleSet.append(NowNode)


        ed_time = datetime.datetime.now()
        print("Split a node cost Time : ", ed_time - st_time)

    return RuleSet








if __name__ == '__main__':
    st_time = datetime.datetime.now()
    RuleSet = main()
    ed_time = datetime.datetime.now()

    NewRuleSet = []
    for rule in RuleSet:
        newrule = []
        for r in rule:
            newrule.append([int(r / BIT), r % BIT])
        NewRuleSet.append(newrule)

    f = open("../RuleSet/RuleSet.pkl", "wb")
    pickle.dump(NewRuleSet, f)
    f.close()

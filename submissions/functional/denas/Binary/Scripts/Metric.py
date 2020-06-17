from Binary.Scripts.utils import *




def testCoverage(RuleSet, x, rule_number = 1000):
    totalCover = 0
    coverIndex = np.zeros([len(x) , 1])
    NoCoverRuleSet = []
    rulueCoverNum = np.zeros(rule_number)
    for rindex in range(len(RuleSet)):
        if rindex > rule_number:
            break
        rule = RuleSet[rindex]
        coverNum = 0
        for i in range(len(x)):
            covered = True
            for r in rule:
                if x[i][int(r[0])] != r[1]:
                    covered = False
                    break
            if covered == True and coverIndex[i] == 0:
                coverNum += 1
                coverIndex[i] = 1
        if coverNum == 0:
            NoCoverRuleSet.append(rule)
        totalCover += coverNum
        rulueCoverNum[rindex] = coverNum

    for i in range(1, len(rulueCoverNum)):
        rulueCoverNum[i] = rulueCoverNum[i - 1] + rulueCoverNum[i]
    rulueCoverNum = rulueCoverNum / len(x)
    return rulueCoverNum


# def ConsistencyOut(RuleSet, model, mean_vec, maxlength = 5, target = 1):
#     consistency = np.zeros([len(RuleSet), 1])
#     # tmp_vec = np.tile(mean_vec, (1000, 1))
#     for rnum in range(len(RuleSet)):
#         rule = RuleSet[rnum]
#         #testData = np.random.randint(0, BIT,[1000, FEANUM])
#         tic = datetime.datetime.now()
#         testData = np.random.random([100, FEANUM])
#         testData = np.int32(testData < (mean_vec / FEANUM))
#         oripredict = model.predict(testData, batch_size = 1000) > 0.5
#
#         rule = rule[0 : maxlength]
#         for r in rule:
#              testData[:, r[0]] = r[1]
#
#         if target == 1:
#             testData = testData[np.where(oripredict == 0)[0]]
#             consist = np.sum(model.predict(testData, batch_size = 1000) > 0.5)
#         else:
#             testData = testData[np.where(oripredict == 1)[0]]
#             consist = np.sum(model.predict(testData, batch_size=1000) < 0.5)
#         if len(testData) != 0:
#             consistency[rnum] = consist / len(testData)
#         else:
#             consistency[rnum] = 0
#         toc = datetime.datetime.now()
#         print(rnum, "cost time", toc - tic)
#     return np.mean(consistency)
#


def ConsistencyIn(x, RuleSet, pred_y, maxlength = 5):
    consistency = np.zeros([len(RuleSet)])
    for j in range(len(RuleSet)):
        r_y = np.zeros_like(pred_y)
        rule = RuleSet[j]
        rule = rule[:maxlength]
        theta = [abs(x[:, r[0]] - int(r[1]))  for r in rule]
        theta =np.array(theta)
        theta = np.sum(theta, axis= 0)
        pos = np.where(theta == 0)
        r_y[pos] = 1
        Y_Y = np.sum((r_y == 1) * (pred_y == 1))
        if np.sum(r_y) != 0:
            consistency[j] = Y_Y / np.sum(r_y)
        else:
            consistency[j] = -1
    consistency = consistency[np.where(consistency != -1)]
    return consistency


def AddPattern(RuleSet, model, x, target_label = 1, maxlength = 5):
    rate = np.zeros([len(RuleSet)])
    ccc = 0
    for rule in RuleSet:
        xx = x.copy()
        rule = rule[0 : maxlength]
        for r in rule:
            xx[:, r[0]] = r[1]
        pred_y = (model.predict(xx, batch_size= 1000) > 0.5)
        rate[ccc] = np.sum(pred_y == target_label) / len(xx)
        ccc += 1
    return rate



def existRule(RuleSet, data):
    x = data[0]
    for rule in RuleSet:
        coverNum = 0
        st_time = datetime.datetime.now()
        for i in range(len(x)):
            for st in range(11, 189):
                covered = True
                for r in rule:
                    if (x[i][int(st - 10 + r[0])] != r[1]):
                        covered = False
                        break
                if covered == True:
                    coverNum += 1
        ed_time = datetime.datetime.now()
        print(rule, "really exist, appear", coverNum, "cost time", ed_time - st_time)
        f = open("data\\appear_time.txt", "a")
        f.write(str(coverNum))
        f.write("\n")
        f.close()





import keras
import numpy as np
import pickle as pickle
from keras.preprocessing.sequence import pad_sequences
from keras.models import Sequential
from keras.utils import plot_model
from keras.models import load_model
from keras.optimizers import RMSprop
from keras.layers import Dense, Activation, Dropout, SimpleRNN, Embedding, Bidirectional,TimeDistributed


def load_data(file_Name):
    print('[Load data...]')
    f = open(file_Name, 'rb')
    data = pickle.load(f)

    data_num = len(data[0])
    print('Data_num:', data_num)
    seq_len = len(data[0][0])
    print('Sequence length:', seq_len)
    return data[0], data[1]


def createModel():
    model = keras.Sequential()
    model.add(Embedding(256,16,input_length=200))
    model.add(Bidirectional(SimpleRNN(8,activation=None, return_sequences=True)))
    model.add(Activation('relu'))

    model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True)))
    model.add(Activation('relu'))

    model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True)))
    model.add(Activation('relu'))
    model.add(Dropout(0.5))

    model.add(TimeDistributed(Dense(2,activation='softmax')))

    #model.compile(loss = my_loss_fun, optimizer='sgd', metrics=['accuracy'])

    model.compile(loss=keras.losses.categorical_crossentropy,
                  optimizer=keras.optimizers.Adadelta(),
                  metrics=['accuracy'])

    #plot_model(model, to_file='mymodel.png', show_shapes=True)

    return model


def my_loss_fun(y_true, y_pred):
    theta = (y_true[:,:,1] - y_pred[:,:,1])
    return np.min(theta)


def NormalRuleSet(RuleSet):
    newRuleSet = []
    for rule in RuleSet:
        st_pt = 100
        for r in rule:
            st_pt = np.min([r[0], st_pt])
        newrule = []
        for r in rule:
            newrule.append([r[0] - st_pt, r[1]])
        newRuleSet.append(newrule)
    return newRuleSet


def selAvailableRule(x, index, RuleSet):
    selIndex = []
    for i in index:
        covered = False
        for rule in RuleSet:
            testSample = np.zeros([1, 4])
            for r in rule:
                testSample[0][int(r[0])] = r[1]
            for j in range(196):
                if (x[i][j : j + 4] == testSample).all():
                    print("find a forbidden instance")
                    covered = True
                    break
            if covered == True:
                break
        if covered == False:
            selIndex.append(i)
    return selIndex





def  main():
    data_path = 'D:\\machineLearning_Data\\elf-x86OUT\\1.pkl'
    x,y = load_data(data_path)
    y_labels = keras.utils.to_categorical(y, num_classes = 2)

    dataSize = np.int(len(x) / 10)
    index = np.random.randint(0,10,dataSize)
    delindex = []
    for i in range(dataSize):
        delindex.append(i * 10 + index[i])

    train_X = x[delindex]
    train_Y = y_labels[delindex]
    x = np.delete(x, delindex, axis = 0)
    y = np.delete(y, delindex, axis = 0)
    f = open("data\\DNN_train_data.pkl", "wb")
    pickle.dump([train_X, train_Y], f)
    f.close()
    print("finish save my DNN data")


    dataSize = np.int(len(x) / 10)
    index = np.random.randint(0, 10, dataSize)
    delindex = []
    for i in range(dataSize):
        delindex.append(i * 10 + index[i])
    mymodel_x = x[delindex]
    mymodel_y = y[delindex]
    x = np.delete(x, delindex, axis=0)
    y = np.delete(y, delindex, axis=0)
    f = open("data\\build_model_data.pkl", "wb")
    pickle.dump([mymodel_x, mymodel_y], f)
    f.close()
    print("finish save my model data")



    dataSize = np.int(len(x) / 10)
    index = np.random.randint(0, 10, dataSize)
    delindex = []
    for i in range(dataSize):
        delindex.append(i * 10 + index[i])
    testDNN_x = x[delindex]
    testDNN_y = y[delindex]
    x = np.delete(x, delindex, axis=0)
    y = np.delete(y, delindex, axis=0)
    f = open("data\\test_DNN_data.pkl", "wb")
    pickle.dump([testDNN_x, testDNN_y], f)
    f.close()
    print("finish save my test DNN data")


    f = open("data\\test_model_data.pkl", "wb")
    pickle.dump([x, y], f)
    f.close()
    print("finish save my test model data")

    model = createModel()
    model.fit(train_X, train_Y, batch_size=100, validation_split=0.0, epochs=20, )
    model.save('model\\rnn_model.h5')
    print("finish train model")


if __name__ == '__main__':
    main()
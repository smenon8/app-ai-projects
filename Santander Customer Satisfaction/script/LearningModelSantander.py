from sklearn import tree
import csv
import pandas as pd
import matplotlib.pyplot as plt
import random
import numpy as np
from sklearn.metrics import roc_curve, auc
from sklearn.cross_validation import train_test_split
import math


# shuffle and split training and test sets
def splitTrainTest(splitRatio,fullData):
    if not fullData:
        dataFull = pd.read_csv("../data/filteredData.csv")
    else:
        dataFull = pd.read_csv("../data/train.csv")
        
    header = dataFull.columns
    lastIndex = len(header) - 1
    
    trainDataAttribs = pd.DataFrame(dataFull,columns = header[:lastIndex])
    targetVar = pd.DataFrame(dataFull,columns = [header[lastIndex]])
    
    X_train, X_test, y_train, y_test = train_test_split(trainDataAttribs, targetVar, test_size=splitRatio,random_state=0)
    
    return X_train, X_test, y_train, y_test


def treeClassifier(trainTestProp,fullDataParam = False):    
    X_train, X_test, y_train, y_test = splitTrainTest(trainTestProp,fullDataParam)

    clf = tree.DecisionTreeClassifier()
    clf = clf.fit(X_train, y_train)
    predictions = clf.predict(X_test)
    
    # Logic for calculating accuracy
    correctPred = 0
    for i in range(len(predictions)):
        if predictions[i] == y_test.iat[i,0]:
            correctPred += 1
    accuracy = correctPred * 100/len(predictions)
    
    
    trueNeg = 0
    truePos = 0
    falsePos = 0
    falseNeg = 0
    
    totalPositives = 0
    totalNegatives = 0
    for i in range(len(predictions)):
        if y_test.iat[i,0] == 1:
            totalPositives += 1
        else:
            totalNegatives += 1
            
    for i in range(len(predictions)):
        # logic for calculating True Negatives
        if predictions[i] == y_test.iat[i,0] and predictions[i] == 0:
             trueNeg += 1

        # logic for calculating True positives        
        if predictions[i] == y_test.iat[i,0] and predictions[i] == 1:
             truePos += 1
        
        # logic for calculating False positives        
        if predictions[i] != y_test.iat[i,0] and predictions[i] == 1:
             falsePos += 1

        # logic for calculating False negatives        
        if predictions[i] != y_test.iat[i,0] and predictions[i] == 0:
             falseNeg += 1
      
    tpf = truePos/totalPositives
    fpf = falsePos/totalPositives
    tnf = trueNeg/totalNegatives
    fnf = falseNeg/totalNegatives
    
    return accuracy,tpf,fpf,tnf,fnf

# after attribute selection
TPF = []
FPF = []
TNF = []
FNF = []
accuracy = []
for i in np.arange(0.1,1,0.1):
    acc,tpf,fpf,tnf,fnf = treeClassifier(i)
    accuracy.append(acc)
    TPF.append(tpf)
    FPF.append(fpf)
    TNF.append(tnf)
    FNF.append(fnf)


# calculate the area of a triangle given by points on roc curve
areaAll = []

for i in range(len(FNF)):
    start = (0,0) # A
    between = (FNF[i],TNF[i]) # B
    end = (1,1) # C

    AB = math.sqrt((start[0] - between[0])**2 + (start[1] - between[1])**2)
    BC = math.sqrt((end[0] - between[0])**2 + (end[1] - between[1])**2)
    AC = math.sqrt((start[0] - end[0])**2 + (start[1] - end[1])**2)

    s = (AB + BC + AC) / 2
    area = 0.5 + (s*(s-AB)*(s-BC)*(s-AC)) ** 0.5
    areaAll.append(area)

## Print output 
for i in range(len(accuracy)):
    print("Current split %f - %f" %((i*10)+10,(100-i*10)-10))
    print("Accuracy : %f" %(accuracy[i]))
    print("Area under the ROC curve : %f" %areaAll[i])
    print()

# Accuracy plot
x = np.arange(0.1,1,0.1)
z = np.polyfit(x,accuracy, 2)
f = np.poly1d(z)

x_new = np.linspace(x[0], x[-1], 50)
y_new = f(x_new)

plt.figure(1)
plt.plot(x,accuracy,'o')
plt.plot(x_new,y_new,lw=2)
plt.xlabel("Train data - Test data split")
plt.ylabel("Accuracy percentage")
plt.title("Train-test split versus accuracy, fitted to a 2 degree polynomial curve")

# Plot for negative estimations
z = np.polyfit(FNF, TNF, 2)
f = np.poly1d(z)

x_new = np.linspace(FNF[0], FNF[-1], 50)
y_new = f(x_new)

plt.figure(2)
plt.plot(FNF,TNF,'o')
plt.xlabel("False Unsatisfied Customer Fraction")
plt.ylabel("True Unsatisfied Customer Fraction")
plt.title("ROC curve candidate points for all Unsatisfied Customers")

plt.figure(3)
plt.plot(FNF,TNF,'o', x_new, y_new)
plt.plot([0, x_new[49]], [0,y_new[49]],lw=2)
plt.plot([x_new[0],1],[y_new[0],1], lw=2)
plt.plot([0, 0.5,1],[0, 0.5,1], lw=2)
plt.xlabel("False Unsatisfied Customer Fraction")
plt.ylabel("True Unsatisfied Customer Fraction")
plt.title("ROC curve - representational area under the curve, zoom to the top left to see all points")


plt.show()
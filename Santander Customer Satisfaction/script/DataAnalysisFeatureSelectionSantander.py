
# coding: utf-8

# <b>Applied AI :</b>  San-Ander Bank Customer Satisfaction <br>
# <b>Number of Input attributes :</b>  370 <br>
# <b>Output attribute name : </b> TARGET <br>
# <b>Author:</b>  Sreejith Menon <br>
# <b>Date: </b> 03rd April 2016 <br>
# 
# Applying feature selection before building a neural net:
# http://www3.it.nuigalway.ie/cirg/localpubs/aics01.pdf

# In[2]:

import csv
import pandas as pd
import math
import importlib
import FeatureSelectionAPI as FS
importlib.reload(FS) # uncomment if any changes are made to the API


# create sample toy training file with rows number of rows
def createToyFile(inFileName,outFileName,sampleSize):
    reader = csv.reader(open(inFileName,"r"))
    head = reader.__next__()

    data = []
    i = 1
    for row in reader:
        data.append(row)
        if i >= sampleSize:
            break
        i += 1

    writeFL = open(outFileName,"w")
    writer = csv.writer(writeFL)
    writer.writerow(head)
    for row in data:
        writer.writerow(row)
    writeFL.close()
    
    print("Wrote %d samples from "  %i + inFileName + " to " + outFileName)
    print("Has %d attributes" %len(head))

createToyFile("../data/train.csv","../data/trainToy.csv",25000)

# Read the training data into a Panda data frame    
train = pd.read_csv("../data/trainToy.csv")


def getNextColumnPd(pandaObj,head):
    for attrib in head:
        yield pandaObj[attrib]


# Calculate information gain for every column in the data set
infoGainPerColn = []
count = 0
nextCol = getNextColumnPd(train,train.columns)
for i in range(len(train.columns)):
    infoGainPerColn.append((train.columns[i],FS.infoGain(next(nextCol),train.TARGET)))
    count += 1
    print("Percent complete %f" %(count*100/len(train.columns)))

# Calculate the average of the information gains
# Filter out all the candidate columns with information gain > avg(info_gain)
total = 0
count = 0

for row in infoGainPerColn:
    total += row[1]
    count += 1

average = total/count

infoGainPerColnFilteredGtAvg = list(filter(lambda x: x[1] >= average,(sorted(infoGainPerColn,key = lambda infoGainPerColn:infoGainPerColn[1], reverse=True))))
candidateCol = [col[0] for col in infoGainPerColnFilteredGtAvg ]
candidateCol.append(candidateCol.pop(1))


writeFL = open("../data/InfoGainPerColumn.csv","w")
writer = csv.writer(writeFL)
for row in infoGainPerColnFilteredGtAvg:
    writer.writerow(row)
writeFL.close()


trainFull = pd.read_csv("../data/train.csv")
dt = pd.DataFrame(trainFull,columns = candidateCol)
dt.to_csv("../data/filteredData.csv",index=False)


test = pd.read_csv("../data/test.csv")
df = pd.DataFrame(test,columns = candidateCol)
df.to_csv("../data/filteredDataTest.csv",index=False)


from create_spark_session import create_spark_session
import pandas as pd
import numpy as np
from pyspark.sql.types import *
import pyspark.sql.functions as F
import pickle

# create spark session
[spark, sqlContext] = create_spark_session()

# create the dataframe
pd_df = pd.DataFrame([['p1', ['e', 'c', 'e', 'c']],
                      ['p2', ['a', 'b', 'c', 'd']],
                      ['p3', ['a', 'e', 'b', 'e']],
                      ['p4', ['b', 'z', 'a', 'v']]], columns=['Passengers', 'list_POIs'])

# convert to spark dataframe
sample_df = sqlContext.createDataFrame(pd_df)

# the dictionnary of POIs and embeddings
small_dict_POI2vec = {'a': [1.01, 1.01, 1.01],
                      'b': [2.01, 2.01, 2.01],
                      'c': [3.01, 3.01, 3.01],
                      'd': [4.01, 4.01, 4.01],
                      'e': [5.01, 5.01, 5.01],
                      'f': [6.01, 6.01, 6.01]}


# create a boolean to check if all items in a sublist are in a list
udf_list = F.udf(lambda p: all(i in [*small_dict_POI2vec] for i in p), BooleanType())
sample_df = sample_df.withColumn("Boolean", udf_list("list_POIs"))
sample_df = sample_df.filter(sample_df["Boolean"] != False).drop("Boolean")
sample_df.show()

# each passengers get their POI vector representation
udf_users_emb = F.udf(lambda p: [small_dict_POI2vec[k] for k in p if k in p], ArrayType(ArrayType(FloatType())))
sample_df = sample_df.withColumn("POI_emb", udf_users_emb("list_POIs"))
sample_df.show(truncate=False)

# get passengers vector representation. Suppose its the sum of POIs
udf_sum_POI_emb = F.udf(lambda p: [sum(i) for i in zip(*p)])
sample_df = sample_df.withColumn("passengers_emb", udf_sum_POI_emb("POI_emb"))
sample_df.show(truncate=False)

# get passengers vector representation. Suppose its the sum of POIs

# read the POI2vec
file_poi2vec = open('/mnt/usb2/PassengerAI/POI_sequence/poi2vec.pickle', 'rb')
dict_POI2vec = pickle.load(file_poi2vec)
file_poi2vec.close()


# create the dataframe
pd_df = pd.DataFrame([['p1', ['pad', 'pad', '04DN9BobXaFAB9NZM5y6qRL36dSDEB4wXgsMFcYrdeM=', '2pdDWxldT7EkNAO3_KATfK1oXLsKVnIpLY-nwSYe_rY=']],
                      ['p2', ['pad', '2pdDWxldT7EkNAO3_KATfK1oXLsKVnIpLY-nwSYe_rY=', 'h30M_vGF8OcpqxEQCjtkI53qPXG4v4aWMmu9J98raZw=', 'BU0bx4khPgZZ2K-HiiEJ2LH4uRtS4tjsmJr6QOXnseM=']],
                      ['p3', ['pad', 'pad', 'pad', 'pad']],
                      ['p4', ['pad', 'z', 'a', 'v']]], columns=['Passengers', 'list_POIs'])

sample_df = sqlContext.createDataFrame(pd_df)

keys = ['pad', '04DN9BobXaFAB9NZM5y6qRL36dSDEB4wXgsMFcYrdeM=', '2pdDWxldT7EkNAO3_KATfK1oXLsKVnIpLY-nwSYe_rY=', 'h30M_vGF8OcpqxEQCjtkI53qPXG4v4aWMmu9J98raZw=', 'BU0bx4khPgZZ2K-HiiEJ2LH4uRtS4tjsmJr6QOXnseM=']
dct = {key: dict_POI2vec[key] for key in keys}

# create a boolean to check if all items in a sublist are in a list
udf_list = F.udf(lambda p: all(i in [*dct] for i in p), BooleanType())
sample_df = sample_df.withColumn("Boolean", udf_list("list_POIs"))
sample_df = sample_df.filter(sample_df["Boolean"] != False).drop("Boolean")
sample_df.show()

def my_func(list_poi):
    poi_emb = []
    for item in list_poi:
        if item in dct.keys():
            poi_emb.append(dct[item].tolist())
    res = [sum(i) for i in zip(*poi_emb)]
    return res

my_func(['pad', 'pad', '04DN9BobXaFAB9NZM5y6qRL36dSDEB4wXgsMFcYrdeM=', '2pdDWxldT7EkNAO3_KATfK1oXLsKVnIpLY-nwSYe_rY='])

udf_my_func = F.udf(my_func, ArrayType(FloatType()))
sample_df = sample_df.withColumn("POI_emb", udf_my_func("list_POIs"))
sample_df.show()

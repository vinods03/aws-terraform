import sys
import os
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col
from pyspark.sql.functions import explode
from pyspark.sql.functions import split 
# split is not used here because we get a struct after explode. we use the "." notation to access columns within a struct.
# if we had got a string after explode, split might have helped in accessing individual columns
from pyspark.sql.functions import year, month, dayofmonth, hour
# from pyspark.context import SparkContext

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'appName', 'tgt_file_format', 'tgt_bucket'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

def write(df, format, folder, partition_col1, partition_col2, partition_col3, partition_col4):
    
    print('The target file format is ', format)
    print('The target folder is ', folder)
    df.write.partitionBy(partition_col1, partition_col2, partition_col3, partition_col4).mode('append').format(format).save(folder)

def core():

    appName = args['appName']
    tgt_file_format = args['tgt_file_format']
    tgt_bucket = args['tgt_bucket']
    
    print('The appName is ', appName)
    print('The target file format is ', tgt_file_format)
    print('The target bucket is ', tgt_bucket)
    
    # spark.sql('select current_date()').show()

    print('****************************************** Source DF ************************************************')

    source_df = spark.read.json('s3://vinod-streaming-project-bucket/orders/')
    # source_df.printSchema()
    # source_df.show(truncate=False)

    print('****************************************** Source exploded DF ************************************************')
    # multiple products are exploded into multiple rows
    # if an order has 3 products in the column 'products', that row will be exploded into 3 rows here

    source_exploded_df = source_df.withColumn('exploded_products', explode('products'))
    # source_exploded_df.printSchema()
    # source_exploded_df.show(truncate=False)

    print('****************************************** Source transformed DF ************************************************')
    # to access individual columns in struct, use the "." notation as shown below

    source_transformed_df = source_exploded_df.withColumn('product_code',col('exploded_products.product_code')).withColumn('product_name',col('exploded_products.product_name')).withColumn('product_price',col('exploded_products.product_price')).withColumn('product_qty',col('exploded_products.product_qty'))
    # source_transformed_df.printSchema()
    # source_transformed_df.show()

    print('****************************************** extract partition columns **********************************************')

    source_further_transformed_df = source_transformed_df.withColumn('order_purchase_year', year(col('order_purchase_timestamp'))) \
    .withColumn('order_purchase_month', month(col('order_purchase_timestamp'))) \
    .withColumn('order_purchase_day', dayofmonth(col('order_purchase_timestamp'))) \
    .withColumn('order_purchase_hour', hour(col('order_purchase_timestamp')))
    # source_further_transformed_df.printSchema()
    # source_further_transformed_df.show()

    print('****************************************** final DF ************************************************')
    # we select only the required columns. products and exploded_products columns are not needed any more because we have extracted the rows / columns from these columns

    final_df = source_further_transformed_df.select('order_id','customer_id','seller_id','product_code','product_name','product_price','product_qty','order_value','order_purchase_timestamp','order_purchase_year','order_purchase_month','order_purchase_day', 'order_purchase_hour')
    # final_df = source_further_transformed_df.select_fields(paths = ['order_id','customer_id','seller_id','product_code','product_name','product_price','product_qty','order_value','order_purchase_timestamp','order_purchase_year','order_purchase_month','order_purchase_day', 'order_purchase_hour'])
    # final_df.printSchema()
    # final_df.show()

    print('****************************************** write the transformed data *********************************************')
    write(final_df, tgt_file_format, tgt_bucket, 'order_purchase_year','order_purchase_month','order_purchase_day', 'order_purchase_hour')
    
if __name__ == '__main__':
    # appName = sys.argv[1]
    # tgt_file_format = sys.argv[2]
    # tgt_bucket = sys.argv[3]
    # core(appName, tgt_file_format, tgt_bucket)
    core()
    
job.commit()

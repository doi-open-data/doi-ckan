import os
import sys
import pandas as pd
from tabulate import tabulate

# function for printing df's to the console
pdtabulate=lambda df:tabulate(df,headers='keys',tablefmt='psql', showindex='never')

try:
    # read in our data
    data_path = os.path.join(os.path.dirname(os.path.realpath(__file__)))
    pdata = pd.read_csv(os.path.join(data_path, '../../report-prod.csv'))
    ldata = pd.read_csv(os.path.join(data_path, '../../report-local.csv'))
except:
    print('Could not read data. Error: {}'.format(sys.exc_info()))


# find harvest sources that are still running locally
local_running = ldata.loc[ldata['last_job_status'] == 'Running', ['title', 'name', 'total_datasets', 'last_job_created','last_job_finished', 'last_job_status']].reset_index()
if len(local_running) > 0:
    print('There are {} job(s) still running locally:'.format(len(local_running)))
    print(pdtabulate(local_running))
else:
    print('There are no running harvest jobs locally.')

# we're going to create two small statistic df's, then combine into one sumamry df
# first data is about dataset count -- second data is about error count diff

# dataset count
# merge production and data, rename columns, convert dtypes
dataset_compare = pdata[['title', 'total_datasets']].merge(ldata[['title', 'total_datasets']], on='title')
dataset_compare.columns = ['title', 'prod_datasets', 'local_datasets']
dataset_compare['prod_datasets'] = dataset_compare['prod_datasets'].astype(int)
# what percent of local is on production?
dataset_compare['local_prod_diff'] = dataset_compare['local_datasets'] / dataset_compare['prod_datasets'] * 100
# print dataset count stats
threshold = 90
dataset_diff = dataset_compare.loc[dataset_compare['local_prod_diff'] < threshold]
diff_count = len(dataset_diff)
if (diff_count > 0):
    print('There are {} dataset count differences below {}%'.format(diff_count, threshold))
    print(pdtabulate(dataset_diff.sort_values(by='local_prod_diff')))
else:
    print('There are no dataset count differences above {}%'.format(threshold))

# error count
# merge production and data, rename columns, calculate diff
error_compare = pdata[['title', 'last_job_errored']].merge(ldata[['title', 'last_job_errored']], on='title')
error_compare.columns = ['title', 'prod_error', 'local_error']
error_compare['error_diff'] = error_compare['local_error'] - error_compare['prod_error']
error_threshold = 0
error_diff = error_compare.loc[error_compare['error_diff'] > error_threshold]
# print error counts
if len(error_diff) > 0:
    print('There are {} error differences greater than {}'.format(len(error_diff), error_threshold))
    print(pdtabulate(error_diff.sort_values(by='error_diff')))
else:
    print('There are no error differences greater than {}'.format(error_threshold))

# produce summary df
summary_df = pd.concat([dataset_compare, error_compare.drop(columns='title')], axis='columns')
summary_df = summary_df.loc[(summary_df.local_prod_diff < threshold) | (summary_df.error_diff > error_threshold)]
summary_df.sort_values(by=['local_prod_diff','error_diff'], inplace=True)
# print(pdtabulate(summary_df))
# save to local path
path_to_save = os.path.join(data_path, '../../summary_stats.csv')
summary_df.to_csv(path_to_save, index=False)
print('Summary statistics csv saved at {}'.format(path_to_save))
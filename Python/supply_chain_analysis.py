# The purpose of this script is to inspect and validate the logistics
# shipments dataset before performing the main analysis.
# The script checks the dataset's structure, data types, missing values,
# duplicates, categorical distributions, and data consistency.


import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_excel('Data/logistics_shipments_dataset_raw.xlsx')

df['Shipment_Date'] = pd.to_datetime(df['Shipment_Date'], errors='coerce') #converts the shipment date column to datetime format
df['Delivery_Date'] = pd.to_datetime(df['Delivery_Date'], errors='coerce') #converts the delivery date column to datetime format

print("\n")
print(df[df['Delivery_Date'].isnull()][
    ['Shipment_ID','Status','Shipment_Date','Delivery_Date']
])


print(df.shape) #finds out how many lines and columns are in the dataset

print("\n")
df.info() #prints out the data types of each column and the number of non-null values

print("\n")
print(df[['Shipment_Date', 'Delivery_Date']].dtypes) #prints out the data types of the shipment and delivery date columns

print("\n")
print(df.head()) #prints the first 5 rows of the dataset

print("\n")
print(df.columns.tolist()) #prints out the column names of the dataset

print("\n")
print(df.isnull().sum()) #prints out the number of missing values in each column of the dataset

print("\n")
print(df.duplicated().sum()) #prints out the number of duplicate rows in the dataset


print("\n")
print(df['Origin_Warehouse'].value_counts()) #prints out the count of shipments from each origin warehouse
         
print("\n")
print(df['Destination'].value_counts()) #prints out the count of shipments to each destination  

print("\n")
print(df['Carrier'].value_counts()) #prints out the count of shipments by each carrier   

print("\n")
print(df['Status'].value_counts()) #prints out the count of shipments by each status    


print("\n")
print(df.describe()) #prints out the summary statistics of the dataset, including count, mean, std, min, 25%, 50%, 75%, and max values for each numerical column




print("\n")
print(df[df['Delivery_Date'].isnull()]['Status'].value_counts())
# prints out the status of shipments where the delivery date is missing

print("\n")
print(df[df['Cost'].isnull()]['Status'].value_counts())
# prints out the status of shipments where the cost is missing



#The below code calculates the transit days based on the shipment and delivery dates, and compares it to the existing transit days in the dataset. 
# It identifies any discrepancies between the calculated transit days and the recorded transit days.
df['Calculated_Transit_Days'] = (df['Delivery_Date'] - df['Shipment_Date']).dt.days
print("\n")

discrepancies = df[
    (df['Calculated_Transit_Days'].notnull()) &
    (df['Transit_Days'] != df['Calculated_Transit_Days']) 
] 

print(discrepancies.shape)
print(discrepancies.head(10))

print("\n")
print(df[df['Calculated_Transit_Days'] < 0][
    ['Shipment_ID', 'Shipment_Date', 'Delivery_Date', 'Calculated_Transit_Days']
])


#---------------
#Data Cleaning
#---------------

df_clean = df.copy()

df_clean['Missing_Delivery_Date'] = df_clean['Delivery_Date'].isnull()
df_clean['Missing_Cost'] = df_clean['Cost'].isnull()

df_clean['Calculated_Transit_Days'] = (
    df_clean['Calculated_Transit_Days'].astype('Int64')
)

df_clean['Invalid_Transit_Date'] = (
    df_clean['Calculated_Transit_Days'] < 0
)

df_analysis = df_clean[
    ~df_clean['Invalid_Transit_Date']
].copy() #creates a new dataset that excludes rows with invalid transit dates

df_analysis['Transit_Days_Calculated'] = (
    df_analysis['Delivery_Date'] - df_analysis['Shipment_Date']
).dt.days #calculates the transit days for the analysis-ready dataset

print("\n")
print(df_analysis['Transit_Days_Calculated'].describe())

carrier_transit = (
    df_analysis.groupby('Carrier')['Transit_Days_Calculated']
    .mean()
    .sort_values(ascending=False)
)


#The below code generates a bar chart to visualize the average transit time by carrier.
print("\n")
print(carrier_transit)              

print(carrier_transit)
carrier_transit.plot(kind='bar')
plt.title('Average Transit Time by Carrier')
plt.xlabel('Carrier')
plt.ylabel('Average Transit Days')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Export the cleaned dataset
df_analysis = df_analysis[
    [
        'Shipment_ID',
        'Shipment_Date',
        'Delivery_Date',
        'Weight_kg',
        'Cost',
        'Status',
        'Distance_miles',
        'Transit_Days',
        'Calculated_Transit_Days',
        'Missing_Delivery_Date',
        'Missing_Cost',
        'Invalid_Transit_Date',
        'Transit_Days_Calculated',
        'Origin_Warehouse',
        'Destination',
        'Carrier'
    ]
]

df_analysis.to_csv('Data/logistics_shipments_cleaned.csv', index=False)
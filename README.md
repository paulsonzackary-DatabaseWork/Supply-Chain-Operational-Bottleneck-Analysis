# Supply Chain & Operational Bottleneck Analysis

## Overview

This project analyzes shipment and logistics data to identify operational bottlenecks, delivery delays, and potential cost-saving opportunities.

The analysis uses Python, SQL, Excel, and Power BI to clean the data, investigate shipment performance, identify patterns across carriers and warehouses, and present the findings through an interactive dashboard.


## Business Questions

This project was designed to answer the following questions:

* Where are shipment delays occurring?
* Which carriers have the highest delay rates?
* Which warehouses experience the most delivery delays?
* How does shipping cost vary by delivery status?
* What operational patterns could indicate opportunities for improvement?


## Tools & Technologies

* **Python** — Data cleaning, exploration, and visualization
* **SQL / PostgreSQL** — Data analysis, joins, CTEs, window functions, and aggregations
* **Excel** — Pivot tables, data analysis, and supporting calculations
* **Power BI** — Interactive dashboard and data visualization
* **Git / GitHub** — Project documentation and version control


## Data Preparation

The raw shipment dataset was reviewed and prepared before analysis.

### Python

Python and pandas were used to:

* Inspect the dataset structure and data types
* Identify missing values and duplicate records
* Convert shipment and delivery dates into datetime format
* Identify invalid or missing date values
* Examine numerical distributions and data consistency
* Prepare the dataset for SQL and visualization

### SQL

The cleaned data was loaded into PostgreSQL for analysis. SQL was used to:

* Join and analyze shipment-related data
* Calculate delivery and delay metrics
* Compare carrier and warehouse performance
* Analyze shipping costs by delivery status
* Identify missing cost and delivery information
* Calculate rankings and operational performance metrics


## Key Findings

### Delivery Status

* **1,610 shipments (82.48%)** were delivered successfully.
* **191 shipments (9.78%)** were classified as delayed.
* **75 shipments (3.84%)** were still in transit.
* **45 shipments (2.31%)** were lost.
* **31 shipments (1.59%)** were returned.

### Carrier Performance

Delay rates varied across carriers:

* **DHL:** 13.87%
* **Amazon Logistics:** 12.27%
* **OnTrac:** 9.59%
* **UPS:** 8.91%
* **LaserShip:** 8.75%
* **FedEx:** 8.28%
* **USPS:** 7.07%

### Warehouse Performance

Warehouse delay rates also varied:

* **HOU:** 12.14%
* **NYC:** 6.02%

### Shipping Cost

Shipping costs varied by delivery status. Among shipments with available cost data:

* **Delivered:** $208.84 average cost
* **Delayed:** $200.00 average cost
* **Returned:** $196.82 average cost
* **Lost:** $175.32 average cost
* **In Transit:** $169.21 average cost

The dataset contained 39 shipments with missing cost values, including 34 delivered shipments and 5 delayed shipments.
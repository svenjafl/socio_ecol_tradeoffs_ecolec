# socio_ecol_tradeoffs_ecolec
This is the replication package for the article "Income inequality and the trade-off between socio-economic and ecological goals" by S. Flechtner and M. Middelanis, published in Ecological Economics (2026). doi: 10.1016/j.ecolecon.2026.109100

Create a folder structure as follows. The main folder is called "replication_package", the remaining folders are (sub)subfolders.

Replication_package
> Code

> Data
>> wid_all_data 

> Results

The raw data files need to be downloaded from the original sources and stored in the data folder as indicated in the data preparation code. The do-files must run in the order indicated in the Master do-file:

- fanning_2022.do
- fanning_countrytrends.do
- wid_dataprep.do
- codepath/data_preparation.do

The files jointly create the dataset that we use in the analysis: "$datapath/dataset_cross-sectional.dta". Should you experience difficulties in reproducing this dataset, contact us and we may be able to share it. We cannot share it publicly because this would imply sharing raw data that we do not own. 

The analysis runs from the code "$codepath/analysis.do", which contains the main analysis and all robustness checks.

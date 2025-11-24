# NSSO-India-Agricultural-Indicators-Code

This repository includes Stata do.files developed by the Evans School Policy Analysis & Research Group (EPAR) for the construction of a set of agricultural development indicators using data from the World Bank's Living Standards Measurement Study - Integrated Surveys on Agriculture (LSMS-ISA) surveys and produced in partnership with the host countries' national statistics bureaus. 

If you use or modify our code, please cite us using the provided citation in the header of the do file.

This repository includes a separate folder for each country. Each of these folders includes master Stata .do files with all of the code used to generate the final set of indicators from the raw survey data for a given survey wave. See the USER GUIDE file in this repository for guidance on how to download the files in this repository and raw data available from the World Bank in order to run the .do files.

Each .do file takes as inputs the raw data files organized according to how the data from the World Bank LSMS-ISA team are organized. The .do files process the raw data and store created data sets in the folder "Final DTA files". Three final data sets are created at the household, individual, and plot levels with labeled variables, which can be used to estimate sumary statistics for the indicators and for a variety of intermediate variables. At the end of the .do file, a set of commands outputs summary statistics restricted to rural households only to an excel file also in the folder "Final DTA files". The code for generating summary statistics may be modified as needed, or users may conduct analyses directly from the final created datasets. We include the three final datasets and spreadsheet of gender-disaggregated summary statistics in the repository, under the "Final DTA files" folder.

In addition to project leads C. Leigh Anderson and Federico Trinidade, we gratefully acknowledge the following contributors: Vanisha Sharma and Ahana Raina.

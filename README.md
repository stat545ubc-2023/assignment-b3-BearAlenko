# Worst Level Distribution by Diagnosis Data Analysis Dashboards (B4)


## App link:
The link to the running Shiny app of my dashboard is:
https://zzh2015.shinyapps.io/B4CancerAnalysis/

## Assignment option and dataset:
* My choice is Option C with a new app - my own Shiny app of cancer worst level.
* Dataset: cancer sample from [datateachr package](https://github.com/UBC-MDS/datateachr).

## File location:
The code and the image are in /B4.
* CancerAnalysisApp.R: the main code of the shiny app.
* www/cancer-icon-2797418_1280.png: the cancer image used in app.
* archive/: the old files of B3.

## Description:
_This app analyzes the cancer sample data by analyzing the worst levels._
It has many functions:
1. It illustrates three outputs:
     * a **box and jitter plot** of worst values by diagnosis.
     * a **summarize table** grouped by diagnosis and worst levels. 
     * an **interactive data table** of the full result data.
2. A **slider input** to select the number of worst levels in data. By this function, we can see different plots and data.
3. A **check box input** to show the legend in the plot. Sometimes, we want to turn on the legend to see the worst level distribution and turn off to see the box clearly.
4. A **cancer image** to make our dashboard more interesting and to align with the data frame "cancer_sample".
5. **Separating tabs**. Because I have two tables and one plot, separating tabs to show them **makes the dashboard clear and pretty**.
6. **Interactive table** can help users to choose how many data entries to show in a page and sort on different variables.
7. A **download button** for downloading the result table.

## Methods
1. I first cut the worst radius and the worst concavity into four
categories so that we can combine them together as one dimension **“worst level”** for easy diagnosis. The resulted worst_level has dxd categories where d is the chosen number of levels by users. By combining the two level variables, we can simulate an easy model for pre-diagnosis, for example, self diagnosis before seeing a doctor. 
2. I also calculate **"worst value"**, the sum of normalized worst concavity and worst radius, as a representation of numeric worst level for plotting.


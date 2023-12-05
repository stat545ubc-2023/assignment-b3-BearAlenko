library(shiny)
library(datateachr)
library(ggplot2)
library(dplyr)
library(DT)
library(colourpicker)

## This app analyzes the cancer data to see how the diagnosis is related to the worst level/value.
## It has many functions:
## 1. It illustrates three outputs (containing one interactive table):
##      a box and jitter plot of worst values by diagnosis,
##      a summarize table grouped by diagnosis and worst levels, 
##      and a full data table
## 2. A slider input to select the number of worst levels in data. By this function, we can see different plots and data.
## 3. A check box input to show the legend in the plot. Sometimes, we want to turn on the legend to see the worst level distribution and turn off to see the box clearly.
## 4. A cancer image to make our dashboard more interesting and to align with the data frame "cancer_sample".
## 5. Separating tabs. Because I have two tables and one plot, separating tabs to show them makes the dashboard clear.
## 6. A download button for downloading the result table.
## 7. A color chooser for changing the color of boxes in the box plot.
## 8. A text output to show the rows of the summarise table. 
ui <- fluidPage(
  titlePanel("Worst Level Distribution by Diagnosis Data Analysis Dashboards"),
  sidebarLayout(
    sidebarPanel(
      # the slider input of the number of worst levels
      sliderInput("num", "Select how many intervals to cut the worst radius and worst concavity",
                  min = 3,
                  max = 10,
                  value = 4),
      # allow the user to turn on/off the legend
      checkboxInput("show_legend", "Check to show legend", value = TRUE),
      
      # allow the user to choose the color of box
      colourInput("col", "Choose the color of boxes", "black"),
      
      # download button
      downloadButton("download", label = "Download"),
      # add a cancer image to UI
      img(src = "cancer-icon-2797418_1280.png", align = "center", height = 100, width = 100)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("myplot")), # the output plot of box plot
        tabPanel("Summarise", textOutput("show_nrows"), tableOutput("mytable_summarise")), # the output summarise table
        tabPanel("Table", dataTableOutput("mytable")) #the full result table output
      )
    )
  )
)
server <- function(input, output){
  # reactive data
  num_input <- reactive({input$num}) 
  show_leg <- reactive({input$show_legend})
  col_input <- reactive({input$col})
  
  #Output Worst Value Table:
  #Cut worst radius and worst concavity into intervals and add/concatenate them together.
  #After combining the two intervals, we can see the distribution by diagnosis
  cancer_worst_radius_concavity <- reactive({cancer_sample %>%
      mutate(radius_worst_level = cut_interval(radius_worst, num_input(), labels = 1:num_input()), 
             concavity_worst_level = cut_interval(concavity_worst, num_input(), labels = 1:num_input())) %>% # cut the worst radius and concavity into intervals
      mutate(worst_level = paste0(as.character(radius_worst_level)," ", as.character(concavity_worst_level)), 
             worst_value = scale(radius_worst)+scale(concavity_worst)) %>%
      select(diagnosis, worst_level, worst_value, radius_worst, concavity_worst)})
  
  # plot output
  output$myplot <- renderPlot({
    cur_table <- cancer_worst_radius_concavity()
    if (show_leg()){
      cur_table %>%
        ggplot(aes(x = diagnosis, y = worst_value)) +
        geom_boxplot(color = col_input())+ # the box plot of worst value by diagnosis
        geom_jitter(aes(color = worst_level), alpha = 0.3)+ # add jitter to show the distribution of worst level
        ggtitle("The boxplot of worst value by diagnosis")+
        xlab("diagnosis")+
        ylab("worst value")
    }
    else{
      cur_table %>%
        ggplot(aes(x = diagnosis, y = worst_value)) +
        geom_boxplot(color = col_input())+ # the box plot of worst value by diagnosis
        geom_jitter(alpha = 0.3)+ # add jitter to show the distribution of worst level
        ggtitle("The boxplot of worst value by diagnosis")+
        xlab("diagnosis")+
        ylab("worst value")
    }
  })
  
  # summarise output
  output$mytable_summarise <- renderTable({
    cur_table <- cancer_worst_radius_concavity()
    cur_table %>%
      group_by(diagnosis, worst_level) %>%
      summarise(counts = n()) %>% # calculate the counts of each worst concavity level
      mutate(proportion = counts / sum(counts)) # calculate the proportion of each worst concavity level
  })
  
  # print the number of rows for current number of levels
  output$show_nrows <- renderText({
    cur_table <- cancer_worst_radius_concavity()
    n <- cur_table %>%
      group_by(diagnosis, worst_level) %>%
      summarise(counts = n()) %>% # calculate the counts of each worst concavity level
      ungroup() %>%
      nrow()# calculate the number of rows
    paste("The current rows of the summarised table is:", n, sep = " ")
  })
  
  # full table output
  output$mytable <- renderDataTable({ ## out put the entire table in tab three
    cancer_worst_radius_concavity()
  })
  
  # download output
  output$download <- downloadHandler(
    filename = function(){
      paste("table_", Sys.Date(), ".csv", sep="")
    },
    content = function(file){
      write.csv(cancer_worst_radius_concavity(), file)
    }
  )
}
shinyApp(ui = ui, server = server)


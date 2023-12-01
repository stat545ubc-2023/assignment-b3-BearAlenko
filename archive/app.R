library(shiny)
library(palmerpenguins)
library(ggplot2)
library(dplyr)
library(DT)

## This app analyzes the palmerpenguins data.
## It has many functions:
## 1. It illustrates three outputs:
##      a box plot of flipper length by species,
##      a summarize table grouped by species and islands, 
##      and a full data table
## 2. A slider input to select the max bill length in data. By this function, we can see different plots and data in different subsets of bill length.
## 3. A check box input to sort the table by islands. Sometimes, we want to compare the data on the same island and the sorted table is more clear to compare on this.
## 4. A penguin image to make our dashboard more interesting and to align with the data frame "palmerpenguins".
## 5. Separating tabs. Because I have two tables and one plot, separating tabs to show them makes the dashboard clear.
ui <- fluidPage(
  titlePanel("Penguins Data Analysis Dashboards"),
  sidebarLayout(
    sidebarPanel(
      # the slider input for table and plot to filter the penguins with bill length less than the input
      sliderInput("num", "show penguins with bill length less than",
                  min = min(penguins$bill_length_mm, na.rm = TRUE),
                  max = max(penguins$bill_length_mm, na.rm = TRUE),
                  value = 50),
      # allow the user to sort the data in summarised table by "island"
      checkboxInput("sort", "sort table by the island"),
      # add a penguin image to UI
      img(src = "penguins.png", align = "center", height = 100, width = 100)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("myplot")), # the output plot of box plot
        tabPanel("Summarise", tableOutput("mytable_summarise")), # the output summarise table
        tabPanel("Table", dataTableOutput("mytable")) #plotOutput, textOutput, uiOutput, tableOutput
      )
    )
  )
)
server <- function(input, output){
  # reactive data
  num_input <- reactive({input$num}) 
  output_table <- reactive({penguins %>% filter(bill_length_mm <= num_input())})
  
  # plot output
  output$myplot <- renderPlot({
    penguins %>%
      filter(bill_length_mm <= num_input()) %>% ## show the data with bill length <= input
      ggplot(aes(x = species, y = flipper_length_mm))+  ## the ggplot to plot box and jitter
      geom_boxplot(aes(color = species))+
      geom_jitter(aes(color = island))
  })
  
  # summarise output
  output$mytable_summarise <- renderTable({
    if(input$sort){ ## if the check box is selected, then sort otherwiese unsort
      penguins %>%
        filter(bill_length_mm <= input$num) %>% ## same as the plot
        group_by(species, island) %>% ## group and summarise the data
        summarise(count = n(), 
                  mean_bill_length = mean(bill_length_mm, na.rm = TRUE), 
                  mean_flipper_length = mean(flipper_length_mm, na.rm = TRUE)) %>%
        arrange(island)
    }
    else {
      penguins %>%
        filter(bill_length_mm <= input$num) %>%
        group_by(species, island) %>%
        summarise(count = n(), 
                  mean_bill_length = mean(bill_length_mm, na.rm = TRUE), 
                  mean_flipper_length = mean(flipper_length_mm, na.rm = TRUE))
    }
  })
  
  # full table output
  output$mytable <- renderDataTable({ ## out put the entire table in tab three
    if(input$sort) output_table() %>% arrange(island)
    else output_table()
  })
  
}
shinyApp(ui = ui, server = server)


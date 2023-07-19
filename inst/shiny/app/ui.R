# ui.R

library(shiny)

# To label inputs, the section title is give first, followed by the section parameter
# i.e. hwe_p

# Initialize the layout with a navbar
fluidPage(
  
  ## Just one page - generate randomization
  
  # Title 
  titlePanel("Experimental design randomization generator"),
  
  # Create a sidebar panel
  sidebarLayout(
    
    # Panel for the side bar
    sidebarPanel(
      
      ## Input - select design type (i.e. RCBD or AIBD)
      radioButtons("des", "Design Type", choices = c("RCBD", "AIBD"), selected = "RCBD"),
      
      ## Zurn seed
      selectInput(inputId = "zurn",
                  label = "Zurn crop code:",
                  choices = c("3 - barley", "5 - oat")),
      
      ## Input - location
      textInput(inputId = "loc",
                label = "Location name:"),
      
      numericInput(inputId = "loc.id",
                   label = "Location code:",
                   value = 1),
      
      ## Input - experiment
      textInput(inputId = "exp",
                label = "Trial name:"),
      
      ## Input - experiment code
      numericInput(inputId = "exp.id",
                   label = "Trial code:",
                   value = 1),
      
      
      
      ## Input - number of rows, blocks, etc.
      numericInput(inputId = "plot.start",
                   label = "Starting plot number:",
                   value = 1001),
      
      numericInput(inputId = "rows",
                   label = "Number of beds/field rows:",
                   value = 10),
      
      numericInput(inputId = "year",
                   label = "Experiment year:",
                   value = format(Sys.Date(), "%Y")),
      
      ## Conditional panel with number of blocks
      conditionalPanel(
        condition = "input.des == 'RCBD'",
        numericInput(inputId = "blk_rcbd",
                     label = "Number of complete blocks (i.e. reps):",
                     value = 3)
      ),
      
      conditionalPanel(
        condition = "input.des == 'AIBD'",
        numericInput(inputId = "blk_aibd",
                     label = "Minimum number of incomplete blocks:",
                     value = 10)
      ),
      
      
      
      ## Conditional panel with number of checks
      conditionalPanel(
        condition = "input.des == 'RCBD'",
        
        # Input - check reps (RCBD)
        numericInput(inputId = "check.rep",
                     label = "Number of check replicates:",
                     value = 1)
      ),
      
      
      ## Conditional panel with number of checks
      conditionalPanel(
        condition = "input.des == 'AIBD'",
        
        ## Input - check 2 reps (AIBD)
        numericInput(inputId = "check2.rep",
                     label = "Number of secondary check replicates:",
                     value = 1)
      ),
      
      
      ## Input - fill with
      selectInput(inputId = "fillWith",
                  label = "Fill extra plots with...",
                  choices = c("check", "entry", "filler", "custom")),
      
      ## Conditional panel with custom fill
      conditionalPanel(
        condition = "input.fillWith == 'custom'",
        # If custon, requre input
        textInput(inputId = "fill.with.custom",
                  label = "Custom fill:")
      ),
      
      
      ## Horizontal line
      tags$hr(),
      
      # Help text
      helpText("Upload one file for entries and (optionally) one file for checks. Each file should be a CSV file with one column; the header of this column should be 'line'."),
      
      ## Uploading files
      
      # Download an example.
      downloadLink(outputId = "downloadEntryExample", 
                   label = "Download example entry file"),
      # Entries
      fileInput(inputId = "entry", 
                label = "Choose CSV file for entries:",
                multiple = FALSE, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      
      # Download an example.
      downloadLink(outputId = "downloadCheckExample", 
                   label = "Download example check file"),
      # Checks
      fileInput("checks", "Choose CSV file for checks:",
                multiple = FALSE, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      
      
      ## Horizontal line
      tags$hr(),
      
      ## Creation button
      actionButton(inputId = "create", label = "Create Randomization"),
      
      tags$p(),
      
      
      ## Download button - this will depend on the above data being passed
      downloadButton(outputId = "downloadData", label = "Save randomization file")
      
      
    ),
    
    ## Main panel for output
    mainPanel( 
      
      # Title
      h3("Visualization of trial:"),
      ## Plot with colors assigned to checks, entries, and filler
      plotOutput("entry_plot"),
      
      
      # Summary
      h3("Trial summary:"),
      verbatimTextOutput("summ"),
      
      # Tabset panel for the three data book outputs
      h3("Data book preview:"),
      tabsetPanel(
        type = "tabs",
        tabPanel("Data book", tableOutput("data_head")),
        tabPanel("Field map", tableOutput("map_head")),
        tabPanel("Rep book", tableOutput("rep_head"))
      )
      
    )
    
  )
  
) # Close the page

## End of UI
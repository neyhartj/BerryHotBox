# server.R

library(shiny)
library(writexl)

# Load the source script
source("source.R")


shinyServer(function(input, output) {
  
  design_rand <- eventReactive(eventExpr = input$create, valueExpr = {
    
    # Create an AIBD or RCBD design
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, the RCBD or AIBD design will be generated
    
    req(input$entry)
    
    ## Save the other inputs
    loc.to.use <- input$loc
    loc.id <- input$loc.id
    plot.start <- input$plot.start
    trial <- input$exp
    trial.id <- input$exp.id
    zurn.seed <- substr(x = input$zurn, start = 1, stop = 1)
    rows <- input$rows
    year <- input$year
    block_rcbd <- input$blk_rcbd
    block_aibd <- input$blk_aibd
    fill.with <- input$fillWith
    
    ## These will depend on other inputs
    check2.rep <- input$check2.rep
    check.rep <- input$check.rep
    fill.with.custom <- input$fill.with.custom
    
    ## The design
    design <- input$des
    
    # Determine the fill
    fill.with.use <- if (fill.with == "custom") fill.with.custom else fill.with
    
    ## Create the specified design
    if (design == "RCBD") {
      
      rand <- design_rcbd(location = loc.to.use, location.id = loc.id, trial = trial, trial.id = trial.id, plot.start = plot.start, 
                          number.blocks = block_rcbd, number.rows = rows, year = year, crop.id = zurn.seed, fill.with = fill.with.use, 
                          number.reps.chk = check.rep, entries = input$entry$datapath, checks = input$checks$datapath, write.excel = FALSE)
      
    } else {
      
      rand <- design_aibd(location = loc.to.use, location.id = loc.id, trial = trial, trial.id = trial.id, plot.start = plot.start, 
                          minimum.blocks = block_aibd, number.rows = rows, year = year, crop.id = zurn.seed, 
                          chk2rep = check2.rep, fill.with = fill.with.use, entries = input$entry$datapath,
                          checks = input$checks$datapath, write.excel = FALSE)
      
    }
    
    # Return the randomization
    rand
    
  })
  
  
  ## Plot
  output$entry_plot <- renderPlot({
    plot(design_rand())
  })
  
  ## Summarize
  output$summ <- renderPrint({
    summary.exp.design(x = design_rand())
  })
  
  # First few lines of the data book, map, and rep book
  output$data_head <- renderTable({
    design_rand()$data.book
  })
  
  output$map_head <- renderTable({
    design_rand()$map.to.print
  })
  
  output$rep_head <- renderTable({
    design_rand()$rep.book
  })
  
  
  
  # Download examples
  output$downloadEntryExample <- downloadHandler(
    filename = "entry_example.csv", 
    content = function(file) {
      fl <- read.csv(file = "pyt_entry.csv", header = TRUE)
      write.csv(x = fl, file = file, quote = FALSE, row.names = FALSE)
    }
  )
  
  output$downloadCheckExample <- downloadHandler(
    filename = "check_example.csv", 
    content = function(file) {
      fl <- read.csv(file = "pyt_chk.csv", header = TRUE)
      write.csv(x = fl, file = file, quote = FALSE, row.names = FALSE)
    } 
  )
  
  
  ## Separate server for downloading the data
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    
    filename = function() {
      filename <- paste0(design_rand()$data.book$trial[1], "_", tail(class(design_rand()), 1), "_rand.xlsx")
    }, 
    
    content = function(file) {
      dsg <- design_rand()
      dsg <- dsg[sapply(dsg, is.data.frame)]
      writexl::write_xlsx(x = dsg, path = file)
    }, 
    
    contentType = "text/xlsx"
    
  )
  
})


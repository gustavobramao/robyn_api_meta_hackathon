library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyvalidate)

# source("demo/allocator.R")
# OUTPUT_FILE_PATH <- "/Users/cto/webapps/central/Robyn-main_final/outpout/"
OUTPUT_FILE_PATH <- "~/Desktop/Robyn-main_final/outpout/"
source("/Users/gustavobramao/Desktop/Robyn-main_final/demo/shiny_allocator.R")

SELECT_MODEL <- "1_319_2"

body <- dashboardBody(shinyjs::useShinyjs(), uiOutput("body"))
header <- dashboardHeader(title = "Predictive Allocator")

sidebar <- dashboardSidebar(
  width = "0px"
)

ui <- dashboardPage(
  title = 'MMM Predictive Allocator',
  header,
  sidebar,
  body, skin = 'black'
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  shinyjs::runjs("document.getElementsByClassName('sidebar-toggle')[0].style.visibility = 'hidden';")

  output$body <- renderUI({
    sidebarLayout(
      sidebarPanel(
        fluidRow(
          column(width = 4,
                 numericInput("expected_spend", "expected_spend", 7000000)
          ),
          column(width = 4,
                 numericInput("expected_spend_days", "expected_spend_days", 7)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("affiliates_S_low", "affiliates_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("affiliates_S_high", "affiliates_S_high", 1.2)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("sho_S_low", "sho_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("sho_S_high", "sho_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("rmk_S_low", "rmk_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("rmk_S_high", "rmk_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("sem_non_brand_S_low", "sem_non_brand_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("sem_non_brand_S_high", "sem_non_brand_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("fb_bau_S_low", "fb_bau_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("fb_bau_S_high", "fb_bau_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("fb_are_S_low", "fb_are_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("fb_are_S_high", "fb_are_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("fb_ins_S_low", "fb_ins_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("fb_ins_S_high", "fb_ins_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("google_uac_ins_S_low", "google_uac_ins_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("google_uac_ins_S_high", "google_uac_ins_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("tiktok_S_low", "tiktok_S_low", 0.7)

          ),
          column(width = 4,
                 numericInput("tiktok_S_high", "tiktok_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("fb_S_low", "fb_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("fb_S_high", "fb_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("fb_branding_S_low", "fb_branding_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("fb_branding_S_high", "fb_branding_S_high", 1.5)
          )
        ),
        fluidRow(
          column(width = 4,
                 numericInput("google_branding_S_low", "google_branding_S_low", 0.7)
          ),
          column(width = 4,
                 numericInput("google_branding_S_high", "google_branding_S_high", 1.5)
          ),
        ),
        fluidRow(
          column(width = 4),
          actionButton("run_mmm_allocation", "Run MMM Allocator", class = "btn btn-success",
                       align = "center", style='width:100%; font-size:150%;')
        ), width=4),

      # Show a plot of the generated distribution
      mainPanel(
        tabsetPanel(
          id = 'dataset',
          tabPanel("Allocator Graph", imageOutput("reallocator_call")),
          tabPanel("Allocator Table", DT::dataTableOutput("reallocator_table"))
        ),
        width=8
      )
    )
  })

  sv_numeric_only <- sv_numeric( message = "A number is required",
                                 allow_multiple = FALSE,
                                 allow_na = FALSE,
                                 allow_nan = FALSE,
                                 allow_inf = FALSE)

  iv <- InputValidator$new()
  iv$add_rule("expected_spend", sv_numeric_only)
  iv$add_rule("expected_spend_days", sv_numeric_only)
  iv$add_rule("affiliates_S_low", sv_numeric_only)
  iv$add_rule("affiliates_S_high", sv_numeric_only)
  iv$add_rule("sho_S_low", sv_numeric_only)
  iv$add_rule("sho_S_high", sv_numeric_only)
  iv$add_rule("rmk_S_low", sv_numeric_only)
  iv$add_rule("rmk_S_high", sv_numeric_only)
  iv$add_rule("sem_non_brand_S_low", sv_numeric_only)
  iv$add_rule("sem_non_brand_S_high", sv_numeric_only)
  iv$add_rule("fb_bau_S_low", sv_numeric_only)
  iv$add_rule("fb_bau_S_high", sv_numeric_only)
  iv$add_rule("fb_are_S_low", sv_numeric_only)
  iv$add_rule("fb_are_S_high", sv_numeric_only)
  iv$add_rule("fb_ins_S_low", sv_numeric_only)
  iv$add_rule("fb_ins_S_high", sv_numeric_only)
  iv$add_rule("google_uac_ins_S_low", sv_numeric_only)
  iv$add_rule("google_uac_ins_S_high", sv_numeric_only)
  iv$add_rule("tiktok_S_low", sv_numeric_only)
  iv$add_rule("tiktok_S_high", sv_numeric_only)
  iv$add_rule("fb_S_low", sv_numeric_only)
  iv$add_rule("fb_S_high", sv_numeric_only)
  iv$add_rule("fb_branding_S_low", sv_numeric_only)
  iv$add_rule("fb_branding_S_high", sv_numeric_only)
  iv$add_rule("google_branding_S_low", sv_numeric_only)
  iv$add_rule("google_branding_S_high", sv_numeric_only)

  iv$enable()

  output$reallocator_table <- DT::renderDataTable({
    bu_data <- read.csv(paste0(OUTPUT_FILE_PATH, "robyn_allocator.csv"),
                        stringsAsFactors = F, header = T)
    DT::datatable( bu_data, options = list(orderClasses = TRUE, scrollX='100px'))
  })

  mmm_output <- eventReactive(input$run_mmm_allocation, {
    # shinyjs::toggle(id= "run_mmm_allocation")

    channel_constr_low <- c(
      as.numeric(input$affiliates_S_low), input$sho_S_low, input$rmk_S_low, input$sem_non_brand_S_low,
      input$fb_bau_S_low, input$fb_are_S_low, input$fb_ins_S_low, input$google_uac_ins_S_low,
      input$tiktok_S_low, input$fb_S_low, input$fb_branding_S_low, input$google_branding_S_low
    )

    channel_constr_up <- c(
      input$affiliates_S_high, input$sho_S_high, input$rmk_S_high, input$sem_non_brand_S_high,
      input$fb_bau_S_high, input$fb_are_S_high, input$fb_ins_S_high, input$google_uac_ins_S_high,
      input$tiktok_S_high, input$fb_S_high, input$fb_branding_S_high, input$google_branding_S_high
    )

    robyn_object <- paste0(OUTPUT_FILE_PATH, "Robyn.RDS")
    plot_folder <- paste0(OUTPUT_FILE_PATH, "2021-11-23 08.07 rf1/")

    expected_spend <- as.numeric(input$expected_spend)
    expected_spend_days <- as.numeric(input$expected_spend_days)

    get_robyn_allocator(
      robyn_object=robyn_object, plot_folder=plot_folder, select_model=SELECT_MODEL, channel_constr_low=channel_constr_low,
      channel_constr_up=channel_constr_up, expected_spend=expected_spend, expected_spend_days=expected_spend_days
    )

    # Sys.sleep(2)
  })

  output$reallocator_call <- renderImage({
    mmm_output()
    # shinyjs::toggle(id= "run_mmm_allocation")

    filename <- normalizePath(paste0(OUTPUT_FILE_PATH, "2021-11-23 08.07 rf1/",SELECT_MODEL, "_reallocated.png"))

    # Return a list containing the filename and alt text
    list(src = filename,
         width = '100%',
         height = '270%',
         alt = "Reallocated Output")

  }, deleteFile = TRUE
  )
}

# Run the application
options(shiny.port = 7776)
shinyApp(ui = ui, server = server)

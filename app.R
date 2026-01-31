# 1. Load dependent packages (remove fastshap, keep core packages only)
install.packages(c("shiny", "randomForest", "dplyr", "ggplot2", "readr"))
library(shiny)
library(randomForest)
library(dplyr)
library(ggplot2)
library(readr)


data <- read_csv("C:/Users/c7970/Desktop/sample_data.csv", show_col_types = FALSE)

target_var <- "Hernia"  # Dependent variable: Hernia (ensure this column is 0/1 or binary factor)
feature_vars <- setdiff(colnames(data), target_var)  # Independent variables: risk factors

# Data cleaning: handle missing values + variable type adaptation
for (var in feature_vars) {
  if (is.numeric(data[[var]])) {
    # Continuous variables: fill with mean
    data[[var]] <- ifelse(is.na(data[[var]]), mean(data[[var]], na.rm = TRUE), data[[var]])
  } else {
    # Categorical variables: fill with mode + convert to factor
    mode_val <- names(sort(table(data[[var]], useNA = "no"), decreasing = TRUE))[1]
    data[[var]] <- ifelse(is.na(data[[var]]), mode_val, data[[var]])
    data[[var]] <- as.factor(data[[var]])
  }
}
# Convert target variable to factor (ensure normal training of classification model)
data[[target_var]] <- as.factor(data[[target_var]])

# Distinguish continuous/categorical variables (for UI control generation)
cont_vars <- feature_vars[sapply(data[feature_vars], is.numeric)]
cat_vars <- feature_vars[sapply(data[feature_vars], is.factor)]

# Train RF model (fix random seed for reproducibility)
set.seed(123)
rf_model <- randomForest(
  formula = as.formula(paste(target_var, "~", paste(feature_vars, collapse = " + "))),
  data = data,
  ntree = 500,
  mtry = floor(sqrt(length(feature_vars))),
  importance = TRUE,
  na.action = na.omit
)

# Save model parameters (for UI adaptation and input data validation)
model_params <- list(
  cont_ranges = lapply(cont_vars, function(var) c(min = min(data[[var]]), max = max(data[[var]]))),
  cat_levels = lapply(cat_vars, function(var) levels(data[[var]]))
)
names(model_params$cont_ranges) <- cont_vars
names(model_params$cat_levels) <- cat_vars

# 3. Shiny UI design (remove SHAP contribution plot related display area)
ui <- fluidPage(
  titlePanel("Hernia Risk Nonlinear Prediction Calculator (RF Model)"),
  sidebarLayout(
    sidebarPanel(
      width = 4,
      h4("Patient Risk Factor Input"),
      hr(),
      
      # Dynamically generate sliders for continuous variables (adapt to data range)
      lapply(cont_vars, function(var) {
        sliderInput(
          inputId = paste0("cont_", var),
          label = paste(var, "(Range: ", round(model_params$cont_ranges[[var]]["min"], 1), "-", 
                        round(model_params$cont_ranges[[var]]["max"], 1), ")"),
          min = model_params$cont_ranges[[var]]["min"],
          max = model_params$cont_ranges[[var]]["max"],
          value = round(mean(c(model_params$cont_ranges[[var]]["min"], 
                               model_params$cont_ranges[[var]]["max"])), 1),
          step = ifelse((model_params$cont_ranges[[var]]["max"] - model_params$cont_ranges[[var]]["min"]) > 10, 1, 0.1)
        )
      }),
      
      # Dynamically generate dropdowns for categorical variables (adapt to data levels)
      lapply(cat_vars, function(var) {
        selectInput(
          inputId = paste0("cat_", var),
          label = var,
          choices = model_params$cat_levels[[var]],
          selected = model_params$cat_levels[[var]][1]
        )
      }),
      
      hr(),
      actionButton("predict_btn", "Calculate Hernia Risk", class = "btn-primary", style = "width:100%")
    ),
    
    mainPanel(
      width = 8,
      h3("Prediction Results"),
      hr(),
      
      # Risk probability and stratification
      fluidRow(
        column(6, verbatimTextOutput("risk_prob"), verbatimTextOutput("risk_level")),
        column(6, h4("Clinical Recommendations"), textOutput("clinical_advice"), 
               style = "background:#f8f9fa; padding:15px; border-radius:8px;")
      ),
      
      hr(),
      # Model information
      h5("Model Information"),
      textOutput("model_info")
    )
  )
)

# 4. Shiny Server logic (remove all SHAP value calculation and visualization code)
server <- function(input, output) {
  observeEvent(input$predict_btn, {
    # Step 1: Collect user input and organize into model-recognizable format
    input_data <- data.frame(matrix(nrow = 1, ncol = length(feature_vars)))
    colnames(input_data) <- feature_vars
    
    # Fill continuous variables
    for (var in cont_vars) {
      input_data[[var]] <- as.numeric(input[[paste0("cont_", var)]])
    }
    
    # Fill categorical variables (ensure factor levels match training data)
    for (var in cat_vars) {
      input_data[[var]] <- factor(input[[paste0("cat_", var)]], 
                                  levels = model_params$cat_levels[[var]])
    }
    
    # Step 2: RF model nonlinear prediction (hernia occurrence probability)
    hernia_prob <- predict(rf_model, newdata = input_data, type = "prob")[, "1"]
    hernia_prob_percent <- round(hernia_prob * 100, 2)
    
    # Step 3: Output risk results
    output$risk_prob <- renderPrint({
      cat("Hernia Occurrence Probability: ", hernia_prob_percent, "%\n", sep = "")
    })
    
    output$risk_level <- renderPrint({
      risk_cat <- case_when(
        hernia_prob_percent < 20 ~ "Low Risk (<20%)",
        hernia_prob_percent < 40 ~ "Low-Medium Risk (20%-40%)",
        hernia_prob_percent < 60 ~ "Medium-High Risk (40%-60%)",
        hernia_prob_percent < 80 ~ "High Risk (60%-80%)",
        TRUE ~ "Very High Risk (≥80%)"
      )
      cat("Risk Stratification: ", risk_cat, "\n", sep = "")
    })
    
    # Step 4: Output clinical recommendations
    output$clinical_advice <- renderText({
      case_when(
        hernia_prob_percent < 20 ~ "Recommendation: Maintain current regimen, regular follow-up every 6 months.",
        hernia_prob_percent < 40 ~ "Recommendation: Control abdominal pressure-increasing behaviors (e.g., constipation, severe cough), follow-up every 3-4 months.",
        hernia_prob_percent < 60 ~ "Recommendation: Complete abdominal ultrasound examination, evaluate feasibility of dialysis mode adjustment, follow-up every month.",
        hernia_prob_percent < 80 ~ "Recommendation: Surgical consultation to assess intervention timing, strictly limit heavy physical activity, follow-up every week.",
        TRUE ~ "Recommendation: Urgent surgical evaluation, closely monitor abdominal pain/distension symptoms, intervene if necessary."
      )
    })
    
    # Step 5: Output model information
    output$model_info <- renderText({
      paste0(
        "Model Type: Random Forest (Nonlinear Classification); Number of Training Samples: ", nrow(data), "; ",
        "Number of Risk Factors: ", length(feature_vars), "; Model OOB Error: ", 
        round(rf_model$err.rate[nrow(rf_model$err.rate), "OOB"] * 100, 1), "% (Lower is better)."
      )
    })
  })
}

# 5. Start Shiny application (local webpage pops up automatically)
shinyApp(ui = ui, server = server)


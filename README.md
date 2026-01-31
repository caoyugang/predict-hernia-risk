# Hernia Risk Prediction Tool
An interactive hernia risk prediction calculator based on Random Forest (RF) algorithm and Shiny framework, developed for academic peer review.

## Quick Access (No Local Installation Required)
Click the Binder badge below to launch the tool directly in your browser:
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/caoyugang/hernia-risk-prediction/main?urlpath=shiny/app.R)

## How to Use
1. After clicking the Binder badge, wait 1-2 minutes for the environment to build (first launch may take longer).
2. In the input panel: Enter patient risk factors (continuous variables via sliders, categorical variables via dropdowns).
3. Click the "Calculate Hernia Risk" button to view results:
   - Hernia occurrence probability (percentage)
   - Risk stratification (Low/ Low-Medium/ Medium-High/ High/ Very High)
   - Standardized clinical recommendations

## Repository File Structure
| Filename          | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `app.R`           | Core Shiny application code (full English version, no Chinese display)      |
| `sample_data.csv` | Desensitized sample data (no patient privacy information, for tool testing) |
| `install.R`       | R package installation script (for Binder environment building)             |
| `runtime.txt`     | R version specification (avoids compatibility errors like `ffi_list2`)      |
| `README.md`       | Academic documentation (for reviewers and platform recognition)              |

## Data and Ethics
- **Data**: All data used in the tool are desensitized simulated data (no real patient information), complying with privacy protection regulations.
- **Ethical Approval**: Approved by [Institutional Ethics Committee of Huangshi Central Hospital], Approval No.: Lun_ Kuai_Shen [2025]-48").

## Technical Details
- Core Algorithm: Random Forest (500 trees, mtry = floor(sqrt(number of features)))
- Dependencies: shiny, randomForest, dplyr, ggplot2, caret, readr
- R Version: R 4.2.2 (specified in `runtime.txt` as `r-2023-01-01`)
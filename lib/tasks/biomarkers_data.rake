namespace :biomarkers_data do
  desc "Create or update biomarkers"
  task create_or_update_biomarkers: :environment do
    # Biomarkers
    biomarker_categories = [
      {
        "name": "Blood Health",
        "description": "",
        "subcategories": [
          {
            "name": "Iron",
            "description": "",
            "biomarkers": [
              {
                "name": "Ferritin",
                "description": "Iron storage protein",
                "unit": "ng/mL",
                "alternative_names": [
                  "Ferritin, Serum",
                  "Ferritin (serum)",
                  "Serum Ferritin",
                  "Blood Ferritin",
                ]
              },
              {
                "name": "Iron (serum)",
                "description": "Iron in liquid part of blood",
                "unit": "ug/dL",
                "alternative_names": [
                  "Iron, Serum",
                  "Iron",
                  "Serum Iron",
                  "Blood Iron",
                  "Iron, Total"
                ]
              },
              {
                "name": "Iron Saturation",
                "description": "The percent of Iron transport protein bound to Iron",
                "unit": "%",
                "alternative_names": []
              },
              {
                "name": "Total Iron Binding Capacity",
                "description": "Estimates transferrin level",
                "unit": "ug/dL",
                "alternative_names": [
                  "Iron Binding Capacity",
                  "Iron Bind.Cap.(TIBC)",
                  "TIBC",
                  "Total Iron Binding Capacity (TIBC)",
                ]
              },
              {
                "name": "Unsaturated Iron Binding Capacity",
                "description": "Reserve capacity of transferrin",
                "unit": "ug/dL",
                "alternative_names": [
                  "Unsaturated Iron Bind.Cap.(UIBC)",
                  "UIBC",
                  "Unsaturated Iron Binding Capacity (UIBC)",
                ]
              }
            ]
          },
          {
            "name": "Platelets",
            "description": "",
            "biomarkers": [
              {
                "name": "Mean Platelet Volume (MPV)",
                "description": "Average platelet size",
                "unit": "fL",
                "alternative_names": [
                  "MPV",
                  "Mean Platelet Volume",
                  "Mean Platelet Volume, MPV",
                ]
              },
              {
                "name": "Platelet Count",
                "description": "Clot-forming cell fragments",
                "unit": "K/uL",
                "alternative_names": [
                  "PLATELET COUNT",
                  "PLT",
                  "Platelets"
                ]
              }
            ]
          },
          {
            "name": "Red Blood Cells",
            "description": "",
            "biomarkers": [
              {
                "name": "Hematocrit",
                "description": "Fraction of red blood cells",
                "unit": "%",
                "alternative_names": [
                  "HCT",
                  "HEMATOCRIT"
                ]
              },
              {
                "name": "Hemoglobin",
                "description": "Protein in red blood cells",
                "unit": "g/dL",
                "alternative_names": [
                  "HEMOGLOBIN",
                  "HGB"
                ]
              },
              {
                "name": "MCH",
                "description": "Mean cell hemoglobin",
                "unit": "pg",
                "alternative_names": [
                  "MCH",
                  "Mean Cell Hemoglobin"
                ]
              },
              {
                "name": "MCHC",
                "description": "RBC hemoglobin concentration",
                "unit": "g/dL",
                "alternative_names": [
                  "MCHC",
                  "Mean Cell Hemoglobin Concentration",
                  "Mean Cell Hemoglobin Concentration (MCHC)",
                  "RBC hemoglobin concentration"
                ]
              },
              {
                "name": "MCV",
                "description": "Mean corpuscular volume",
                "unit": "fL",
                "alternative_names": [
                  "MCV",
                  "Mean corpuscular volume"
                ]
              },
              {
                "name": "Nucleated Red Blood Cells",
                "description": "Immature red blood cells",
                "unit": "/100 WBCs",
                "alternative_names": [
                  "NRBC",
                  "Nucleated Red Blood Cells, NRBC",
                  "Nucleated Red Blood Cells (NRBC)",
                  "Nucleated Rbc",
                ]
              },
              {
                "name": "Absolute Nucleated Red Blood Cells",
                "description": "Immature red blood cells",
                "unit": "K/uL",
                "alternative_names": [
                  "Absolute NRBC",
                  "ABSOLUTE NRBC",
                  "Absolute Nucleated Red Blood Cells (NRBC)",
                  "Absolute Nucleated Red Blood Cells",
                  "Absolute Nucleated Red Blood Cells, NRBC",
                  "Absolute Nucleated Rbc"
                ]
              },
              {
                "name": "RBC",
                "description": "Red blood cell count",
                "unit": "M/uL",
                "alternative_names": [
                  "RBC",
                  "RED BLOOD CELL COUNT"
                ]
              },
              {
                "name": "RDW",
                "description": "Red cell distribution width",
                "unit": "%",
                "alternative_names": [
                  "RDW",
                  "Red cell distribution width",
                  "Red blood cell distribution width"
                ]
              }
            ]
          },
          {
            "name": "White Blood Cells",
            "description": "",
            "biomarkers": [
              {
                "name": "% Basophils",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "BASOPHILS",
                  "BASOS",
                  "BASOS %"
                ]
              },
              {
                "name": "% Eosinophils",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "EOS",
                  "EOSINOPHILS",
                  "EOSINOPHILS %"
                ]
              },
              {
                "name": "% Lymphocytes",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "LYMPHOCYTES",
                  "LYMPHS",
                  "LYMPHS %",
                  "Lymphocytes %"
                ]
              },
              {
                "name": "% Monocytes",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "MONOCYTES",
                  "MONOS",
                  "MONOS %",
                  "Monocytes %"
                ]
              },
              {
                "name": "% Neutrophil",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "NEUTROPHILS",
                  "NEUTS",
                  "NEUTS %",
                  "Neutrophils %"
                ]
              },
              {
                "name": "% Band Neutrophil",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "Band Neutrophils",
                  "Band Neuts",
                  "Band Neuts %",
                  "Band Neutrophils %",
                  "Bands"
                ]
              },
              {
                "name": "% Blasts",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "Blasts",
                  "Blasts %"
                ]
              },
              {
                "name": "% Metamyelocytes",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "Metamyelocytes",
                  "Metamyelocytes %",
                  "Metamyelocytes, %"
                ]
              },
              {
                "name": "% Myelocytes",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "Myelocytes",
                  "Myelocytes %",
                  "Myelocytes, %"
                ]
              },
              {
                "name": "% Promyelocytes",
                "description": "Part of WBC differential",
                "unit": "%",
                "alternative_names": [
                  "Promyelocytes",
                  "Promyelocytes %",
                  "Promyelocytes, %"
                ]
              },
              {
                "name": "Basophil (absolute)",
                "description": "Calculation of WBC type",
                "unit": "K/uL",
                "alternative_names": [
                  "ABSOLUTE BASOPHILS",
                  "ABSOLUTE BASOS",
                  "Basophil, absolute",
                  "Basos, absolute",
                  "Basos (absolute)",
                  "Baso (Absolute)"
                ]
              },
              {
                "name": "Band Neutrophil (absolute)",
                "description": "Part of WBC differential",
                "unit": "k/uL",
                "alternative_names": [
                  "Absolute Band Neutrophils",
                  "Band Neuts, Absolute",
                  "Band Neuts (Absolute)",
                  "Band Neutrophils, Absolute",
                  "Absolute Band Neutrophil Count",
                ]
              },
              {
                "name": "Blasts (absolute)",
                "description": "Part of WBC differential",
                "unit": "k/uL",
                "alternative_names": [
                  "Absolute Blasts",
                  "Blasts, Absolute",
                  "Absolute Blasts Count",
                ]
              },
              {
                "name": "Eosinophil (absolute)",
                "description": "Calculation of WBC type",
                "unit": "K/uL",
                "alternative_names": [
                  "ABSOLUTE EOS",
                  "ABSOLUTE EOSINOPHILS",
                  "Eosinophil, absolute",
                  "Eosinophils, absolute",
                  "Eosinophils (absolute)",
                  "Eos (absolute)",
                  "Eos, absolute"
                ]
              },
              {
                "name": "% Immature Granulocytes",
                "description": "Immature granulocytes",
                "unit": "%",
                "alternative_names": [
                  "% IMMATURE GRANS",
                  "IMMATURE GRANS %",
                  "Immature Grans",
                  "Immature Granulocytes %",
                ]
              },
              {
                "name": "Immature Granulocytes (Absolute)",
                "description": "Immature Granulocytes (Absolute)",
                "unit": "K/uL",
                "alternative_names": [
                  "ABS IMMATURE GRANS",
                  "Immature Granulocytes, Absolute",
                  "Immature Grans, Absolute",
                  "Immature Grans (Absolute)",
                  "Absolute Immature Granulocytes",
                  "Absolute Immature Grans",
                  "Immature Grans (Abs)"
                ]
              },
              {
                "name": "Lymphocyte Count (absolute)",
                "description": "Calculation of WBC type",
                "unit": "K/uL",
                "alternative_names": [
                  "ABSOLUTE LYMPHOCYTES",
                  "ABSOLUTE LYMPHS",
                  "Lymphocyte, absolute",
                  "Lymphocytes, abs",
                  "Lymphocytes (absolute)",
                  "Lymphs, absolute",
                  "Lymphs (absolute)",
                  "Lymphs, abs",
                  "Lymphocyte Count",
                  "Lymphocyte Count (Abs)"
                ]
              },
              {
                "name": "Metamyelocytes (absolute)",
                "description": "Part of WBC differential",
                "unit": "K/uL",
                "alternative_names": [
                  "Absolute Metamyelocytes",
                  "Metamyelocytes, Absolute",
                  "Metamyelocytes (Absolute)"
                ]
              },
              {
                "name": "Myelocytes (absolute)",
                "description": "Part of WBC differential",
                "unit": "K/uL",
                "alternative_names": [
                  "Absolute Myelocytes",
                  "Myelocytes, Absolute",
                  "Myelocytes (Absolute)"
                ]
              },
              {
                "name": "Promyelocytes (absolute)",
                "description": "Part of WBC differential",
                "unit": "K/uL",
                "alternative_names": [
                  "Absolute Promyelocytes",
                  "Promyelocytes, Absolute",
                  "Promyelocytes (Absolute)"
                ]
              },
              {
                "name": "Monocytes (absolute)",
                "description": "Type of white blood cell",
                "unit": "K/uL",
                "alternative_names": [
                  "ABSOLUTE MONOCYTES",
                  "ABSOLUTE MONOS",
                  "Monocyte, absolute",
                  "Monocytes, absolute",
                  "Monos, absolute",
                  "Monos (absolute)",
                  "Absolute Monocyte",
                  "Monocytes(Absolute)"
                ]
              },
              {
                "name": "Megakaryocytes",
                "description": "Large bone marrow cells responsible for production of platelets",
                "unit": "%",
                "alternative_names": []
              },
              {
                "name": "Reactive Lymphocytes",
                "description": "Type of white blood cell",
                "unit": "%",
                "alternative_names": [
                  "Reactive Lymphocytes %",
                  "Reactive Lymphocytes, %",
                  "Reactive Lymphocytes"
                ]
              },
              {
                "name": "Neutrophil Count (ANC)",
                "description": "Type of white blood cell",
                "unit": "K/uL",
                "alternative_names": [
                  "ABSOLUTE NEUTROPHILS",
                  "ABSOLUTE NEUTS",
                  "Neutrophil, absolute",
                  "Neutrophils, absolute",
                  "Neutrophils (absolute)",
                  "Neuts, absolute",
                  "Neuts (absolute)",
                  "Absolute Neutrophil",
                  "Absolute Neutrophils",
                  "Absolute Neutrophils Count",
                  "Absolute Neutrophil Count",
                  "Absolute Neuts Count",
                  "Absolute Neuts Count, ANC",
                  "Absolute Neutrophils Count, ANC",
                  "Absolute Neutrophil Count (ANC)",
                  "Absolute Neutrophils Count (ANC)"
                ]
              },
              {
                "name": "White Blood Cell Count",
                "description": "Immune system cells",
                "unit": "K/uL",
                "alternative_names": [
                  "WBC",
                  "WHITE BLOOD CELL COUNT",
                  "WBC",
                  "WBC COUNT"
                ]
              }
            ]
          }
        ]
      },
      {
        "name": "Body Composition",
        "description": "",
        "subcategories": [
          {
            "name": "Body",
            "description": "",
            "biomarkers": [
              {
                "name": "Body Mass Index",
                "description": "Measure of weight to height",
                "unit": "Kg/m2",
                "alternative_names": [
                  "BMI",
                  "Body Mass Index (BMI)",
                  "Body Mass Index, BMI"
                ]
              }
            ]
          }
        ]
      },
      {
        "name": "Cardiovascular Health",
        "description": "",
        "subcategories": [
          {
            "name": "Inflammation",
            "description": "",
            "biomarkers": [
              {
                "name": "Cortisol",
                "description": "Primary stress hormone",
                "unit": "ug/dL",
                "alternative_names": [
                  "Cortisol, Total",
                  "Serum,Hydrocortisone",
                  "Total Cortisol",
                  "Compound F",
                  "Hydrocortisone"
                ]
              },
              {
                "name": "hs-CRP",
                "description": "General Inflammation Marker",
                "unit": "mg/L",
                "alternative_names": [
                  "HS CRP",
                  "C-Reactive Protein, Cardiac",
                  "High Sensitivity CRP",
                  "High Sensitivity C-Reactive Protein",
                  "Cardiac CRP",
                  "CRP",
                  "High Sensitivity",
                  "CCRP",
                  "Ultrasensitive CRP",
                  "hsCRP",
                  "C-Reactive Protein",
                  "Highly Sensitive CRP",
                  "Cardiac C-Reactive Protein (CRP)",
                  "High-sensitivity CRP"
                ]
              }
            ]
          },
          {
            "name": "Lipid Panel",
            "description": "",
            "biomarkers": [
              {
                "name": "HDL",
                "description": "High-Density Lipoprotein",
                "unit": "mg/dL",
                "alternative_names": [
                  "HDL Chol Calc (NIH)",
                  "HDL CHOLESTEROL",
                  "HDL Cholesterol",
                  "High Density Lipoprotein",
                  "High-density lipoprotein",
                  "Cholesterol HDL",
                  "Cholesterol, HDL",
                  "Cholesterol, HDL (High Density Lipoprotein)",
                  "Cholesterol, HDL (High-density lipoprotein)"
                ]
              },
              {
                "name": "LDL",
                "description": "Less Healthy Low-Density Lipoprotein",
                "unit": "mg/dL",
                "alternative_names": [
                  "LDL Chol Calc (NIH)",
                  "LDL-CHOLESTEROL",
                  "Low Density Lipoprotein",
                  "Low-density lipoprotein",
                  "Cholesterol LDL",
                  "Cholesterol, LDL",
                  "Cholesterol, LDL (Low Density Lipoprotein)",
                  "Cholesterol, LDL (Low-density lipoprotein)",
                  "LDL, Calculated"
                ]
              },
              {
                "name": "Non-HDL Cholesterol (Calculated)",
                "description": "All Less Healthy Cholesterol",
                "unit": "mg/dL",
                "alternative_names": [
                  "NON HDL CHOLESTEROL",
                  "Non-HDL Cholesterol",
                  "Calculated Non-HDL Cholesterol",
                  "Calculated Non-HDL Cholesterol (Non-HDL-C)",
                  "Calc Non-HDL Cholesterol",
                  "Non HDL Cholesterol (calculated)",
                  "Non-HDL Cholesterol (calc)",
                  "Non-HDL Cholesterol, Calculated",
                  "Non-HDL Cholesterol, calc",
                  "Non HDL Cholesterol (calc)",
                  "Non HDL Chol, Calculated"
                ]
              },
              {
                "name": "Total Cholesterol",
                "description": "A Type of Fat",
                "unit": "mg/dL",
                "alternative_names": [
                  "CHOLESTEROL, TOTAL", 
                  "Cholesterol", 
                  "Cholesterol, Total",
                  "Total Chol",
                  "Cholesterol, Total (TC)"
                ]
              },
              {
                "name": "Total to HDL Ratio",
                "description": "Total Cholesterol to HDL Ratio",
                "unit": "",
                "alternative_names": [
                  "CHOL/HDLC RATIO",
                  "Total Cholesterol to HDL Ratio",
                  "Total Cholesterol to HDL Ratio (TC/HDL)",
                  "Total Cholesterol to HDL Ratio (TC/HDL-C)",
                  "Total Cholesterol/HDL Ratio",
                  "Total Chol/HDL Ratio",
                  "TC/HDLC Ratio",
                  "TC/HDL Ratio",
                  "TC/HDL-C Ratio",
                  "T. Chol/HDL Ratio",
                  "Chol/HDL Ratio",
                  "Cholesterol/HDL Ratio"
                ]
              },
              {
                "name": "Triglycerides",
                "description": "Type of Fat",
                "unit": "mg/dL",
                "alternative_names": [
                  "TRIGLYCERIDES",
                  "Triglycerides",
                  "Triglycerides (TG)",
                  "Triglyceride"
                ]
              },
              {
                "name": "Triglycerides to HDL Ratio",
                "description": "Ratio of Triglycerides to HDL",
                "unit": "",
                "alternative_names": [
                  "TRIG/HDL RATIO",
                  "Ratio of Triglycerides to HDL",
                  "Triglycerides/HDL Ratio",
                  "TG/HDL Ratio",
                  "TG/HDL-C Ratio"
                ]
              },
              {
                "name": "vLDL",
                "description": "Very Low-Density Lipoprotein",
                "unit": "mg/dL",
                "alternative_names": [
                  "VLDL Cholesterol Cal",
                  "Very low-density lipoprotein",
                  "Very low density lipoprotein",
                  "v-LDL"
                ]
              }
            ]
          },
          {
            "name": "Lipid Particles",
            "description": "",
            "biomarkers": [
              {
                "name": "Apo A-1",
                "description": "Protein in HDL Cholesterol",
                "unit": "mg/dL",
                "alternative_names": [
                  "APOLIPOPROTEIN-A1",
                  "ApoA1",
                  "Apo-A1",
                  "Apolipoprotein A1",
                  "Apolipoprotein A-1",
                  "A-1 Apolipoprotein",
                  "Alpha-Apolipoprotein"
                ]
              },
              {
                "name": "Apo B",
                "description": "Protein in LDL Cholesterol",
                "unit": "mg/dL",
                "alternative_names": [
                  "APOLIPOPROTEIN B",
                  "ApoB",
                  "Apo-B",
                  "Apolipoprotein B-100",
                  "Beta Apolipoprotein"
                ]
              },
              {
                "name": "Lp(a)",
                "description": "Different Form of LDL",
                "unit": "nmol/L",
                "alternative_names": [
                  "LIPOPROTEIN (a)",
                  "Lp a",
                  "Lp (a)",
                  "Lipoprotein a",
                  "Lipoprotein-a",
                  "Lipoprotein(a)",
                  "Lp \"Little a\""
                ]
              }
            ]
          },
          {
            "name": "Risk Factors",
            "description": "",
            "biomarkers": [
              {
                "name": "Homocysteine",
                "description": "Amino Acid in Blood",
                "unit": "umol/L",
                "alternative_names": [
                  "HOMOCYSTEINE",
                  "Homocysteine",
                  "Homocysteine, Plasma",
                  "Plasma Homocysteine",
                  "Homocyst(e)ine"
                ]
              },
              {
                "name": "Lp-PLA2 Activity",
                "description": "Lipoprotein-Associated Phospholipase A2 activity",
                "unit": "nmol/min/mL",
                "alternative_names": [
                  "Lp PLA2 Activity",
                  "Lp-PLA2 SerPl-cCnc",
                  "Lipoprotein-associated phospholipase A2 activity",
                  "Lipoprotein associated phospholipase A2",
                  "Lipoprotein Associated Phospholipase A2, Blood"
                ]
              }
            ]
          }
        ]
      },
      {
        "name": "Kidney Health",
        "description": "",
        "subcategories": [
          {
            "name": "Kidney",
            "description": "",
            "biomarkers": [
              {
                "name": "BUN",
                "description": "Blood Urea Nitrogen",
                "unit": "mg/dL",
                "alternative_names": [
                  "BUN",
                  "UREA NITROGEN (BUN)",
                  "Blood urea nitrogen",
                  "Blood urea nitrogen (BUN)",
                  "Blood Urea Nitrogen, BUN",
                  "Plasma Urea Nitrogen",
                  "Urea Nitrogen"
                ]
              },
              {
                "name": "BUN/Creatinine Ratio",
                "description": "BUN / Creatinine Serum",
                "unit": "",
                "alternative_names": [
                  "BUN/CREATININE RATIO",
                  "BUN/Creatinine Ratio",
                  "BUN/creatinine",
                  "BUN/Creatinine",
                  "BUN / Creatinine Serum",
                  "BUN/Creatinine Serum",
                  "Blood Urea Nitrogen/Creatinine Ratio"
                ]
              },
              {
                "name": "Creatinine",
                "description": "Creatinine in your blood",
                "unit": "mg/dL",
                "alternative_names": [
                  "CREATININE",
                  "Creatinine",
                  "Creatinine, Serum",
                  "Serum Creatinine",
                  "Plasma Creatinine"
                ]
              },
              {
                "name": "Urine Creatinine",
                "description": "Creatinine in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "CREATININE, URINE",
                  "Creatinine, Urine",
                  "Urine Creatinine"
                ]
              },
              {
                "name": "eGFR",
                "description": "Marker for kidney function",
                "unit": "mL/min/1.73m2",
                "alternative_names": [
                  "EGFR",
                  "eGFR",
                  "eGFR NON-AFR. AMERICAN",
                  "eGFRcr CKD-EPI",
                  "e-GFR",
                  "eGFR Estimate, All",
                  "eGFR, Creatinine-based formula (CKD-EPI 2021)"
                ]
              },
              {
                "name": "eGFR (African American ethnicity)",
                "description": "eGFR if African American",
                "unit": "mL/min/1.73m2",
                "alternative_names": [
                  "eGFR AFRICAN AMERICAN",
                  "African American eGFR",
                  "eGFR African American",
                  "eGFR (African American)",
                  "eGFR African American ethnicity",
                  "African American ethnicity eGFR"
                ]
              },
              {
                "name": "Uric Acid",
                "description": "Levels of Uric Acid in blood",
                "unit": "mg/dL",
                "alternative_names": [
                  "Uric Acid, Serum",
                  "Serum Uric Acid",
                  "UA",
                  "Urate"
                ]
              }
            ]
          }
        ]
      },
      {
        "name": "Liver Health",
        "description": "",
        "subcategories": [
          {
            "name": "Liver",
            "description": "",
            "biomarkers": [
              {
                "name": "A/G Ratio",
                "description": "Proportion, albumin/globulin",
                "unit": "",
                "alternative_names": [
                  "ALBUMIN/GLOBULIN RATIO",
                  "Albumin/Globulin Ratio",
                  "Albumin/Globulin",
                  "Albumin/globulin",
                  "Albumin/Globulin Ratio (calculated)",
                  "Proportion, albumin/globulin"
                ]
              },
              {
                "name": "Albumin",
                "description": "Type of protein in blood",
                "unit": "g/dL",
                "alternative_names": [
                  "ALBUMIN",
                  "Albumin",
                  "Albumin, Serum",
                  "Serum Albumin",
                  "ALBUMIN, POCT"
                ]
              },
              {
                "name": "Urine Albumin",
                "description": "Type of protein in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "ALBUMIN, URINE",
                  "Albumin, Urine",
                  "UA-Albumin",
                  "Urine Albumin"
                ]
              },
              {
                "name": "Urine Urobilinogen",
                "description": "Byproduct of the breakdown of hemoglobin in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "UROBILINOGEN, URINE",
                  "UA-Urobilinogen",
                  "Urine Urobilinogen",
                  "Urobilinogen, Urine"
                ]
              },
              {
                "name": "ALP",
                "description": "Alkaline Phosphatase",
                "unit": "IU/L",
                "alternative_names": [
                  "ALKALINE PHOSPHATASE",
                  "Alkaline Phosphatase",
                  "Alkaline Phosphatase (ALP)",
                  "Alkaline Phosphatase, Serum",
                  "Serum Alkaline Phosphatase"
                ]
              },
              {
                "name": "ALT / SGPT",
                "description": "Alanine aminotransferase",
                "unit": "IU/L",
                "alternative_names": [
                  "ALT",
                  "ALT (SGPT)",
                  "Transaminase-SGPT",
                  "Alanine aminotransferase",
                  "Alanine aminotransferase (ALT)",
                  "ALT/SGPT"
                ]
              },
              {
                "name": "AST / SGOT",
                "description": "Aspartate aminotransferase",
                "unit": "IU/L",
                "alternative_names": [
                  "AST",
                  "AST (SGOT)",
                  "Transaminase-SGOT",
                  "Aspartate aminotransferase",
                  "Aspartate aminotransferase (AST)",
                  "AST/SGOT"
                ]
              },
              {
                "name": "Bilirubin (direct)",
                "description": "Test for liver problems",
                "unit": "mg/dL",
                "alternative_names": [
                  "DIRECT BILIRUBIN",
                  "Direct Bilirubin",
                  "Bilirubin, Direct"
                ]
              },
              {
                "name": "Bilirubin (total)",
                "description": "Made by the liver to help digest fat.",
                "unit": "mg/dL",
                "alternative_names": [
                  "BILIRUBIN, TOTAL", 
                  "Bilirubin, Total", 
                  "TOTAL BILIRUBIN", 
                  "Total Bilirubin",
                  "Bilirubin Total"
                ]
              },
              {
                "name": "Urine Bilirubin",
                "description": "Bilirubin in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "BILIRUBIN, URINE",
                  "Bilirubin, Urine",
                  "Urine Bilirubin",
                  "UA-Bilirubin"
                ]
              },
              {
                "name": "Globulin",
                "description": "Immune protein",
                "unit": "g/dL",
                "alternative_names": [
                  "GLOBULIN", 
                  "Globulin", 
                  "Globulin, Total",
                  "Globulin (calculated)",
                  "Total Globulin",
                  "Total Globulin (calculated)",
                  "Globulin (total)"
                ]
              },
              {
                "name": "Urine Ketone",
                "description": "Ketones in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "KETONES, URINE",
                  "Ketones, Urine",
                  "Urine Ketones",
                  "UA-Ketones"
                ]
              },
              {
                "name": "Total Protein",
                "description": "Total protein amount (serum)",
                "unit": "g/dL",
                "alternative_names": [
                  "PROTEIN, TOTAL", 
                  "Protein, Total", 
                  "TOTAL PROTEIN",
                  "Total Protein",
                  "Total Protein (serum)",
                  "Protein, Total (serum)",
                  "Protein (Total)",
                  "Protein"
                ]
              },
              {
                "name": "Urine Protein",
                "description": "Protein in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "PROTEIN, URINE",
                  "Protein, Urine",
                  "Urine Protein",
                  "UA-Protein",
                  "Protein-UA",
                  "Protein, Total, Urine"
                ]
              }
            ]
          }
        ]
      },
      {
        "name": "Metabolic Health",
        "description": "",
        "subcategories": [
          {
            "name": "Diabetes & Insulin Resistance",
            "description": "",
            "biomarkers": [
              {
                "name": "Glucose",
                "description": "Blood Sugar",
                "unit": "mg/dL",
                "alternative_names": [
                  "GLUCOSE",
                  "Glucose",
                  "Glucose, Serum",
                  "Blood Glucose",
                  "Glucose, Plasma",
                  "Plasma Glucose",
                  "GLUCOSE, POCT"
                ]
              },
              {
                "name": "Urine Glucose",
                "description": "Sugar in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "GLUCOSE, URINE",
                  "Glucose, Urine",
                  "UA-Glucose"
                ]
              },
              {
                "name": "Hemoglobin A1c (HbA1c)",
                "description": "Average blood sugar level",
                "unit": "%",
                "alternative_names": [
                  "HEMOGLOBIN A1c",
                  "Hemoglobin A1c",
                  "HbA1c",
                  "A1c",
                  "HA1c",
                  "Hgb A1c",
                  "Glycated Hemoglobin"
                ]
              },
              {
                "name": "HOMA-IR SCORE",
                "description": "Predicting risk of insulin resistance and diabetes",
                "unit": "",
                "alternative_names": [
                  "HOMA-IR",
                  "HOMA IR",
                  "HOMA IR SCORE",
                ]
              },
              {
                "name": "Insulin",
                "description": "Blood sugar storage hormone",
                "unit": "mIU/L",
                "alternative_names": [
                  "Immunoreactive Insulin"
                ]
              },
              {
                "name": "Insulin-Like Growth Factor I",
                "description": "A Measure of Growth Hormone",
                "unit": "ng/mL",
                "alternative_names": [
                  "IGF-1",
                  "IGF 1",
                  "IGF1",
                  "Insulin like growth factor 1",
                  "Igf 1, Lc/Ms", 
                  "Somatomedin-C",
                  "Insulin Like Growth Factor",
                  "Insulin-Like Growth Factor",
                  "SM-C/IGF-1"
                ]
              },
              {
                "name": "Z score",
                "description": "IGF-1 compared to others",
                "unit": "",
                "alternative_names": [
                  "Z-score",
                  "Z Score (Male)",
                  "Z Score (Female)"
                ]
              }
            ]
          },
          {
            "name": "Reproductive Hormones",
            "description": "",
            "biomarkers": [
              {
                "name": "DHEA-S",
                "description": "Adrenal Hormone",
                "unit": "ug/dL",
                "alternative_names": [
                  "DHEA S",
                  "DHEA-Sulfate",
                  "DHEA Sulfate",
                  "DHEAS",
                  "DHEA SO4",
                  "Dehydroepiandrosterone Sulfate",
                  "Transdehydroandrosterone",
                  "DHEA-SO4"
                ]
              },
              {
                "name": "Estradiol",
                "description": "Main female sex hormone",
                "unit": "pg/mL",
                "alternative_names": [
                  "17-Beta-Estradiol",
                  "E2 IVF",
                  "IVF Estradiol",
                  "Estradiol (E2-6 III)",
                  "Estradiol, 17 Beta"
                ]
              },
              {
                "name": "Free Testosterone",
                "description": "Active Unbound Testosterone",
                "unit": "pg/mL",
                "alternative_names": [
                  "Free Testosterone (Direct)",
                  "Free-Testosterone",
                  "Free Testosterone, Serum",
                  "Serum Free Testosterone",
                  "Free Testosterone, Direct",
                  "Testosterone, Free",
                  "Free Testosterone(Direct)"
                ]
              },
              {
                "name": "SHBG",
                "description": "Sex Hormone Binding Globulin",
                "unit": "nmol/L",
                "alternative_names": [
                  "Sex Hormone Binding Globulin",
                  "Sex Horm Binding Glob, Serum",
                  "Estradiol Binding Globulin",
                  "Estradiol Binding Protein",
                  "Bound Testosterone",
                  "Testosterone Binding Gobulin",
                  "Sex Hormone Binding Protein",
                  "Androgen Binding Globulin",
                  "Testosterone Binding Protein",
                  "Testosterone-binding Globulin",
                  "SEX HORM. BIND. GLOB."
                ]
              },
              {
                "name": "Testosterone (total)",
                "description": "Steroid hormone",
                "unit": "ng/dL",
                "alternative_names": [
                  "TESTOSTERONE, TOTAL",
                  "Total Testosterone",
                  "Testosterone, Total, Ms",
                  "Testosterone"
                ]
              },
              {
                "name": "Follicle Stimulating Hormone",
                "description": "Reproductive Hormone",
                "unit": "mIU/mL",
                "alternative_names": [
                  "FSH",
                  "Follicle Stimulating Hormone (FSH)",
                  "Pituitary Gonadotropin"
                ]
              },
              {
                "name": "Luteinizing Hormone (LH)",
                "description": "Reproductive Hormone",
                "unit": "mIU/mL",
                "alternative_names": [
                  "LH",
                  "Luteinizing Hormone",
                  "Interstitial Cell-stimulating Hormone",
                  ""
                ]
              },
              {
                "name": "Progesterone",
                "description": "Reproductive Hormone",
                "unit": "ng/mL",
                "alternative_names": []
              }
            ]
          },
          {
            "name": "Thyroid",
            "description": "",
            "biomarkers": [
              {
                "name": "Anti-Thyroglobulin Antibodies",
                "description": "Antibodies to thyroid proteins",
                "unit": "IU/mL",
                "alternative_names": [
                  "Thyroglobulin Ab",
                  "Thyroglobulin Antibody"
                ]
              },
              {
                "name": "Free T3",
                "description": "Available T3",
                "unit": "pg/mL",
                "alternative_names": [
                  "Free-T3",
                  "T3, Free",
                  "T3, Free (Direct)",
                  "T3,Free",
                  "T3,Free (Direct)",
                  "Triiodothyronine (T3), Free",
                  "Free T3",
                  "T3, Free"
                ]
              },
              {
                "name": "T3 Uptake",
                "description": "Thyroid Hormone Binding",
                "unit": "%",
                "alternative_names": [
                  "T3 Uptake, Serum"
                ]
              },
              {
                "name": "Free T4",
                "description": "Available T4",
                "unit": "ng/dL",
                "alternative_names": [
                  "FREE T4", 
                  "Free T4", 
                  "T4,Free (Direct)", 
                  "Thyroxine, free",
                  "Free Thyroxine (T4)",
                  "Free Thyroxine",
                  "Free Thyroxine, T4",
                  "T4, FREE",
                  "T4 Free",
                  "T4,Free(Direct)",
                  "FT4",
                  "Free T4, Direct, Serum",
                  "Free Thyroxine",
                  "T4, Free, Direct, Serum"
                ]
              },
              {
                "name": "Free Thyroxine Index",
                "description": "A Thyroxine Index",
                "unit": "",
                "alternative_names": [
                  "Free T4 Index (T7)"
                ]
              },
              {
                "name": "Reverse T3",
                "description": "Reverse T3, Serum",
                "unit": "ng/dL",
                "alternative_names": [
                  "T3, Reverse, Lc/Ms/Ms",
                  "Reverse T3, Serum",
                  "T3, Reverse",
                  "Reverse Triiodothyronine",
                  "RT3",
                  "rT3",
                  "Triiodothyronine Reverse"
                ]
              },
              {
                "name": "T-Uptake",
                "description": "Thyroxine Binding Sites",
                "unit": "%",
                "alternative_names": []
              },
              {
                "name": "Parathyroid hormone (PTH)",
                "description": "Parathyroid Hormone",
                "unit": "pg/mL",
                "alternative_names": [
                  "Parathyroid Hormone",
                  "Parathyroid Hormone (PTH), Intact",
                  "PTH Whole Molecule",
                  "Parathyroid Hormone, Intact"
                ]
              },
              {
                "name": "Thyroxine (T4, total)",
                "description": "Total thyroxine (T4) level",
                "unit": "ug/dL",
                "alternative_names": [
                  "Thyroxine (T4)",
                  "T4, Total",
                  "T4, Total (Direct)",
                  "T4, Total (Direct) (Thyroxine)",
                  "T4, Total (Thyroxine)",
                  "Thyroxine (T4), Total",
                  "Thryoxine, Total",
                  "T4 (Thyroxine), Total"
                ]
              },
              {
                "name": "TPO Antibodies",
                "description": "An antibody to a thyroid enzyme",
                "unit": "IU/mL",
                "alternative_names": [
                  "TPO ANTIBODIES",
                  "TPO Antibodies",
                  "Thyroid Peroxidase (TPO) Ab",
                  "Thyroid Peroxidase AB",
                  "Thyroid peroxidase antibodies",
                  "Thyroid-peroxidase antibodies",
                  "Antibodies to thyroid peroxidase",
                  "Anti-Thyroid Microsomal Antibody",
                  "Anti-TPO",
                  "Antimicrosomal Antibody",
                  "Antithyroid Microsomal Antibody"
                ]
              },
              {
                "name": "Triiodothyronine (T3, total)",
                "description": "Total triiodothyronine (T3)",
                "unit": "ng/dL",
                "alternative_names": [
                  "Total T3",
                  "T3 Total", 
                  "T3, total",
                  "Triiodothyronine",
                  "Triiodothyronine (T3)",
                  "Triiodothyronine, Total",
                  "Triiodothyronine, Total (T3)",
                  "T3 Total (Triiodothyronine)",
                  "T3, Total"
                ]
              },
              {
                "name": "TSH",
                "description": "Thyroid-Stimulating Hormone",
                "unit": "mIU/L",
                "alternative_names": [
                  "SCREENING PANEL: TSH",
                  "T1-TSH",
                  "TSH",
                  "Thyroid stimulating hormone",
                  "Thyroid Stimulating Hormone (TSH)",
                  "Thyroid-Stimulating Hormone",
                  "Thyroid Stimulating Hormone, TSH",
                  "TSH (Thyroid Stimulating Hormone)",
                  "Thyrotropin",
                  "Third-generation TSH"
                ]
              }
            ]
          },
        ]
      },
      {
        "name": "Fatty Acids",
        "description": "",
        "subcategories": [
          {
            "name": "Fatty Acids",
            "description": "",
            "biomarkers": [
              {
                "name": "Omega 3 Index",
                "description": "Amount of EPA and DHA in blood",
                "unit": "%",
                "alternative_names": [
                  "Omega-3 Index",
                  "Omega 3 Index (EPA+DHA)",
                  "Omega-3 Index (EPA+DHA)",
                  "Omega-3 Index (EPA + DHA)",
                  "Omega 3 (Epa+Dha) Index",
                  "Omega 3 (EPA + DHA) Index",
                ]
              },
              {
                "name": "Total Omega-3",
                "description": "Total amount of Omega 3 Fatty Acids",
                "unit": "",
                "alternative_names": [
                  "Omega-3 total"
                ]
              },
              {
                "name": "Total Omega-6",
                "description": "Total amount of Omega 6 Fatty Acids",
                "unit": "",
                "alternative_names": [
                  "Omega-6 total"
                ]
              },
              {
                "name": "Omega-6:Omega-3 Ratio",
                "description": "Ratio of Omega 6 to Omega 3",
                "unit": "",
                "alternative_names": [
                  "Omega-6:3 Ratio",
                  "Omega 6:3 Ratio",
                  "Omega 6:Omega 3 Ratio",
                  "Omega 6:Omega 3 Ratio (Arachidonic Acid/EPA+DHA)",
                  "Omega 6:Omega 3 Ratio (Arachidonic Acid/EPA + DHA)",
                  "Omega 6:Omega 3 Ratio (Arachidonic Acid/EPA and DHA)",
                  "Omega 6/Omega 3 Ratio",
                  "Omega-6/Omega-3 Ratio",
                  "Omega-6/Omega-3 Ratio (Arachidonic Acid/EPA+DHA)",
                  "Omega-6/Omega-3 Ratio (Arachidonic Acid/EPA + DHA)",
                ]
              },
              {
                "name": "Arachidonic Acid",
                "description": "Omega-6 Fatty Acid",
                "unit": "%",
                "alternative_names": [
                  "Arachidonic Acid (AA)",
                  "Arachidonic Acid, Serum",
                  "Serum Arachidonic Acid"
                ]
              },
              {
                "name": "DHA (Docosahexaenoic Acid)",
                "description": "Omega-3 Fatty Acid",
                "unit": "%",
                "alternative_names": [
                  "DHA",
                  "Docosahexaenoic Acid",
                  "Docosahexaenoic Acid (DHA)",
                  "Docosahexaenoic Acid, Serum",
                  "Serum Docosahexaenoic Acid"
                ]
              },
              {
                "name": "EPA (Eicosapentaenoic Acid)",
                "description": "Omega-3 Fatty Acid",
                "unit": "%",
                "alternative_names": [
                  "EPA",
                  "Eicosapentaenoic Acid",
                  "Eicosapentaenoic Acid (EPA)",
                  "Eicosapentaenoic Acid, Serum",
                  "Serum Eicosapentaenoic Acid"
                ]
              },
              {
                "name": "DPA (Docosapentaenoic Acid)",
                "description": "Omega-3 Fatty Acid",
                "unit": "",
                "alternative_names": [
                  "DPA",
                  "Docosapentaenoic Acid",
                  "Docosapentaenoic Acid (DPA)",
                  "Docosapentaenoic Acid, Serum",
                  "Serum Docosapentaenoic Acid"
                ]
              },
              {
                "name": "Linoleic Acid",
                "description": "Omega-6 Fatty Acid",
                "unit": "",
                "alternative_names": [
                  "Linoleic Acid, Serum",
                  "Serum Linoleic Acid"
                ]
              },
              {
                "name": "EPA:AA Ratio",
                "description": "EPA Ratio to Arachidonic Acid",
                "unit": "",
                "alternative_names": [
                  "EPA/AA RATIO",
                  "EPA:AA Ratio",
                  "EPA/AA",
                  "EPA/AA Ratio (Eicosapentaenoic Acid/Arachidonic Acid)",
                  "EPA/AA Ratio (Eicosapentaenoic Acid/Arachidonic Acid)",
                  "Epa/Arachidonic Acid Ratio",
                  "Eicosapentaenoic Acid/Arachidonic Acid",
                  "Eicosapentaenoic Acid/Arachidonic Acid Ratio",
                ]
              },
              {
                "name": "AA:EPA Ratio",
                "description": "Arachidonic Acid to EPA Ratio",
                "unit": "",
                "alternative_names": [
                  "AA/EPA RATIO",
                  "AA:EPA Ratio",
                  "AA/EPA",
                  "AA/EPA Ratio (Arachidonic Acid/Eicosapentaenoic Acid)",
                  "AA/EPA Ratio (Arachidonic Acid / Eicosapentaenoic Acid)",
                  "Arachidonic Acid/Epa Ratio",
                  "Arachidonic Acid/Eicosapentaenoic Acid",
                  "Arachidonic Acid/Eicosapentaenoic Acid Ratio",
                ]
              },
              {
                "name": "Free Fatty Acids",
                "description": "Unbound Fatty Acids in blood",
                "unit": "mmol/L",
                "alternative_names": [
                  "Free Fatty Acids, Serum",
                  "Serum Free Fatty Acids",
                  "Nonesterified Fatty Acids (Free Fatty Acids)",
                  "Free Fatty Acids (FFA)",
                  "NEFA"
                ]
              }
            ]
          },
        ]
      },
      {
        "name": "Vitamins, Minerals & Electrolytes",
        "description": "",
        "subcategories": [
          {
            "name": "Electrolytes",
            "description": "",
            "biomarkers": [
              {
                "name": "Anion Gap",
                "description": "Difference between ions",
                "unit": "mmol/L",
                "alternative_names": [
                  "ANION GAP",
                  "Plasma Anion GAP"
                ]
              },
              {
                "name": "Chloride",
                "description": "Balances other electrolytes",
                "unit": "mmol/L",
                "alternative_names": [
                  "CHLORIDE",
                  "Chloride",
                  "Chloride, Serum",
                  "Serum Chloride",
                  "Plasma Chloride"
                ]
              },
              {
                "name": "CO2",
                "description": "Carbon dioxide in blood",
                "unit": "mmol/L",
                "alternative_names": [
                  "CARBON DIOXIDE",
                  "CO2",
                  "Carbon Dioxide, Total",
                  "Carbon dioxide (CO2)",
                  "Carbon dioxide",
                  "Carbon dioxide, serum",
                  "Serum Carbon Dioxide",
                  "Carbon Dioxide, Total (CO2)",
                  "Carbon Dioxide, CO2",
                  "CO2, Total",
                  "CO2, Total (Carbon Dioxide)",
                  "CO2, Carbon Dioxide",
                  "Plasma Carbon Dioxide"
                ]
              },
              {
                "name": "Potassium",
                "description": "An electrolyte inside cells",
                "unit": "mmol/L",
                "alternative_names": [
                  "POTASSIUM",
                  "Potassium",
                  "Potassium, Serum",
                  "Serum Potassium",
                  "Plasma Potassium"
                ]
              },
              {
                "name": "Sodium",
                "description": "An electrolyte outside cells",
                "unit": "mmol/L",
                "alternative_names": [
                  "SODIUM",
                  "Sodium, Serum",
                  "Serum Sodium",
                  "Plasma Sodium",
                  "Sodium, Plasma"
                ]
              }
            ]
          },
          {
            "name": "Minerals",
            "description": "",
            "biomarkers": [
              {
                "name": "Calcium",
                "description": "Blood and Bone Mineral",
                "unit": "mg/dL",
                "alternative_names": [
                  "CALCIUM",
                  "Calcium",
                  "Calcium, Serum",
                  "Serum Calcium"
                ]
              },
              {
                "name": "Urine Calcium",
                "description": "Calcium in urine",
                "unit": "mg/dL",
                "alternative_names": [
                  "CALCIUM, URINE",
                  "Calcium, Urine",
                  "URINE CALCIUM",
                ]
              },
              {
                "name": "Ionized Calcium",
                "description": "Ionized Calcium in blood",
                "unit": "mg/dL",
                "alternative_names": [
                  "IONIZED CALCIUM",
                  "Ionized Calcium",
                  "Calcium, Ionized",
                  "Ionized Calcium, Serum",
                  "Serum Ionized Calcium",
                  "Calcium Filterable",
                  "Calcium Unbound",
                  "Ionized Calcium"
                ]
              },
              {
                "name": "Magnesium",
                "description": "Essential mineral",
                "unit": "mg/dL",
                "alternative_names": [
                  "MAGNESIUM",
                  "Magnesium, Serum",
                  "Serum Magnesium"
                ]
              },
              {
                "name": "Phosphorus",
                "description": "Electrolyte in cells and bones",
                "unit": "mg/dL",
                "alternative_names": [
                  "PHOSPHORUS",
                  "Phosphorus, Serum",
                  "Serum Phosphorus"
                ]
              },
              {
                "name": "RBC Magnesium",
                "description": "The Magnesium in our cells",
                "unit": "mg/dL",
                "alternative_names": [
                  "Magnesium, Rbc",
                  "MG (RBC)",
                  "MG RBC",
                  "MG++ (RBC)",
                  "RBC MG"
                ]
              }
            ]
          },
          {
            "name": "Vitamins",
            "description": "",
            "biomarkers": [
              {
                "name": "25-Hydroxy Vitamin D",
                "description": "Precursor to vitamin D",
                "unit": "ng/mL",
                "alternative_names": [
                  "VITAMIN D,25-OH,TOTAL,IA",
                  "25-Hydroxyvitamin D",
                  "Vitamin D, 25-Hydroxy",
                  "Vitamin D, 25-Hydroxy (Total)",
                  "Vitamin D",
                  "25 OH Vitamin D",
                  "Vitamin D, 25-OH",
                  "25-Hydroxy Vitamin D",
                  "Vitamin D, 25-Hydroxy",
                  "25-Hydroxycalciferol",
                  "25-OH-D",
                  "Cholecalciferol Metabolite",
                  "Vitamin D3 Metabolite",
                  "25 OH VIT D (TOTAL)",
                  "25-Hydroxy Vit D",
                  "25-Hydroxy Vit D (Total)",
                ]
              },
              {
                "name": "Folate",
                "description": "Folic Acid",
                "unit": "ng/mL",
                "alternative_names": [
                  "Folate Acid",
                  "Folate, Serum",
                  "Folate (Folic Acid), Serum"
                ]
              },
              {
                "name": "Vitamin B12",
                "description": "Essential nutrient for cells",
                "unit": "pg/mL",
                "alternative_names": [
                  "B12",
                  "Vitamin B-12",
                  "Vitamin B12, Serum",
                  "Serum Vitamin B12"
                ]
              }
            ]
          }
        ]
      }, {
        "name": UNCATEGORIZED_BIOMARKER_CATEGORY,
        "description": "",
        "subcategories": [
          {
            "name": UNCATEGORIZED_BIOMARKER_CATEGORY,
            "description": "",
            "biomarkers": []
          }
        ]
      }
    ]

    Rails.logger.info "Seeding Biomarker Categories and Subcategories"
    biomarker_categories.each do |category_attrs|
      Rails.logger.info "Processing biomarker category: #{category_attrs[:name]}"
      # Find the category by name, or initialize a new one
      category = BiomarkerCategory.find_or_initialize_by(name: category_attrs[:name])
      category.description = category_attrs[:description]

      category.save if category.new_record? || category.changed?

      # Associate subcategories
      category_attrs[:subcategories].each do |subcategory_attrs|
        Rails.logger.info "Processing biomarker subcategory: #{subcategory_attrs[:name]}"
        subcategory = category.biomarker_subcategories.find_or_initialize_by(name: subcategory_attrs[:name])
        subcategory.description = subcategory_attrs[:description]

        subcategory.save if subcategory.new_record? || subcategory.changed?

        # Associate biomarkers with the subcategory
        subcategory_attrs[:biomarkers].each do |biomarker_attrs|
          return unless biomarker_attrs.present?

          Rails.logger.info "Processing biomarker: #{biomarker_attrs[:name]}"
          biomarker = subcategory.biomarkers.find_or_initialize_by(name: biomarker_attrs[:name])
          biomarker.description = biomarker_attrs[:description]
          biomarker.unit = biomarker_attrs[:unit]
          biomarker.alternative_names = biomarker_attrs[:alternative_names]

          biomarker.save if biomarker.new_record? || biomarker.changed?
          Rails.logger.info "Processing biomarker: #{biomarker_attrs[:name]} complete!"
        end
        Rails.logger.info "Processing biomarker subcategory: #{subcategory_attrs[:name]} complete!"
      end
      Rails.logger.info "Processing biomarker category: #{category_attrs[:name]} complete!"
    end
    Rails.logger.info "Seeding Biomarker Categories and Subcategories complete!"
  end

end

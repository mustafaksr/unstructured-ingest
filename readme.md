# unstructured-data-convert-with-docai demo google cloud case-study

This demo project is about automatically converting unstructured pdf files uploaded to cloud storage into structured form with cloud function and docai.

Shortly process steps:
1.  Upload invoice files into the cloud storage bucket.
Note: For the invoice files, the pdf files located at the [dataset](https://data.mendeley.com/datasets/tnj49gpmtz) (10 pdf files of these files) will be used.
2.  Converting unstructured files into structured form with doc ai and cloud functions.
3.  Store structured data in Bigquery.

Note: This case study was inspired by qwiklab's [Automate Data Capture at Scale with Document AI: Challenge Lab](https://www.cloudskillsboost.google/focuses/34185?parent=catalog).  

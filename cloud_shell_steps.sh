git clone https://github.com/mustafaksr/unstructured-ingest.git

#enable apis
gcloud services enable compute.googleapis.com
gcloud services enable cloudbuild.googleapis.com  
gcloud services enable documentai.googleapis.com      
gcloud services enable cloudfunctions.googleapis.com  
    

#creating buckets

export project_id=[your-project_id]

export bucket_location=us-west1

gsutil mb -c STANDARD -l ${bucket_location} -b on gs://$project_id-input-bucket
gsutil mb -c STANDARD -l ${bucket_location} -b on gs://$project_id-output-bucket
gsutil mb -c ARCHIVE -l ${bucket_location} -b on gs://$project_id-archive

#make biqquery dataset and table for results
bq --location=US mk  -d \
     --description "Form Parser Results" \
     ${project_id}:invoice_results
cd ~/unstructured-ingest/table-schema
bq mk --table \
    invoice_results.extracted_entities \
    entities_schema.json

# create doc ai form parser
## Document AI - Overview
## Explore processor select form parser
## select region
## copy parser processor id

#create cloud functions
cd ~/unstructured-ingest/script
export region=us-west1
export processor_id=[your-docai-processor-id]


cat > process-invoices/.env.yaml <<EOF
PARSER_LOCATION: us
PROCESSOR_ID: f4a1f33332263cb
TIMEOUT: "300"
GCS_OUTPUT_URI_PREFIX: "processed"
EOF

cd ~/unstructured-ingest/script
gcloud functions deploy process-invoices \
    --region=${region} \
    --entry-point=process_invoice \
    --runtime=python37 \
    --service-account=${project_id}@appspot.gserviceaccount.com \
    --source=process-invoices \
    --timeout=300 \
    --env-vars-file=process-invoices/.env.yaml \
    --trigger-resource=gs://$project_id-input-bucket\
    --trigger-event=google.storage.object.finalize
   

gsutil cp ~/unstructured-ingest/sample-invoice-files/* gs://$project_id-input-bucket/

gsutil cp ~/unstructured-ingest/sample-invoice-files/* gs://$project_id-input-bucket/
git clone https://github.com/mustafaksr/unstructured-ingest.git

#enable apis
gcloud services enable compute.googleapis.com
gcloud services enable cloudbuild.googleapis.com  
gcloud services enable documentai.googleapis.com      
gcloud services enable cloudfunctions.googleapis.com  
    

#creating buckets

export project_id=[your-project_id]

export bucket-input=$project_id-input-bucket
export bucket-output=$project_id-output-bucket
gsutil mb gs://bucket-input
gsutil mb gs://bucket-output

#make biqquery dataset and table for results
bq --location=US mk  -d \
     --description "Form Parser Results" \
     ${PROJECT_ID}:invoice_results
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
gcloud functions deploy process-invoices \
    --region=${region} \
    --entry-point=process_invoice \
    --runtime=python37 \
    --service-account=${project_id}@appspot.gserviceaccount.com \
    --source=cloud-functions/process-invoices \
    --timeout=300 \
    --env-vars-file=cloud-functions/process-invoices/.env.yaml \
    --trigger-resource=gs://${bucket-input}\
    --trigger-event=google.storage.object.finalize
    --set-env-vars=PROCESSOR_ID=${processor_id},PARSER_LOCATION=${region}

gsutil cp ~/unstructured-ingest/sample-invoice-files/* gs://bucket-input/


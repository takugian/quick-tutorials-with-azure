# custom_topic_http_request_to_storage_queue

Creates a EventGrid Custom Topic that integrates HTTP Request and Storage Queue.

## How to test

curl --location '{eventgrid_topic_endpoint}' \
--header 'aeg-sas-key: {eventgrid_topic_primary_access_key}' \
--header 'Content-Type: application/json' \
--data '[
    {
        "id": "d5474e1e-76f9-4f58-a08f-2015a16f732d",
        "eventType": "QuickTutorialsWithAzure.EventGrid.UseCaseCreated",
        "subject": "usecase",
        "eventTime": "2023-01-01T00:00:00",
        "data": {
            "useCaseName": "custom_topic_storage_blob_to_storage_queue"
        },
        "dataVersion": "1.0"
    }
]'
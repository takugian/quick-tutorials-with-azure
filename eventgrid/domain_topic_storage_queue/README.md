# domain_topic_storage_queue

Creates a EventGrid Domain Topic that integrates HTTP Request and Storage Queue.

## How to test

curl --location '{eventgrid_domain_endpoint}' \
--header 'aeg-sas-key: {eventgrid_domain_primary_access_key}' \
--header 'Content-Type: application/json' \
--data '[
    {
        "id": "d5474e1e-76f9-4f58-a08f-2015a16f732d",
        "topic": "domain-topic"
        "eventType": "QuickTutorialsWithAzure.EventGrid.UseCaseCreated",
        "subject": "usecase",
        "eventTime": "2023-01-01T00:00:00",
        "data": {
            "useCaseName": "domain_topic_storage_queue"
        },
        "dataVersion": "1.0"
    }
]'
Terraform module for a Pub/Sub Topic (with subscribers) in GCP

# Push Subscriptions

The `push_subscriptions` variable accepts a list of push subscriber configurations. PubSub will send push messages to all these push subscribers when a message is available.

```terraform
push_subscriptions = [
  {
    name                       = "Just any name"
    push_endpoint              = "https://an.endpoint/to_be_called/when_a_message/is_available/for_delivery"
    auth_sa_email              = "Email address of a ServiceAccount that has permission to call this endpoint"
    auth_audience              = "A case-insensitive string that can be used to validate intended audience"
    ack_deadline_seconds       = "Overrides 'var.default_ack_deadline_seconds' for this subscriber"
    message_retention_duration = "Overrides 'var.default_message_retention_duration' for this subscriber"
    expiry_ttl                 = "Overrides 'var.default_expiry_ttl' for this subscriber"
  }
]
```
More information on push authentication here - https://cloud.google.com/pubsub/docs/push#setting_up_for_push_authentication

# Pull Subscriptions

The `pull_subscriptions` variable accepts a list of pull subscriber configurations. PubSub will hold on to messages until these pull subsribers poll/fetch them from PubSub.

```terraform
pull_subscriptions = [
  {
    name                       = "Just any name"
    ack_deadline_seconds       = "Overrides 'var.default_ack_deadline_seconds' for this subscriber"
    message_retention_duration = "Overrides 'var.default_message_retention_duration' for this subscriber"
    expiry_ttl                 = "Overrides 'var.default_expiry_ttl' for this subscriber"
  }
]
```

# BigQuery Subscriptions

The `bigquery_subscriptions` variable accepts a list of bigquery subscriber configurations. PubSub will write messages to an existing BigQuery table as they are received.

```terraform
bigquery_subscriptions = [
  {
    name  = "Just any name"
    table = "The name of the table to which to write data from pubsub."
  }
]
```

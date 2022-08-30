terraform {
  required_version = ">= 0.13.1" # see https://releases.hashicorp.com/terraform/
}

data "google_project" "project" {}
data "google_client_config" "google_client" {}

locals {
  google_pubsub_sa_email = "service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  default_expiry_ttl     = var.default_expiry_ttl == "NEVER" ? "" : var.default_expiry_ttl
  topic_name             = format("%s-%s", var.topic_name, var.name_suffix)
  push_subscriptions = [
    for subscription in var.push_subscriptions :
    {
      name                       = format("%s-%s-push-%s", var.topic_name, subscription.name, var.name_suffix)
      push_endpoint              = subscription.push_endpoint
      auth_sa_email              = lookup(subscription, "auth_sa_email", null)
      auth_audience              = lookup(subscription, "auth_audience", null)
      dead_letter_topic          = lookup(subscription, "dead_letter_topic", null)
      dead_letter_max_attempts   = lookup(subscription, "dead_letter_max_attempts", var.default_dead_letter_max_attempts)
      ack_deadline_seconds       = lookup(subscription, "ack_deadline_seconds", var.default_ack_deadline_seconds)
      message_retention_duration = lookup(subscription, "message_retention_duration", var.default_message_retention_duration)
      expiry_ttl                 = lookup(subscription, "expiry_ttl", local.default_expiry_ttl)
      filter                     = lookup(subscription, "filter", "")
      minimum_backoff            = lookup(subscription, "minimum_backoff", var.default_minimum_backoff)
      maximum_backoff            = lookup(subscription, "maximum_backoff", var.default_maximum_backoff)
    }
  ]
  pull_subscriptions = [
    for subscription in var.pull_subscriptions :
    {
      name                       = format("%s-%s-pull-%s", var.topic_name, subscription.name, var.name_suffix)
      ack_deadline_seconds       = lookup(subscription, "ack_deadline_seconds", var.default_ack_deadline_seconds)
      message_retention_duration = lookup(subscription, "message_retention_duration", var.default_message_retention_duration)
      expiry_ttl                 = lookup(subscription, "expiry_ttl", local.default_expiry_ttl)
      filter                     = lookup(subscription, "filter", "")
      minimum_backoff            = lookup(subscription, "minimum_backoff", var.default_minimum_backoff)
      maximum_backoff            = lookup(subscription, "maximum_backoff", var.default_maximum_backoff)
    }
  ]
}

resource "google_project_service" "pubsub_api" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

resource "google_pubsub_topic" "topic" {
  name       = local.topic_name
  depends_on = [google_project_service.pubsub_api]
}

resource "google_pubsub_subscription" "push_subscriptions" {
  count                      = length(local.push_subscriptions)
  name                       = local.push_subscriptions[count.index].name
  topic                      = google_pubsub_topic.topic.name
  ack_deadline_seconds       = local.push_subscriptions[count.index]["ack_deadline_seconds"]
  message_retention_duration = local.push_subscriptions[count.index]["message_retention_duration"]
  filter                     = local.push_subscriptions[count.index].filter
  dynamic "dead_letter_policy" {
    for_each = local.push_subscriptions[count.index]["dead_letter_topic"] == null ? [] : [1]
    content {
      dead_letter_topic     = local.push_subscriptions[count.index]["dead_letter_topic"]
      max_delivery_attempts = local.push_subscriptions[count.index]["dead_letter_max_attempts"]
    }
  }
  push_config {
    push_endpoint = local.push_subscriptions[count.index]["push_endpoint"]
    dynamic "oidc_token" {
      # add this block only if 'auth_sa_email' is present for this subscription
      for_each = local.push_subscriptions[count.index]["auth_sa_email"] == null ? [] : [1]
      content {
        service_account_email = local.push_subscriptions[count.index]["auth_sa_email"]
        audience              = local.push_subscriptions[count.index]["auth_audience"]
      }
    }
  }
  expiration_policy { ttl = local.push_subscriptions[count.index]["expiry_ttl"] }
  retry_policy {
    minimum_backoff = local.push_subscriptions[count.index]["minimum_backoff"]
    maximum_backoff = local.push_subscriptions[count.index]["maximum_backoff"]
  }
  depends_on = [google_project_service.pubsub_api]
}

resource "google_pubsub_subscription" "pull_subscriptions" {
  count                      = length(local.pull_subscriptions)
  name                       = local.pull_subscriptions[count.index].name
  topic                      = google_pubsub_topic.topic.name
  ack_deadline_seconds       = local.pull_subscriptions[count.index]["ack_deadline_seconds"]
  message_retention_duration = local.pull_subscriptions[count.index]["message_retention_duration"]
  filter                     = local.pull_subscriptions[count.index].filter
  expiration_policy { ttl = local.pull_subscriptions[count.index]["expiry_ttl"] }
  retry_policy {
    minimum_backoff = local.pull_subscriptions[count.index]["minimum_backoff"]
    maximum_backoff = local.pull_subscriptions[count.index]["maximum_backoff"]
  }
  depends_on = [google_project_service.pubsub_api]
}

resource "google_project_iam_member" "pubsub_sa_create_oidc_token" {
  # GCP requires the iam.serviceAccountTokenCreator role to be granted
  # on a special ServiceAccount maintained by GCP for PubSub push authentication to work.
  # See https://cloud.google.com/pubsub/docs/push#setting_up_for_push_authentication
  project    = data.google_client_config.google_client.project
  role       = "roles/iam.serviceAccountTokenCreator"
  member     = "serviceAccount:${local.google_pubsub_sa_email}"
  depends_on = [google_project_service.pubsub_api]
}

# See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription#dead_letter_policy
resource "google_project_iam_member" "pubsub_sa_acknowledge_for_dead_letter" {
  project    = data.google_client_config.google_client.project
  role       = "roles/pubsub.subscriber"
  member     = "serviceAccount:${local.google_pubsub_sa_email}"
  depends_on = [google_project_service.pubsub_api]
}

# See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription#dead_letter_topic
resource "google_project_iam_member" "pubsub_sa_publish_to_dead_letter" {
  project    = data.google_client_config.google_client.project
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${local.google_pubsub_sa_email}"
  depends_on = [google_project_service.pubsub_api]
}

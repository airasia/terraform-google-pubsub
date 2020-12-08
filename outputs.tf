output "usage_IAM_roles" {
  description = "Basic IAM role(s) that are generally necessary for using the resources in this module. See https://cloud.google.com/iam/docs/understanding-roles."
  value = [
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber",
    "roles/pubsub.viewer",
  ]
}

output "topic_id" {
  description = "An identifier of the topic with format projects/{{project}}/topics/{{name}}"
  value       = google_pubsub_topic.topic.id
}

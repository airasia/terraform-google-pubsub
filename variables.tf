# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "tf_env" {
  description = "Just an identifier that will be used in GCP resource names. Will help us distinguish resources created by Terraform versus resources that were already created before Terraform."
  type        = string
  validation {
    condition     = length(var.tf_env) <= 10
    error_message = "A max of 10 character(s) are allowed."
  }
}

variable "topic_name" {
  description = "The topic name for this PubSub."
  type        = string
}

variable "push_subscriptions" {
  description = "List of the push subscriptions (if any)."
  type        = list(map(string))
  default     = []
}

variable "pull_subscriptions" {
  description = "List of the pull subscriptions (if any)."
  type        = list(map(string))
  default     = []
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "default_ack_deadline_seconds" {
  description = "Default ackDeadline (in seconds) which will be used if such is not defined by the subscriptions."
  type        = number
  default     = 10
  validation {
    condition     = (var.default_ack_deadline_seconds >= 10) && (var.default_ack_deadline_seconds <= 600)
    error_message = "Must be an integer between 10 to 600."
  }
}

variable "default_message_retention_duration" {
  description = "Default message retention duration (in seconds) which will be used if such is not defined by the subscriptions. Default '604800s' = 7 days."
  type        = string
  default     = "604800s"
}

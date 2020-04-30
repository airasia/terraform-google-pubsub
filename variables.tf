# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "name_suffix" {
  description = "An arbitrary suffix that will be added to the end of the resource name(s). For example: an environment name, a business-case name, a numeric id, etc."
  type        = string
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

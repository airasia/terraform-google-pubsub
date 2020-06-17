# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "name_suffix" {
  description = "An arbitrary suffix that will be added to the end of the resource name(s). For example: an environment name, a business-case name, a numeric id, etc."
  type        = string
  validation {
    condition     = length(var.name_suffix) <= 14
    error_message = "A max of 14 character(s) are allowed."
  }
}

variable "topic_name" {
  description = "The topic name for this PubSub."
  type        = string
}

variable "push_subscriptions" {
  description = "List of push subscriptions (if any) with key-value configurations. See source code for accepted keys of the configuration."
  type        = list(map(string))
  default     = []
}

variable "pull_subscriptions" {
  description = "List of pull subscriptions (if any) with key-value configurations. See source code for accepted keys of the configuration."
  type        = list(map(string))
  default     = []
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "default_ack_deadline_seconds" {
  description = "Sets default value (in seconds) for maximum time before which subsribers should acknowledge a received message. Current default = 10 seconds."
  type        = number
  default     = 10
  validation {
    condition     = (var.default_ack_deadline_seconds >= 10) && (var.default_ack_deadline_seconds <= 600)
    error_message = "Must be an integer between 10 to 600."
  }
}

variable "default_message_retention_duration" {
  description = "Sets default value (in seconds) for how long should unacknowledged messages be retained by PubSub. Current default '604800s' = 7 days."
  type        = string
  default     = "604800s"
}

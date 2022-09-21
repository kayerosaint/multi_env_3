variable "roles" {
  type = map(
    list(
      string
    )
  )
}

variable "users" {
  type = map(
    object({
      name = string,
      role = string,
      key  = bool,
    })
  )
}

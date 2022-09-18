
output "map" {
  value = jsondecode(
    join("",
      [
        "[",
        join(",",
          [
            for k, v in var.map :
            templatefile(
              "${path.module}/environment_template.tpl", {
                k = k
                v = v,
              }
            )
          ]
        ),
        "]"
      ]
    )
  )
}

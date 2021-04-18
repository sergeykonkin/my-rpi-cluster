job "fabio" {
  region      = "local"
  datacenters = ["home"]

  group "fabio" {
    count = 1
    task "fabio" {
      driver = "raw_exec"
      config {
        command = "fabio"
        args    = ["-proxy.strategy=rr"]
      }
      artifact {
        source      = "https://github.com/fabiolb/fabio/releases/download/v1.5.15/fabio-1.5.15-go1.15.5-linux_arm"
        destination = "local/fabio"
        mode        = "file"
      }
    }
  }
}

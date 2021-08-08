# ポート情報を別ファイルで管理
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
}